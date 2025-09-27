//
//  AppCoordinator.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import SwiftUI

// MARK: - App Entry Point (Dependency Injection)

enum AppEntry {
    
    /// Creates and configures the `TransactionManager` with required services.
    /// - Returns: A ready-to-use `TransactionManager`.
    static func makeTransactionManager() -> TransactionManager {
        let ws = WebSocketService()
        let price = PriceService()
        return TransactionManager(
            webSocket: ws,
            priceService: price
        )
    }

    /// Builds the root view of the app.
    /// Sets up the ViewModel and injects dependencies into `MainView`.
    /// - Returns: The root SwiftUI `View` wrapped in a `NavigationStack`.
    static func makeRootView() -> some View {
        let manager = makeTransactionManager()
        let vm = TransactionQueueViewModel(manager: manager)
        return NavigationStack {
            MainView(viewModel: vm)
        }
    }
}


// MARK: - App Coordinator (High-Level Entry)

/// Acts as the top-level coordinator to provide the app’s root view.
/// Useful if the app later expands with multiple coordinators or flows.
struct AppCoordinator {
    
    /// Returns the root SwiftUI view for the app.
    static func makeRootView() -> some View {
        AppEntry.makeRootView()
    }
}
