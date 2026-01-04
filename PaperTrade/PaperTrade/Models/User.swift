import Foundation

/// Represents the app user and their account
struct User: Codable {
    let id: UUID
    var displayName: String
    var portfolio: Portfolio
    var tradeHistory: [Trade]
    var watchlist: [String]  // Stock symbols
    var createdAt: Date

    /// Starting balance for new users
    static let defaultStartingBalance: Double = 10_000.00

    init(displayName: String = "Trader") {
        self.id = UUID()
        self.displayName = displayName
        self.portfolio = Portfolio(holdings: [], cashBalance: User.defaultStartingBalance)
        self.tradeHistory = []
        self.watchlist = ["AAPL", "GOOGL", "TSLA"]  // Default watchlist
        self.createdAt = Date()
    }

    /// Total account value (portfolio total)
    var accountValue: Double {
        portfolio.totalValue
    }

    /// All-time return in dollars
    var allTimeReturn: Double {
        portfolio.totalValue - User.defaultStartingBalance
    }

    /// All-time return percentage
    var allTimeReturnPercent: Double {
        (allTimeReturn / User.defaultStartingBalance) * 100
    }

    /// Whether overall return is positive
    var isPositiveReturn: Bool {
        allTimeReturn >= 0
    }

    /// Formatted account value
    var formattedAccountValue: String {
        String(format: "$%.2f", accountValue)
    }

    /// Formatted all-time return
    var formattedAllTimeReturn: String {
        let sign = allTimeReturn >= 0 ? "+" : ""
        return String(format: "%@$%.2f", sign, allTimeReturn)
    }

    /// Formatted all-time return percentage
    var formattedAllTimeReturnPercent: String {
        let sign = allTimeReturnPercent >= 0 ? "+" : ""
        return String(format: "%@%.1f%%", sign, allTimeReturnPercent)
    }

    /// Check if a stock is in watchlist
    func isInWatchlist(_ symbol: String) -> Bool {
        watchlist.contains(symbol)
    }

    /// Add stock to watchlist
    mutating func addToWatchlist(_ symbol: String) {
        if !watchlist.contains(symbol) {
            watchlist.append(symbol)
        }
    }

    /// Remove stock from watchlist
    mutating func removeFromWatchlist(_ symbol: String) {
        watchlist.removeAll { $0 == symbol }
    }
}

// MARK: - Sample Data
extension User {
    static let sample: User = {
        var user = User(displayName: "Demo Trader")
        user.portfolio = Portfolio.sample
        user.tradeHistory = Trade.sampleTrades
        user.watchlist = ["AAPL", "GOOGL", "TSLA", "NVDA", "META"]
        return user
    }()
}
