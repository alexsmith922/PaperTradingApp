import Foundation
import SwiftUI

/// Manages the buy/sell trade flow UI
@MainActor
class TradeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var stock: Stock?
    @Published var tradeType: TradeType = .buy
    @Published var sharesInput: String = ""
    @Published var isShowingTradeSheet: Bool = false
    @Published var isProcessing: Bool = false
    @Published var showConfirmation: Bool = false
    @Published var lastTradeResult: TradeResult?
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private weak var portfolioViewModel: PortfolioViewModel?

    // MARK: - Computed Properties

    /// Number of shares as Double
    var shares: Double {
        Double(sharesInput) ?? 0
    }

    /// Whether input is valid
    var isValidInput: Bool {
        shares > 0
    }

    /// Total cost/proceeds of the trade
    var totalValue: Double {
        guard let stock = stock else { return 0 }
        return stock.currentPrice * shares
    }

    /// Formatted total value
    var formattedTotalValue: String {
        String(format: "$%.2f", totalValue)
    }

    /// Current cash balance
    var cashBalance: Double {
        portfolioViewModel?.cashBalance ?? 0
    }

    /// Formatted cash balance
    var formattedCashBalance: String {
        String(format: "$%.2f", cashBalance)
    }

    /// Shares currently owned of selected stock
    var sharesOwned: Double {
        guard let stock = stock else { return 0 }
        return portfolioViewModel?.sharesOwned(for: stock.symbol) ?? 0
    }

    /// Whether user owns any shares
    var hasPosition: Bool {
        sharesOwned > 0
    }

    /// Maximum shares user can buy with current cash
    var maxBuyableShares: Double {
        guard let stock = stock, stock.currentPrice > 0 else { return 0 }
        return floor(cashBalance / stock.currentPrice * 100) / 100
    }

    /// Whether user can afford the buy
    var canAffordBuy: Bool {
        totalValue <= cashBalance
    }

    /// Whether user has enough shares to sell
    var canSell: Bool {
        shares <= sharesOwned
    }

    /// Whether trade can be executed
    var canExecuteTrade: Bool {
        guard isValidInput else { return false }
        if tradeType == .buy {
            return canAffordBuy
        } else {
            return canSell
        }
    }

    /// Validation message for current input
    var validationMessage: String? {
        guard isValidInput else { return nil }

        if tradeType == .buy && !canAffordBuy {
            let shortfall = totalValue - cashBalance
            return "You need $\(String(format: "%.2f", shortfall)) more"
        }

        if tradeType == .sell && !canSell {
            return "You only own \(String(format: "%.2f", sharesOwned)) shares"
        }

        return nil
    }

    /// Summary text for the trade
    var tradeSummary: String {
        guard let stock = stock, isValidInput else { return "" }
        let action = tradeType == .buy ? "Buy" : "Sell"
        return "\(action) \(String(format: "%.2f", shares)) shares of \(stock.symbol) for \(formattedTotalValue)"
    }

    // MARK: - Initialization

    init() {}

    /// Configure with dependencies
    func configure(with portfolioViewModel: PortfolioViewModel) {
        self.portfolioViewModel = portfolioViewModel
    }

    // MARK: - Public Methods

    /// Open trade sheet for a stock
    func openTradeSheet(for stock: Stock, type: TradeType = .buy) {
        self.stock = stock
        self.tradeType = type
        self.sharesInput = ""
        self.errorMessage = nil
        self.lastTradeResult = nil
        self.isShowingTradeSheet = true
    }

    /// Close trade sheet
    func closeTradeSheet() {
        isShowingTradeSheet = false
        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.reset()
        }
    }

    /// Switch between buy and sell
    func setTradeType(_ type: TradeType) {
        tradeType = type
        errorMessage = nil
    }

    /// Set shares to maximum available
    func setMaxShares() {
        if tradeType == .buy {
            sharesInput = String(format: "%.2f", maxBuyableShares)
        } else {
            sharesInput = String(format: "%.2f", sharesOwned)
        }
    }

    /// Execute the trade
    func executeTrade() {
        guard let stock = stock,
              let portfolioVM = portfolioViewModel,
              isValidInput else {
            return
        }

        isProcessing = true
        errorMessage = nil

        // Simulate brief processing time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            let result: TradeResult
            if self.tradeType == .buy {
                result = portfolioVM.buy(stock: stock, shares: self.shares)
            } else {
                result = portfolioVM.sell(stock: stock, shares: self.shares)
            }

            self.lastTradeResult = result
            self.isProcessing = false

            if result.isSuccess {
                self.showConfirmation = true
                // Auto-close after success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.closeTradeSheet()
                }
            } else {
                self.errorMessage = result.errorMessage
            }
        }
    }

    /// Preset share amounts for quick selection
    func quickSelectShares(_ amount: QuickSelectAmount) {
        switch amount {
        case .one:
            sharesInput = "1"
        case .five:
            sharesInput = "5"
        case .ten:
            sharesInput = "10"
        case .max:
            setMaxShares()
        case .custom(let shares):
            sharesInput = String(format: "%.2f", shares)
        }
    }

    // MARK: - Private Methods

    private func reset() {
        stock = nil
        sharesInput = ""
        tradeType = .buy
        errorMessage = nil
        lastTradeResult = nil
        showConfirmation = false
    }
}

// MARK: - Quick Select Amount

enum QuickSelectAmount {
    case one
    case five
    case ten
    case max
    case custom(Double)

    var label: String {
        switch self {
        case .one: return "1"
        case .five: return "5"
        case .ten: return "10"
        case .max: return "MAX"
        case .custom(let amount): return String(format: "%.0f", amount)
        }
    }
}
