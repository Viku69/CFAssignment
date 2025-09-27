//
//  StatusView.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.

import SwiftUI

// MARK: - Status View

/// A small capsule-shaped view indicating the current WebSocket connection status.
/// Shows a colored circle with optional pulsing animation when connecting, along with status text.
struct StatusView: View {
    
    /// The connection status text to display.
    let statusText: String
    
    /// Controls the pulse animation for the connecting state.
    @State private var pulseAnimation = false
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 8) {
            
            // Status indicator with pulse animation
            ZStack {
                // Background circle with subtle glow
                Circle()
                    .fill(color(for: statusText).opacity(0.2))
                    .frame(width: 20, height: 20)
                
                // Main status circle
                Circle()
                    .fill(color(for: statusText))
                    .frame(width: 12, height: 12)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .animation(
                        statusText == WSConnectionStatus.connecting.rawValue ?
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .none,
                        value: pulseAnimation
                    )
                
                // Expanding pulse ring shown only while connecting
                if statusText == WSConnectionStatus.connecting.rawValue {
                    Circle()
                        .stroke(color(for: statusText).opacity(0.3), lineWidth: 1)
                        .frame(width: pulseAnimation ? 24 : 16, height: pulseAnimation ? 24 : 16)
                        .opacity(pulseAnimation ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.5).repeatForever(autoreverses: false),
                            value: pulseAnimation
                        )
                }
            }
            
            // Status text label
            Text(statusText.capitalized)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundColor(textColor(for: statusText))
                .contentTransition(.opacity)
                .fixedSize() // Prevents clipping
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(backgroundColor(for: statusText))
                .overlay(
                    Capsule()
                        .strokeBorder(color(for: statusText).opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            // Start pulse animation if connecting
            if statusText == WSConnectionStatus.connecting.rawValue {
                pulseAnimation = true
            }
        }
        .onChange(of: statusText) { oldValue, newValue in
            // Animate pulse when status changes
            withAnimation(.easeInOut(duration: 0.3)) {
                pulseAnimation = newValue == WSConnectionStatus.connecting.rawValue
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns the circle/stroke color for a given status.
    private func color(for status: String) -> Color {
        switch status {
        case WSConnectionStatus.connected.rawValue:
            return .green
        case WSConnectionStatus.connecting.rawValue:
            return .orange
        default:
            return .red
        }
    }
    
    /// Returns the background color for the capsule based on status.
    private func backgroundColor(for status: String) -> Color {
        switch status {
        case WSConnectionStatus.connected.rawValue:
            return Color.green.opacity(0.12)
        case WSConnectionStatus.connecting.rawValue:
            return Color.orange.opacity(0.12)
        default:
            return Color.red.opacity(0.12)
        }
    }
    
    /// Returns the text color for the status label.
    private func textColor(for status: String) -> Color {
        switch status {
        case WSConnectionStatus.connected.rawValue:
            return .green
        case WSConnectionStatus.connecting.rawValue:
            return .orange
        default:
            return .red
        }
    }
}
