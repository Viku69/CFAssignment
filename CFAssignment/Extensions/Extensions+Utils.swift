//
//  Extensions+Utils.swift
//  CFAssignment
//
//  Created by Vikram Singh on 26/09/25.
//

import Foundation
import SwiftUI
import OSLog

// MARK: - Double Extensions

extension Double {
    /// Formats the `Double` value into a USD currency string.
    ///
    /// Example:
    /// ```swift
    /// 1234.56.usdString()       // "$1,234.56"
    /// 1234.56.usdString(0)      // "$1,235"
    /// ```
    ///
    /// - Parameter digits: Number of decimal places (default = 2).
    /// - Returns: A string formatted as USD currency.
    func usdString(_ digits: Int = 2) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = "USD"
        fmt.maximumFractionDigits = digits
        fmt.minimumFractionDigits = digits
        return fmt.string(from: NSNumber(value: self)) ?? String(format: "$%.2f", self)
    }
}


// MARK: - Date Extensions

extension Date {
    /// Formats the date in **Indian Standard Time (IST)**.
    ///
    /// Example:
    /// ```swift
    /// Date().formattedIST() // "27-09-2025 14:35:20 +0530"
    /// ```
    ///
    /// - Returns: A formatted date string in IST timezone.
    func formattedIST() -> String {
        DateFormatter.istFormatter.string(from: self)
    }
}


// MARK: - DateFormatter Extensions

extension DateFormatter {
    /// Preconfigured formatter for **IST (Asia/Kolkata)**.
    ///
    /// Format: `"dd-MM-yyyy HH:mm:ss Z"`
    static let istFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        f.dateFormat = "dd-MM-yyyy HH:mm:ss Z"
        return f
    }()
}


// MARK: - Logger Utility

struct Logger {
    /// Logs messages to the console in **DEBUG builds only**.
    ///
    /// Example:
    /// ```swift
    /// Logger.log("Transaction received:", tx)
    /// ```
    ///
    /// - Parameter items: Values to log (joined into one string).
    static func log(_ items: Any...) {
        #if DEBUG
        print("[BTCWatch]", items.map(String.init(describing:)).joined(separator: " "))
        #endif
    }
}
