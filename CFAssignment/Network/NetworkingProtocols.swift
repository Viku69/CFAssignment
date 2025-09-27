//
//  NetworkingProtocols.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import Foundation

// MARK: - WebSocket Connection Status

/// Represents the current state of the WebSocket connection.
enum WSConnectionStatus: String {
    /// The socket is in the process of connecting.
    case connecting = "Connecting..."
    
    /// The socket is successfully connected.
    case connected = "Connected"
    
    /// The socket has been disconnected (either manually or due to an error).
    case disconnected = "Disconnected"
}


// MARK: - WebSocket Service Protocol

/// Defines the interface for a WebSocket service.
///
/// Provides real-time blockchain data streaming via asynchronous streams.
protocol IWebSocketService: AnyObject {
    
    // MARK: Streams
    
    /// Stream of incoming WebSocket messages (raw JSON data).
    var messageStream: AsyncStream<Data> { get }
    
    /// Stream of WebSocket connection status updates.
    var statusStream: AsyncStream<WSConnectionStatus> { get }
    
    
    // MARK: Lifecycle
    
    /// Starts the WebSocket connection and begins streaming data.
    func start() async
    
    /// Stops the WebSocket connection.
    func stop()
    
    /// Sends a message to the WebSocket server.
    /// - Parameter dictionary: A JSON-like dictionary to send.
    func send(dictionary: [String: Any]) async
}


// MARK: - Price Service Protocol

/// Defines the interface for fetching the current BTC → USD exchange rate.
protocol IPriceService: AnyObject {
    
    /// Fetches the current BTC price in USD.
    ///
    /// - Parameter forceRefresh: If `true`, forces a network refresh instead of using cached data.
    /// - Returns: The BTC price in USD.
    /// - Throws: An error if the request fails (e.g., network error).
    func fetchBTCUSD(forceRefresh: Bool) async throws -> Double
}
