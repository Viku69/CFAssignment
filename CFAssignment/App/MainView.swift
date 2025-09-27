//
//  MainView.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.

import SwiftUI

struct MainView: View {
    
    // MARK: - Properties
    
    /// ViewModel managing transaction queue and websocket connection
    @StateObject private var vm: TransactionQueueViewModel
    
    /// Controls the clear-all-transactions confirmation alert
    @State private var showingClearAlert = false
    
    /// Keeps track of the last transaction count for feedback handling
    @State private var lastTransactionCount = 0

    
    // MARK: - Initializer
    
    init(viewModel: TransactionQueueViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: vm.connectionStatusText)
            
            VStack(spacing: 0) {
                switch true {
                case vm.errorMessage != nil:
                    ErrorStateView(
                        error: vm.errorMessage ?? "",
                        retry: { vm.start() },
                        statusText: vm.connectionStatusText
                    )
                    
                case vm.transactions.isEmpty:
                    EmptyStateView(
                        statusText: vm.connectionStatusText
                    )
                    
                default:
                    TransactionListView(
                        transactions: vm.transactions,
                        totalValue: totalValueString,
                        connectionStatusText: vm.connectionStatusText,
                    )
                }
            }
        }
        .navigationTitle(navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        
        // MARK: - Lifecycle Tasks
        .task { vm.start() }
        .onDisappear { vm.stop() }
        
        // Observe transaction count changes for haptics
        .onChange(of: vm.transactions.count) { old, new in
            handleTransactionCountChange(oldCount: old, newCount: new)
        }
        
        // Clear-all confirmation alert
        .alert("Clear All Transactions", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) { vm.clearQueue() }
        } message: {
            Text("This will remove all \(vm.transactions.count) transactions. Cannot be undone.")
        }
    }
    
    
    // MARK: - UI Helpers
    
    /// Gradient background changes color depending on WebSocket connection status
    private var backgroundGradient: LinearGradient {
        switch vm.connectionStatusText {
        case WSConnectionStatus.connected.rawValue:
            return LinearGradient(
                colors: [.green.opacity(0.4), .blue.opacity(0.03), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        case WSConnectionStatus.connecting.rawValue:
            return LinearGradient(
                colors: [.orange.opacity(0.4), .yellow.opacity(0.02), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        default:
            return LinearGradient(
                colors: [.red.opacity(0.4), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    
    // MARK: - Computed Properties
    
    /// Navigation title text based on transaction state
    private var navigationTitleText: String {
        vm.transactions.isEmpty
        ? "Bitcoin Monitor"
        : "UC BTC Tnxs (\(vm.transactions.count))"
    }
    
    /// Total USD value of all transactions in the queue
    private var totalValueString: String {
        let total = vm.transactions.reduce(0) { $0 + $1.usdAmount }
        return total.usdString()
    }
    
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            StatusView(statusText: vm.connectionStatusText)
        }
        
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                if !vm.transactions.isEmpty {
                    showingClearAlert = true
                }
            } label: {
                Label("Clear Queue", systemImage: "trash")
                    .symbolVariant(vm.transactions.isEmpty ? .slash : .none)
            }
            .buttonStyle(.bordered)
            .disabled(vm.transactions.isEmpty)
            .foregroundColor(vm.transactions.isEmpty ? .secondary : .red)
        }
    }
    
    
    // MARK: - Event Handlers
    
    /// Handles transaction count changes and triggers haptics when new items arrive
    private func handleTransactionCountChange(oldCount: Int, newCount: Int) {
        guard newCount > oldCount else {
            lastTransactionCount = newCount
            return
        }
        lastTransactionCount = newCount
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
