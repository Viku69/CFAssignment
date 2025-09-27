//
//  EmptyStateView.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import SwiftUI

// MARK: - Empty State View

/// A SwiftUI view shown when no transactions are available.
/// Displays the current connection status, a placeholder graphic, and a loader while connecting.
struct EmptyStateView: View {
    
    /// The current WebSocket connection status to display.
    let statusText: String

    // MARK: - Body
    var body: some View {
        VStack {
            Spacer()
            
            // Main card container
            VStack(spacing: 24) {
                
                // Icon with circular background
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1)) // light background for icon
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                }

                // Title text
                Text("Monitoring Bitcoin Network")
                    .font(.title2)
                    .fontWeight(.semibold)

                // Description text
                Text("Listening for unconfirmed transactions above $100")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // Status view showing connection state
                StatusView(statusText: statusText)

                // Loader shown while WebSocket is connecting
                if statusText == WSConnectionStatus.connecting.rawValue {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(1.5)
                        .padding(.top, 12)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial) // blurry material background
                    .shadow(radius: 10)
            )
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}
