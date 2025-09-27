//
//  TransactionListView.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import SwiftUI

// MARK: - Transaction List View

/// A SwiftUI view that displays a list of Bitcoin transactions along with total count and value.
/// Supports pull-to-refresh and animated insertion/removal of rows.
struct TransactionListView: View {
    
    /// Array of transactions to display.
    let transactions: [Transaction]
    
    /// Formatted total USD value of all transactions.
    let totalValue: String
    
    /// Current WebSocket connection status text.
    let connectionStatusText: String
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            
            // Header showing total transactions and total value
            HStack {
                
                // Left: Total transactions
                VStack(alignment: .leading) {
                    Text("Total Transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(transactions.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Right: Total value in USD
                VStack(alignment: .trailing) {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(totalValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            
            // Scrollable list of transactions
            ScrollView {
                LazyVStack(spacing: 16) {
                    
                    // Each transaction row with animated insertion/removal
                    ForEach(transactions) { tx in
                        TransactionRowView(tx: tx)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .top),
                                    removal: .move(edge: .trailing)
                                )
                            )
                    }
                }
                .padding()
            }
        }
    }
}
