import Foundation

/// Represents a stock that can be traded
struct Stock: Identifiable, Codable, Hashable {
    let id: String  // Ticker symbol (e.g., "AAPL")
    let name: String
    let currentPrice: Double
    let previousClose: Double
    let dayHigh: Double
    let dayLow: Double
    let volume: Int
    let marketCap: Double?
    let peRatio: Double?
    let sector: String?

    var symbol: String { id }

    /// Price change from previous close
    var priceChange: Double {
        currentPrice - previousClose
    }

    /// Percentage change from previous close
    var percentChange: Double {
        guard previousClose > 0 else { return 0 }
        return (priceChange / previousClose) * 100
    }

    /// Whether the stock is up today
    var isPositive: Bool {
        priceChange >= 0
    }

    /// Formatted price string
    var formattedPrice: String {
        String(format: "$%.2f", currentPrice)
    }

    /// Formatted change string with sign
    var formattedChange: String {
        let sign = priceChange >= 0 ? "+" : ""
        return String(format: "%@$%.2f", sign, priceChange)
    }

    /// Formatted percentage change
    var formattedPercent: String {
        let sign = percentChange >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, percentChange)
    }

    /// Formatted volume (e.g., "52.3M")
    var formattedVolume: String {
        formatLargeNumber(Double(volume))
    }

    /// Formatted market cap (e.g., "$2.8T")
    var formattedMarketCap: String? {
        guard let cap = marketCap else { return nil }
        return "$" + formatLargeNumber(cap)
    }

    private func formatLargeNumber(_ number: Double) -> String {
        switch number {
        case 1_000_000_000_000...:
            return String(format: "%.1fT", number / 1_000_000_000_000)
        case 1_000_000_000...:
            return String(format: "%.1fB", number / 1_000_000_000)
        case 1_000_000...:
            return String(format: "%.1fM", number / 1_000_000)
        case 1_000...:
            return String(format: "%.1fK", number / 1_000)
        default:
            return String(format: "%.0f", number)
        }
    }
}

// MARK: - Sample Data
extension Stock {
    static let sampleStocks: [Stock] = [
        Stock(
            id: "AAPL",
            name: "Apple Inc.",
            currentPrice: 178.25,
            previousClose: 176.10,
            dayHigh: 179.20,
            dayLow: 175.80,
            volume: 52_300_000,
            marketCap: 2_800_000_000_000,
            peRatio: 28.5,
            sector: "Technology"
        ),
        Stock(
            id: "GOOGL",
            name: "Alphabet Inc.",
            currentPrice: 141.80,
            previousClose: 142.50,
            dayHigh: 143.20,
            dayLow: 140.90,
            volume: 28_100_000,
            marketCap: 1_780_000_000_000,
            peRatio: 25.2,
            sector: "Technology"
        ),
        Stock(
            id: "TSLA",
            name: "Tesla Inc.",
            currentPrice: 245.30,
            previousClose: 237.90,
            dayHigh: 248.50,
            dayLow: 236.00,
            volume: 118_500_000,
            marketCap: 780_000_000_000,
            peRatio: 72.1,
            sector: "Automotive"
        ),
        Stock(
            id: "MSFT",
            name: "Microsoft Corp.",
            currentPrice: 378.00,
            previousClose: 374.50,
            dayHigh: 380.20,
            dayLow: 373.80,
            volume: 21_400_000,
            marketCap: 2_810_000_000_000,
            peRatio: 35.8,
            sector: "Technology"
        ),
        Stock(
            id: "NVDA",
            name: "NVIDIA Corp.",
            currentPrice: 485.09,
            previousClose: 465.50,
            dayHigh: 490.00,
            dayLow: 462.30,
            volume: 45_200_000,
            marketCap: 1_200_000_000_000,
            peRatio: 65.3,
            sector: "Technology"
        )
    ]
}
