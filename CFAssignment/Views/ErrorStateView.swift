//
//  ErrorStateView.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import SwiftUI

// MARK: - Error State View

/// A SwiftUI view shown when a WebSocket connection or transaction fetch fails.
/// Displays an error message, current status, and provides a retry button.
struct ErrorStateView: View {
    
    /// The error message to display.
    let error: String
    
    /// Closure to call when the user taps the retry button.
    let retry: () -> Void
    
    /// The current WebSocket connection status (optional display if needed).
    let statusText: String

    // MARK: - Body
    var body: some View {
        VStack {
            Spacer()
            
            // Main card container
            VStack(spacing: 16) {
                
                // Error icon
                Image(systemName: "wifi.slash")
                    .font(.system(size: 48))
                    .foregroundColor(.red)

                // Title text
                Text("Connection Error")
                    .font(.title2)
                    .fontWeight(.semibold)

                // Detailed error description
                Text(error)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                // Retry button
                Button("Retry Connection", action: retry)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial) // blurred card background
            )
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}
