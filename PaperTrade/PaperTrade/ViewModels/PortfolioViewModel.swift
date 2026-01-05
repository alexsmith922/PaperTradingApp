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

    // MARK: - Persistence
    private var dataService: DataService?
    private var userAccount: UserAccount?

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

    /// Initialize with DataService for persistence
    init(dataService: DataService) {
        self.dataService = dataService
        loadFromPersistence()
    }

    /// Initialize without persistence (for previews)
    init() {
        self.dataService = nil
        loadSampleData()
    }

    // MARK: - Trading Methods

    /// Execute a buy order
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

        // Persist changes
        persistBuy(stock: stock, shares: shares, price: stock.currentPrice)

        return .success(trade: trade)
    }

    /// Execute a sell order
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

        // Persist changes
        persistSell(stock: stock, shares: shares, price: stock.currentPrice)

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
            guard let firstTrade = first.value.first,
                  let secondTrade = second.value.first else {
                return false
            }
            return firstTrade.timestamp > secondTrade.timestamp
        }
        return sorted.map { (date: $0.key, trades: $0.value) }
    }

    /// Reset portfolio to starting state
    func resetPortfolio() {
        holdings = []
        cashBalance = User.defaultStartingBalance
        tradeHistory = []

        // Persist reset
        if let account = userAccount {
            dataService?.resetAccount(account: account)
        }
    }

    // MARK: - Persistence Methods

    private func loadFromPersistence() {
        guard let dataService = dataService else {
            loadSampleData()
            return
        }

        let account = dataService.getOrCreateUserAccount()
        self.userAccount = account

        // Load cash balance
        cashBalance = account.cashBalance

        // Load holdings (we'll need to fetch current prices separately)
        holdings = account.holdings.map { persisted in
            Holding(
                symbol: persisted.symbol,
                name: persisted.name,
                shares: persisted.shares,
                averageCost: persisted.averageCost,
                currentPrice: persisted.averageCost // Will be updated with real prices
            )
        }

        // Load trade history
        tradeHistory = account.trades
            .map { $0.toTrade() }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private func persistBuy(stock: Stock, shares: Double, price: Double) {
        guard let dataService = dataService, let account = userAccount else { return }

        // Update cash balance
        dataService.updateCashBalance(account: account, newBalance: cashBalance)

        // Add/update holding
        dataService.addOrUpdateHolding(
            account: account,
            symbol: stock.symbol,
            name: stock.name,
            shares: shares,
            price: price
        )

        // Record trade
        dataService.recordTrade(
            account: account,
            symbol: stock.symbol,
            name: stock.name,
            type: .buy,
            shares: shares,
            price: price
        )
    }

    private func persistSell(stock: Stock, shares: Double, price: Double) {
        guard let dataService = dataService, let account = userAccount else { return }

        // Update cash balance
        dataService.updateCashBalance(account: account, newBalance: cashBalance)

        // Reduce holding
        dataService.reduceHolding(
            account: account,
            symbol: stock.symbol,
            shares: shares
        )

        // Record trade
        dataService.recordTrade(
            account: account,
            symbol: stock.symbol,
            name: stock.name,
            type: .sell,
            shares: shares,
            price: price
        )
    }

    // MARK: - Private Methods

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func loadSampleData() {
        // Start with sample portfolio for demo/preview purposes
        let samplePortfolio = Portfolio.sample
        holdings = samplePortfolio.holdings
        cashBalance = samplePortfolio.cashBalance
        tradeHistory = Trade.sampleTrades
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
