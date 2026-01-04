import Foundation
import SwiftUI

/// Manages the user's portfolio, holdings, and trade execution
@MainActor
class PortfolioViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var holdings: [Holding] = []
    @Published var cashBalance: Double = User.defaultStartingBalance
    @Published var tradeHistory: [Trade] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Computed Properties

    /// Total value of all stock holdings
    var holdingsValue: Double {
        holdings.reduce(0) { $0 + $1.currentValue }
    }

    /// Total portfolio value (stocks + cash)
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

    /// Total gain/loss as a percentage
    var totalGainLossPercent: Double {
        guard totalCostBasis > 0 else { return 0 }
        return (totalGainLoss / totalCostBasis) * 100
    }

    /// All-time return (vs starting balance)
    var allTimeReturn: Double {
        totalValue - User.defaultStartingBalance
    }

    /// All-time return percentage
    var allTimeReturnPercent: Double {
        (allTimeReturn / User.defaultStartingBalance) * 100
    }

    /// Whether portfolio is up overall
    var isPositive: Bool {
        allTimeReturn >= 0
    }

    // MARK: - Formatted Strings

    var formattedTotalValue: String {
        formatCurrency(totalValue)
    }

    var formattedCashBalance: String {
        formatCurrency(cashBalance)
    }

    var formattedHoldingsValue: String {
        formatCurrency(holdingsValue)
    }

    var formattedAllTimeReturn: String {
        let sign = allTimeReturn >= 0 ? "+" : ""
        return "\(sign)\(formatCurrency(allTimeReturn))"
    }

    var formattedAllTimeReturnPercent: String {
        let sign = allTimeReturnPercent >= 0 ? "+" : ""
        return String(format: "%@%.1f%%", sign, allTimeReturnPercent)
    }

    // MARK: - Initialization

    init() {
        loadSampleData()
    }

    // MARK: - Trading Methods

    /// Execute a buy order
    /// - Parameters:
    ///   - stock: The stock to buy
    ///   - shares: Number of shares to buy
    /// - Returns: Result indicating success or failure reason
    func buy(stock: Stock, shares: Double) -> TradeResult {
        let totalCost = stock.currentPrice * shares

        // Check if user has enough cash
        guard totalCost <= cashBalance else {
            let maxShares = floor(cashBalance / stock.currentPrice * 100) / 100
            return .insufficientFunds(available: cashBalance, needed: totalCost, maxShares: maxShares)
        }

        // Check for valid share count
        guard shares > 0 else {
            return .invalidAmount
        }

        // Execute the trade
        cashBalance -= totalCost

        // Update or create holding
        if let index = holdings.firstIndex(where: { $0.symbol == stock.symbol }) {
            // Update existing holding with new average cost
            var holding = holdings[index]
            let totalShares = holding.shares + shares
            let totalCostBasis = holding.costBasis + totalCost
            holding.averageCost = totalCostBasis / totalShares
            holding.shares = totalShares
            holding.currentPrice = stock.currentPrice
            holdings[index] = holding
        } else {
            // Create new holding
            let holding = Holding(
                symbol: stock.symbol,
                name: stock.name,
                shares: shares,
                averageCost: stock.currentPrice,
                currentPrice: stock.currentPrice
            )
            holdings.append(holding)
        }

        // Record the trade
        let trade = Trade(
            symbol: stock.symbol,
            name: stock.name,
            type: .buy,
            shares: shares,
            pricePerShare: stock.currentPrice
        )
        tradeHistory.insert(trade, at: 0)

        return .success(trade: trade)
    }

    /// Execute a sell order
    /// - Parameters:
    ///   - stock: The stock to sell
    ///   - shares: Number of shares to sell
    /// - Returns: Result indicating success or failure reason
    func sell(stock: Stock, shares: Double) -> TradeResult {
        // Find the holding
        guard let index = holdings.firstIndex(where: { $0.symbol == stock.symbol }) else {
            return .noPosition
        }

        let holding = holdings[index]

        // Check if user has enough shares
        guard shares <= holding.shares else {
            return .insufficientShares(owned: holding.shares, requested: shares)
        }

        // Check for valid share count
        guard shares > 0 else {
            return .invalidAmount
        }

        // Execute the trade
        let totalProceeds = stock.currentPrice * shares
        cashBalance += totalProceeds

        // Update or remove holding
        if shares == holding.shares {
            holdings.remove(at: index)
        } else {
            var updatedHolding = holding
            updatedHolding.shares -= shares
            updatedHolding.currentPrice = stock.currentPrice
            holdings[index] = updatedHolding
        }

        // Record the trade
        let trade = Trade(
            symbol: stock.symbol,
            name: stock.name,
            type: .sell,
            shares: shares,
            pricePerShare: stock.currentPrice
        )
        tradeHistory.insert(trade, at: 0)

        return .success(trade: trade)
    }

    /// Get current holding for a stock (if any)
    func holding(for symbol: String) -> Holding? {
        holdings.first { $0.symbol == symbol }
    }

    /// Get number of shares owned for a stock
    func sharesOwned(for symbol: String) -> Double {
        holding(for: symbol)?.shares ?? 0
    }

    /// Update current prices for all holdings
    func updatePrices(from stocks: [Stock]) {
        for i in holdings.indices {
            if let stock = stocks.first(where: { $0.symbol == holdings[i].symbol }) {
                holdings[i].currentPrice = stock.currentPrice
            }
        }
    }

    /// Get trades grouped by date
    var tradesByDate: [(date: String, trades: [Trade])] {
        let grouped = Dictionary(grouping: tradeHistory) { $0.formattedDate }
        let sorted = grouped.sorted { first, second in
            // Sort by actual date, most recent first
            guard let firstTrade = first.value.first,
                  let secondTrade = second.value.first else {
                return false
            }
            return firstTrade.timestamp > secondTrade.timestamp
        }
        return sorted.map { (date: $0.key, trades: $0.value) }
    }

    // MARK: - Private Methods

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func loadSampleData() {
        // Start with sample portfolio for demo purposes
        let samplePortfolio = Portfolio.sample
        holdings = samplePortfolio.holdings
        cashBalance = samplePortfolio.cashBalance
        tradeHistory = Trade.sampleTrades
    }

    /// Reset portfolio to starting state
    func resetPortfolio() {
        holdings = []
        cashBalance = User.defaultStartingBalance
        tradeHistory = []
    }
}

// MARK: - Trade Result

/// Result of a trade attempt
enum TradeResult {
    case success(trade: Trade)
    case insufficientFunds(available: Double, needed: Double, maxShares: Double)
    case insufficientShares(owned: Double, requested: Double)
    case noPosition
    case invalidAmount

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .insufficientFunds(let available, let needed, let maxShares):
            return "Not enough cash. You have \(formatCurrency(available)) but need \(formatCurrency(needed)). You can buy up to \(String(format: "%.2f", maxShares)) shares."
        case .insufficientShares(let owned, let requested):
            return "You only own \(String(format: "%.2f", owned)) shares but tried to sell \(String(format: "%.2f", requested))."
        case .noPosition:
            return "You don't own any shares of this stock."
        case .invalidAmount:
            return "Please enter a valid number of shares."
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }
}
