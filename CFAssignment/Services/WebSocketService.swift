//
//  WebSocketService.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import Foundation
import OSLog

// MARK: - WebSocket Service

/// Handles a bidirectional WebSocket connection to a blockchain API.
/// Provides async streams for incoming messages and connection status updates.
@MainActor
final class WebSocketService: IWebSocketService {
    
    // MARK: - Properties
    
    /// WebSocket server URL.
    private let url: URL
    
    /// URLSessionWebSocketTask used for communication.
    private var task: URLSessionWebSocketTask?
    
    /// URLSession for creating tasks.
    private var session: URLSession
    
    /// Indicates whether the WebSocket is currently active.
    private var isActive = false
    
    // MARK: Continuations
    
    /// Continuation for pushing received messages to `messageStream`.
    private var messageContinuation: AsyncStream<Data>.Continuation?
    
    /// Continuation for pushing status updates to `statusStream`.
    private var statusContinuation: AsyncStream<WSConnectionStatus>.Continuation?
    
    // MARK: - Public Streams
    
    /// Stream of incoming raw messages (Data) from the WebSocket.
    lazy var messageStream: AsyncStream<Data> = AsyncStream { cont in
        self.messageContinuation = cont
    }
    
    /// Stream of WebSocket connection status updates.
    lazy var statusStream: AsyncStream<WSConnectionStatus> = AsyncStream { cont in
        self.statusContinuation = cont
        cont.yield(.disconnected)
    }
    
    // MARK: - Initialization
    
    /// Initializes the WebSocketService.
    /// - Parameters:
    ///   - url: Optional WebSocket URL (defaults to `wss://ws.blockchain.info/inv`).
    ///   - session: Optional URLSession (defaults to `.shared`).
    init(url: URL? = nil, session: URLSession = .shared) {
        self.url = url ?? URL(string: "wss://ws.blockchain.info/inv")!
        self.session = session
    }
    
    // MARK: - Start / Stop
    
    /// Starts the WebSocket connection and begins receiving messages.
    func start() async {
        guard !isActive else { return } // prevent multiple starts
        isActive = true
        await updateStatus(.connecting)
        
        // Create and start the WebSocket task
        task = session.webSocketTask(with: url)
        task?.resume()
        await updateStatus(.connected)
        
        // Start async receive loop
        Task { [weak self] in
            await self?.receiveLoop()
        }
        
        // Send initial subscription message
        await send(dictionary: ["op": "unconfirmed_sub"])
    }
    
    /// Stops the WebSocket connection and cancels the task.
    func stop() {
        isActive = false
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        statusContinuation?.yield(.disconnected)
    }
    
    // MARK: - Send
    
    /// Sends a JSON message over the WebSocket.
    /// - Parameter dictionary: JSON-compatible dictionary to send.
    func send(dictionary: [String: Any]) async {
        guard let task = task else { return }
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary)
            if let text = String(data: data, encoding: .utf8) {
                try await task.send(.string(text))
            }
        } catch {
            Logger.log("WS send error", error)
            // Optional: implement retry logic
        }
    }
    
    // MARK: - Receive Loop
    
    /// Continuously receives messages from the WebSocket and handles reconnections.
    private func receiveLoop() async {
        guard let task = task else { return }
        var reconnectDelay: UInt64 = 1_000_000_000 // initial 1s
        
        while isActive {
            do {
                let msg = try await task.receive()
                reconnectDelay = 1_000_000_000 // reset delay on success
                
                // Yield data to message stream
                switch msg {
                case .data(let d):
                    messageContinuation?.yield(d)
                case .string(let s):
                    if let d = s.data(using: .utf8) {
                        messageContinuation?.yield(d)
                    }
                @unknown default:
                    break
                }
                
            } catch {
                Logger.log("WS receive error", error)
                await updateStatus(.disconnected)
                
                guard isActive else { break }
                
                // Exponential backoff reconnect
                try? await Task.sleep(nanoseconds: reconnectDelay)
                reconnectDelay = min(reconnectDelay * 2, 30_000_000_000) // max 30s
                
                // Clean up old task
                task.cancel(with: .goingAway, reason: nil)
                self.task = nil
                
                // Reconnect
                await start()
                break
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Updates the connection status stream.
    /// - Parameter status: New WebSocket connection status.
    private func updateStatus(_ status: WSConnectionStatus) async {
        statusContinuation?.yield(status)
    }
}
