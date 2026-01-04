import Foundation

/// Represents a user's investment portfolio
struct Portfolio: Codable {
    var holdings: [Holding]
    var cashBalance: Double

    /// Total value of all holdings at current prices
    var holdingsValue: Double {
        holdings.reduce(0) { $0 + $1.currentValue }
    }

    /// Total portfolio value (holdings + cash)
    var totalValue: Double {
        holdingsValue + cashBalance
    }

    /// Total cost basis of all holdings
    var totalCostBasis: Double {
        holdings.reduce(0) { $0 + $1.costBasis }
    }

    /// Total gain/loss in dollars
    var totalGainLoss: Double {
        holdingsValue - totalCostBasis
    }

    /// Total gain/loss percentage
    var totalGainLossPercent: Double {
        guard totalCostBasis > 0 else { return 0 }
        return (totalGainLoss / totalCostBasis) * 100
    }

    /// Whether portfolio is overall positive
    var isPositive: Bool {
        totalGainLoss >= 0
    }

    /// Formatted total value
    var formattedTotalValue: String {
        String(format: "$%.2f", totalValue)
    }

    /// Formatted gain/loss
    var formattedGainLoss: String {
        let sign = totalGainLoss >= 0 ? "+" : ""
        return String(format: "%@$%.2f", sign, totalGainLoss)
    }

    /// Formatted cash balance
    var formattedCashBalance: String {
        String(format: "$%.2f", cashBalance)
    }
}

/// Represents a single stock holding in the portfolio
struct Holding: Identifiable, Codable {
    let id: UUID
    let symbol: String
    let name: String
    var shares: Double
    var averageCost: Double
    var currentPrice: Double

    init(symbol: String, name: String, shares: Double, averageCost: Double, currentPrice: Double) {
        self.id = UUID()
        self.symbol = symbol
        self.name = name
        self.shares = shares
        self.averageCost = averageCost
        self.currentPrice = currentPrice
    }

    /// Total cost basis for this holding
    var costBasis: Double {
        shares * averageCost
    }

    /// Current market value
    var currentValue: Double {
        shares * currentPrice
    }

    /// Gain or loss in dollars
    var gainLoss: Double {
        currentValue - costBasis
    }

    /// Gain or loss percentage
    var gainLossPercent: Double {
        guard costBasis > 0 else { return 0 }
        return (gainLoss / costBasis) * 100
    }

    /// Whether this holding is profitable
    var isPositive: Bool {
        gainLoss >= 0
    }

    /// Formatted current value
    var formattedValue: String {
        String(format: "$%.2f", currentValue)
    }

    /// Formatted gain/loss
    var formattedGainLoss: String {
        let sign = gainLoss >= 0 ? "+" : ""
        return String(format: "%@$%.2f", sign, gainLoss)
    }

    /// Formatted gain/loss percentage
    var formattedGainLossPercent: String {
        let sign = gainLossPercent >= 0 ? "+" : ""
        return String(format: "%@%.1f%%", sign, gainLossPercent)
    }

    /// Formatted shares count
    var formattedShares: String {
        if shares == floor(shares) {
            return String(format: "%.0f shares", shares)
        } else {
            return String(format: "%.2f shares", shares)
        }
    }
}

// MARK: - Sample Data
extension Portfolio {
    static let sample = Portfolio(
        holdings: [
            Holding(symbol: "AAPL", name: "Apple Inc.", shares: 10, averageCost: 165.75, currentPrice: 178.25),
            Holding(symbol: "GOOGL", name: "Alphabet Inc.", shares: 5, averageCost: 148.90, currentPrice: 141.80),
            Holding(symbol: "MSFT", name: "Microsoft Corp.", shares: 8, averageCost: 355.50, currentPrice: 378.00),
            Holding(symbol: "TSLA", name: "Tesla Inc.", shares: 3, averageCost: 230.00, currentPrice: 245.30)
        ],
        cashBalance: 2500.00
    )
}
