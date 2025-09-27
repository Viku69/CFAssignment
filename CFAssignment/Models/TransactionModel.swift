//
//  TransactionModel.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import Foundation

// MARK: - Transaction Model

/// Represents a single Bitcoin transaction in the app.
struct Transaction: Identifiable, Hashable {
    /// Unique transaction identifier (hash).
    let id: String
    
    /// Amount of Bitcoin in the transaction (in BTC).
    let btcAmount: Double
    
    /// Equivalent USD value of the transaction.
    let usdAmount: Double
    
    /// Timestamp of when the transaction occurred.
    let time: Date
}


// MARK: - WebSocket Models (Raw Blockchain API)

/// Root WebSocket message received from the blockchain API.
///
/// Example:
/// ```json
/// {
///   "op": "utx",
///   "x": { ... }
/// }
/// ```
struct UTXMessage: Codable {
    /// Operation type (e.g., `"utx"` for unconfirmed transaction).
    let op: String
    
    /// Transaction details payload.
    let x: UTXDetail?
}

/// Detailed unconfirmed transaction (UTX) data.
struct UTXDetail: Codable {
    /// Unix timestamp (seconds since 1970).
    let time: TimeInterval?
    
    /// Unique transaction hash.
    let hash: String?
    
    /// List of transaction outputs.
    let out: [UTXOut]?
}

/// Transaction output entry (each recipient in the transaction).
struct UTXOut: Codable {
    /// Value in satoshis (1 BTC = 100,000,000 satoshis).
    let value: Int64?
}
