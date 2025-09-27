//
//  TransactionRowView.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import SwiftUI

// MARK: - Transaction Row View

/// A SwiftUI view representing a single Bitcoin transaction.
/// Shows transaction ID (hash), USD value, BTC amount, and timestamp.
/// Supports copy-to-clipboard with animated feedback and haptic feedback.
struct TransactionRowView: View {
    
    /// Transaction model containing all necessary info.
    let tx: Transaction
    
    /// Tracks tap/press animation state.
    @State private var isPressed = false
    
    /// Shows a checkmark briefly when the transaction ID is copied.
    @State private var showCopiedFeedback = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // HEADER: Transaction ID + USD amount
            HStack(alignment: .top, spacing: 12) {
                
                // Transaction hash with copy button
                VStack(alignment: .leading, spacing: 4) {
                    // Label for transaction ID
                    HStack(spacing: 6) {
                        Image(systemName: "number")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("Transaction ID")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    
                    // Copyable transaction hash
                    Button(action: copyTransactionID) {
                        HStack(spacing: 6) {
                            Text(formattedTransactionID)
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            Image(systemName: showCopiedFeedback ? "checkmark.circle.fill" : "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(showCopiedFeedback ? .green : .secondary)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                // USD Amount display
                VStack(alignment: .trailing, spacing: 2) {
                    Text(tx.usdAmount.usdString())
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("USD VALUE")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
            }
            
            // Divider
            Rectangle()
                .fill(Color.secondary.opacity(0.1))
                .frame(height: 1)
            
            // FOOTER: BTC amount + timestamp
            HStack(alignment: .bottom) {
                
                // BTC amount
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "bitcoinsign.circle")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("BTC AMOUNT")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    
                    Text(String(format: "%.6f", tx.btcAmount))
                        .font(.system(.subheadline, design: .monospaced, weight: .medium))
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                // Timestamp
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("RECEIVED")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    
                    Text(tx.time.formattedIST())
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.blue.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: .black.opacity(isPressed ? 0.08 : 0.04),
                    radius: isPressed ? 8 : 12,
                    x: 0,
                    y: isPressed ? 4 : 6
                )
        )
        // Tap animation
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onTapGesture {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            // Press animation
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
            }
            
            // Copy transaction ID
            copyTransactionID()
        }
    }
    
    // MARK: - Helper Properties & Methods
    
    /// Shortened transaction ID for display (first 8 + last 8 chars).
    private var formattedTransactionID: String {
        let hash = tx.id
        if hash.count > 16 {
            return "\(hash.prefix(8))...\(hash.suffix(8))"
        }
        return hash
    }
    
    /// Copies the transaction ID to clipboard and shows animated feedback.
    private func copyTransactionID() {
        UIPasteboard.general.string = tx.id
        
        // Show copied checkmark
        withAnimation(.easeInOut(duration: 0.2)) {
            showCopiedFeedback = true
        }
        
        // Hide feedback after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showCopiedFeedback = false
            }
        }
        
        // Haptic success feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
}
