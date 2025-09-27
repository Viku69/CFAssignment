# CFAssignment

**CFAssignment** is a SwiftUI-based iOS application that monitors the Bitcoin blockchain in real-time using WebSocket APIs. The app maintains a live queue of unconfirmed transactions above a specified USD threshold and displays their details in a clean, modern UI.

---

## Assignment Context

- Establishing a **WebSocket connection** to the Bitcoin blockchain.
- Streaming real-time **unconfirmed transactions**.
- Displaying a **transaction queue** of the 5 latest transactions above $100.
- Using **SwiftUI** for UI, and **async/await** for concurrency.

---

## Features

### Real-Time Bitcoin Monitoring
- Connects to [Blockchain.com WebSocket API](https://www.blockchain.com/en/api/api_websocket)
- Subscribes to **unconfirmed transactions**
- Shows connection status on-screen:
  - **Connecting…**
  - **Connected**
  - **Disconnected**

### Transaction Filtering
- Displays **only transactions above $100 USD**
- Maintains a **queue of latest 5 transactions**
- Displays for each transaction:
  - **Transaction Hash** (copyable)
  - **USD Amount** (converted from BTC via CoinGecko REST API)
  - **BTC Amount**
  - **Time of transaction** in IST (`dd-MM-yyyy HH:mm:ss +05:30`)

### Live BTC/USD Conversion
- Fetches Bitcoin prices from **CoinGecko API**
- Uses **in-memory caching** for 10 seconds for efficiency

### Interactive Transaction List
- Scrollable list of transactions
- Copy transaction ID with a tap
- Pull-to-refresh functionality

### Status Indicators
- Connection status indicators with animated pulsing

### Modern SwiftUI Design
- Flawless **card-style UI**
- Haptic feedback for interactions

---

## Architecture Overview



**Component Roles:**

- **AppCoordinator / AppEntry** – Initializes dependencies and sets up the root view.
- **TransactionQueueViewModel** – ObservableObject bridging TransactionManager and SwiftUI views.
- **TransactionManager** – Actor managing transaction queue, filtering, and USD conversion.
- **WebSocketService** – Handles bi-directional WebSocket connection, message streaming, and connection status.
- **PriceService** – Actor responsible for fetching BTC → USD price with caching.

Actors ensure **thread-safe state** and `AsyncStream` is used for streaming transactions, status updates, and errors.

---
## Architecture
```
                                   AppCoordinator / AppEntry 
                                           | 
                                           v 
                                TransactionQueueViewModel (ObservableObject) 
                                           |
                                           v
                                 TransactionManager (Manager)
                                           |
                                           v
                              WebSocketService / PriceService (Actor)

```

## Services

- **TransactionQueueViewModel**
  - Subscribes to transaction, status, and error streams
  - Updates UI automatically via `@Published` properties
- **TransactionManager**
  - Consumes WebSocket messages and maps them to `Transaction` objects
  - Computes USD values using `PriceService`
  - Filters by USD threshold
  - Maintains a maximum queue size
- **WebSocketService**
  - Manages WebSocket lifecycle (start/stop)
  - Streams incoming transaction data
  - Reconnects with exponential backoff on failure
- **PriceService**
  - Fetches BTC/USD prices
  - Implements in-memory caching for 10 seconds
  - Performs decoding off the main actor

---

## Models

- `Transaction` – Represents a Bitcoin transaction
- `UTXMessage`, `UTXDetail`, `UTXOut` – WebSocket transaction payload
- `CoinGeckoResponse` – BTC/USD price API response

---


### App Entry
```swift
@main
struct BTCWatchApp: App {
    var body: some Scene {
        WindowGroup {
            AppCoordinator.makeRootView()
        }
    }
}


