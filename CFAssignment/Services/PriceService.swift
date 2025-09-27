//
//  PriceService.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import Foundation

// MARK: - Price Service

/// Service responsible for fetching the **BTC → USD price**
/// from the CoinGecko API with simple in-memory caching.
actor PriceService: IPriceService {
    
    // MARK: - Properties
    
    /// Cached value and timestamp.
    private var cached: (price: Double, timestamp: Date)?
    
    /// Cache validity (in seconds).
    private let ttl: TimeInterval = 10
    
    /// API endpoint for BTC price.
    private let url: URL? = URL(
        string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"
    )
    

    // MARK: - CoinGecko API Response

    /// Represents the JSON response from the **CoinGecko API**
    /// when fetching the current Bitcoin price.
    ///
    /// Example JSON:
    /// ```json
    /// {
    ///   "bitcoin": {
    ///     "usd": 27000.45
    ///   }
    /// }
    /// ```
    struct CoinGeckoResponse: Codable {
        
        /// Nested object containing Bitcoin price details.
        struct Price: Codable {
            /// The current Bitcoin price in USD.
            let usd: Double
        }
        
        /// Root-level key for Bitcoin pricing data.
        let bitcoin: Price
    }

    
    
    // MARK: - Public Methods
    
    /// Fetches the current BTC price in USD.
    ///
    /// - Parameter forceRefresh: If `true`, ignores cache and makes a fresh network call.
    /// - Returns: Current BTC price in USD.
    /// - Throws: `URLError` if the request fails or response is invalid.
    func fetchBTCUSD(forceRefresh: Bool = false) async throws -> Double {
        
        //  Return cached value if valid
        if !forceRefresh,
           let c = cached,
           Date().timeIntervalSince(c.timestamp) < ttl {
            return c.price
        }
        
        //  Validate URL
        guard let url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url, timeoutInterval: 10)
        request.setValue("BTCWatchApp/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        await Logger.log("Fetching BTC price from CoinGecko")
        
        do {
            //  Perform network request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Validate HTTP response
            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            //  Decode JSON response
            let decoded = try JSONDecoder().decode(CoinGeckoResponse.self, from: data)
            cached = (decoded.bitcoin.usd, Date())
            
            return decoded.bitcoin.usd
            
        } catch {
            //  Retry once on transient failure
            await Logger.log("BTC price fetch failed, retrying...", error)
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            return try await fetchBTCUSD(forceRefresh: true)
        }
    }
}
