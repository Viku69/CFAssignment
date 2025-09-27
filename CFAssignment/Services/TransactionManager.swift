//
//  TransactionManager.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import Foundation

// MARK: - Transaction Manager

/// Manages the stream of Bitcoin transactions received via WebSocket.
/// Handles processing, filtering, and notifying subscribers of new transactions.
@MainActor
final class TransactionManager {
    
    // MARK: - Streams
    
    /// Continuation for pushing transaction updates to `transactionStream`.
    private var txContinuation: AsyncStream<[Transaction]>.Continuation?
    
    /// Async stream of transactions that UI or other consumers can subscribe to.
    lazy var transactionStream: AsyncStream<[Transaction]> = {
        AsyncStream { cont in
            self.txContinuation = cont
            cont.yield(self.transactions)
        }
    }()
    
    /// Async stream of WebSocket connection status updates.
    let statusStream: AsyncStream<WSConnectionStatus>
    
    /// Continuation for pushing error messages to `errorStream`.
    private var errorContinuation: AsyncStream<String?>.Continuation!
    
    /// Async stream of error messages that UI can observe.
    lazy var errorStream: AsyncStream<String?> = {
        AsyncStream { cont in
            self.errorContinuation = cont
            cont.yield(nil)
        }
    }()
    
    
    // MARK: - Dependencies
    
    /// WebSocket service providing real-time transaction data.
    private let webSocket: IWebSocketService
    
    /// Service to fetch BTC → USD conversion rate.
    private let priceService: IPriceService
    
    
    // MARK: - State
    
    /// Currently tracked transactions.
    private var transactions: [Transaction] = []
    
    /// Maximum number of transactions to keep in memory.
    private let maxSize: Int
    
    /// Minimum USD value to consider a transaction significant.
    private let usdThreshold: Double
    
    /// Background task consuming WebSocket messages.
    private var consumerTask: Task<Void, Never>?
    
    
    // MARK: - Initializer
    
    /// Initializes the TransactionManager with required services and configuration.
    /// - Parameters:
    ///   - webSocket: The WebSocket service providing live transaction data.
    ///   - priceService: Service to fetch BTC → USD price.
    ///   - maxSize: Maximum number of transactions to retain (default: 5).
    ///   - usdThreshold: Minimum USD value to process a transaction (default: 100).
    init(
        webSocket: IWebSocketService,
        priceService: IPriceService,
        maxSize: Int = 5,
        usdThreshold: Double = 100.0
    ) {
        self.webSocket = webSocket
        self.priceService = priceService
        self.maxSize = maxSize
        self.usdThreshold = usdThreshold
        self.statusStream = webSocket.statusStream
    }
    
    
    // MARK: - Lifecycle Methods
    
    /// Starts the WebSocket connection and begins processing incoming messages.
    func start() async {
        await webSocket.start()
        
        // Consumer task: process incoming raw Data messages
        consumerTask = Task { [weak self] in
            guard let self = self else { return }
            for await data in self.webSocket.messageStream {
                await self.handle(data: data)
            }
        }
    }
    
    /// Stops the consumer task and closes the WebSocket connection.
    func stop() {
        consumerTask?.cancel()
        webSocket.stop()
    }
    
    /// Clears all tracked transactions and notifies subscribers.
    func clear() {
        transactions.removeAll()
        txContinuation?.yield(transactions)
    }
    
    
    // MARK: - Private Methods
    
    /// Handles incoming raw WebSocket data, decodes UTX messages,
    /// filters, converts to USD, and updates the transaction stream.
    /// - Parameter data: Raw Data from WebSocket
    private func handle(data: Data) async {
        do {
            let decoder = JSONDecoder()
            let msg = try decoder.decode(UTXMessage.self, from: data)
            
            // Only process unconfirmed transactions
            guard msg.op == "utx", let detail = msg.x, let hash = detail.hash else { return }
            
            // Compute total BTC
            let totalSats = detail.out?.compactMap { $0.value }.reduce(0, +) ?? 0
            let btc = Double(totalSats) / 100_000_000.0
            
            // Fetch current BTC → USD price (may use cache)
            let price = try await priceService.fetchBTCUSD(forceRefresh: false)
            let usd = btc * price
            
            // Filter by USD threshold
            guard usd >= usdThreshold else { return }
            
            let tx = Transaction(
                id: hash,
                btcAmount: btc,
                usdAmount: usd,
                time: Date(timeIntervalSince1970: detail.time ?? Date().timeIntervalSince1970)
            )
            
            // Avoid duplicates
            if transactions.contains(where: { $0.id == tx.id }) { return }
            
            // Insert at top
            transactions.insert(tx, at: 0)
            
            // Trim to max size
            if transactions.count > maxSize {
                transactions = Array(transactions.prefix(maxSize))
            }
            
            // Notify subscribers
            txContinuation?.yield(transactions)
            
        } catch {
            // Send error to stream
            let msg = (error as? LocalizedError)?.errorDescription ?? "\(error)"
            errorContinuation.yield(msg)
            Logger.log("TransactionManager handle error:", error)
        }
    }
}
