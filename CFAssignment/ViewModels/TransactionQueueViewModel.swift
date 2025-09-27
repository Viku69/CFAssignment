//
//  TransactionQueueViewModel.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import Foundation
import Combine

// MARK: - Transaction Queue ViewModel

/// ViewModel for managing a queue of Bitcoin transactions.
/// Observes a `TransactionManager` and publishes transaction updates,
/// connection status, and errors to the SwiftUI views.
@MainActor
final class TransactionQueueViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current list of transactions. Read-only from outside.
    @Published private(set) var transactions: [Transaction] = []
    
    /// Current WebSocket connection status as a string.
    @Published private(set) var connectionStatusText: String = WSConnectionStatus.disconnected.rawValue
    
    /// Optional error message from the TransactionManager.
    @Published var errorMessage: String?
    
    
    // MARK: - Dependencies
    
    /// The underlying transaction manager providing streams and data.
    private let manager: TransactionManager
    
    
    // MARK: - Tasks
    
    /// Task subscribing to transaction updates.
    private var txTask: Task<Void, Never>?
    
    /// Task subscribing to connection status updates.
    private var statusTask: Task<Void, Never>?
    
    /// Task subscribing to error messages.
    private var errorTask: Task<Void, Never>?
    
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with a given `TransactionManager`.
    /// - Parameter manager: The transaction manager providing streams and transaction handling.
    init(manager: TransactionManager) {
        self.manager = manager
    }
    
    
    // MARK: - Public Methods
    
    /// Starts observing the TransactionManager streams and initiates WebSocket connection.
    func start() {
        // Ensure manager is restarted
        Task {
            manager.stop()
            await manager.start()
        }
        
        // Subscribe to transaction updates
        txTask = Task { [weak self] in
            guard let self = self else { return }
            for await txs in manager.transactionStream {
                await MainActor.run {
                    self.transactions = txs
                }
            }
        }
        
        // Subscribe to connection status updates
        statusTask = Task { [weak self] in
            guard let self = self else { return }
            for await status in manager.statusStream {
                await MainActor.run {
                    self.connectionStatusText = status.rawValue
                }
            }
        }
        
        // Subscribe to error messages
        errorTask = Task { [weak self] in
            guard let self = self else { return }
            for await err in manager.errorStream {
                await MainActor.run {
                    self.errorMessage = err
                }
            }
        }
    }
    
    /// Stops observing streams and disconnects the TransactionManager.
    func stop() {
        txTask?.cancel()
        statusTask?.cancel()
        errorTask?.cancel()
        manager.stop()
    }
    
    /// Clears all transactions from the manager.
    func clearQueue() {
        manager.clear()
    }
}
