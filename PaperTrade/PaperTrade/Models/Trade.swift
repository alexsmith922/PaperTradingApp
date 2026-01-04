import Foundation

/// Represents a completed trade (buy or sell)
struct Trade: Identifiable, Codable {
    let id: UUID
    let symbol: String
    let name: String
    let type: TradeType
    let shares: Double
    let pricePerShare: Double
    let timestamp: Date

    init(symbol: String, name: String, type: TradeType, shares: Double, pricePerShare: Double, timestamp: Date = Date()) {
        self.id = UUID()
        self.symbol = symbol
        self.name = name
        self.type = type
        self.shares = shares
        self.pricePerShare = pricePerShare
        self.timestamp = timestamp
    }

    /// Total value of the trade
    var totalValue: Double {
        shares * pricePerShare
    }

    /// Formatted total value
    var formattedTotal: String {
        String(format: "$%.2f", totalValue)
    }

    /// Formatted price per share
    var formattedPrice: String {
        String(format: "$%.2f", pricePerShare)
    }

    /// Formatted shares
    var formattedShares: String {
        if shares == floor(shares) {
            return String(format: "%.0f shares", shares)
        } else {
            return String(format: "%.2f shares", shares)
        }
    }

    /// Formatted timestamp for display
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }

    /// Formatted date for grouping
    var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(timestamp) {
            return "Today"
        } else if calendar.isDateInYesterday(timestamp) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: timestamp)
        }
    }

    /// Action text (Bought/Sold)
    var actionText: String {
        type == .buy ? "Bought" : "Sold"
    }
}

/// Type of trade
enum TradeType: String, Codable {
    case buy
    case sell

    var isBuy: Bool {
        self == .buy
    }
}

// MARK: - Sample Data
extension Trade {
    static let sampleTrades: [Trade] = [
        Trade(
            symbol: "AAPL",
            name: "Apple Inc.",
            type: .buy,
            shares: 5,
            pricePerShare: 178.25,
            timestamp: Date()
        ),
        Trade(
            symbol: "TSLA",
            name: "Tesla Inc.",
            type: .sell,
            shares: 2,
            pricePerShare: 242.10,
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ),
        Trade(
            symbol: "NVDA",
            name: "NVIDIA Corp.",
            type: .buy,
            shares: 3,
            pricePerShare: 480.50,
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ),
        Trade(
            symbol: "GOOGL",
            name: "Alphabet Inc.",
            type: .buy,
            shares: 5,
            pricePerShare: 141.80,
            timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        )
    ]
}
