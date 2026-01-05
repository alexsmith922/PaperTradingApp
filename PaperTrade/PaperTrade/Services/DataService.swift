import Foundation
import SwiftData

/// Service for managing persisted data with SwiftData
@MainActor
class DataService: ObservableObject {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - User Account

    /// Get or create the user account
    func getOrCreateUserAccount() -> UserAccount {
        let descriptor = FetchDescriptor<UserAccount>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        // Create new account with default starting balance
        let newAccount = UserAccount(
            cashBalance: 10_000.00,
            holdings: [],
            trades: [],
            watchlistItems: defaultWatchlist()
        )
        modelContext.insert(newAccount)
        save()
        return newAccount
    }

    private func defaultWatchlist() -> [WatchlistItem] {
        ["AAPL", "GOOGL", "TSLA"].map { WatchlistItem(symbol: $0) }
    }

    // MARK: - Holdings

    /// Add or update a holding after a buy
    func addOrUpdateHolding(
        account: UserAccount,
        symbol: String,
        name: String,
        shares: Double,
        price: Double
    ) {
        if let existing = account.holdings.first(where: { $0.symbol == symbol }) {
            // Update existing holding with new average cost
            let totalShares = existing.shares + shares
            let totalCost = (existing.shares * existing.averageCost) + (shares * price)
            existing.averageCost = totalCost / totalShares
            existing.shares = totalShares
        } else {
            // Create new holding
            let holding = PersistedHolding(
                symbol: symbol,
                name: name,
                shares: shares,
                averageCost: price
            )
            account.holdings.append(holding)
        }
        save()
    }

    /// Reduce or remove a holding after a sell
    func reduceHolding(
        account: UserAccount,
        symbol: String,
        shares: Double
    ) {
        guard let holding = account.holdings.first(where: { $0.symbol == symbol }) else {
            return
        }

        if shares >= holding.shares {
            // Remove entire holding
            account.holdings.removeAll { $0.symbol == symbol }
            modelContext.delete(holding)
        } else {
            // Reduce shares
            holding.shares -= shares
        }
        save()
    }

    // MARK: - Trades

    /// Record a trade
    func recordTrade(
        account: UserAccount,
        symbol: String,
        name: String,
        type: TradeType,
        shares: Double,
        price: Double
    ) {
        let trade = PersistedTrade(
            symbol: symbol,
            name: name,
            tradeType: type == .buy ? "buy" : "sell",
            shares: shares,
            pricePerShare: price
        )
        account.trades.append(trade)
        save()
    }

    // MARK: - Cash Balance

    /// Update cash balance
    func updateCashBalance(account: UserAccount, newBalance: Double) {
        account.cashBalance = newBalance
        save()
    }

    // MARK: - Watchlist

    /// Add symbol to watchlist
    func addToWatchlist(account: UserAccount, symbol: String) {
        guard !account.watchlistItems.contains(where: { $0.symbol == symbol }) else {
            return
        }
        let item = WatchlistItem(symbol: symbol)
        account.watchlistItems.append(item)
        save()
    }

    /// Remove symbol from watchlist
    func removeFromWatchlist(account: UserAccount, symbol: String) {
        if let item = account.watchlistItems.first(where: { $0.symbol == symbol }) {
            account.watchlistItems.removeAll { $0.symbol == symbol }
            modelContext.delete(item)
            save()
        }
    }

    /// Check if symbol is in watchlist
    func isInWatchlist(account: UserAccount, symbol: String) -> Bool {
        account.watchlistItems.contains { $0.symbol == symbol }
    }

    // MARK: - Reset

    /// Reset account to starting state (for testing)
    func resetAccount(account: UserAccount) {
        // Remove all holdings
        for holding in account.holdings {
            modelContext.delete(holding)
        }
        account.holdings.removeAll()

        // Remove all trades
        for trade in account.trades {
            modelContext.delete(trade)
        }
        account.trades.removeAll()

        // Reset cash
        account.cashBalance = 10_000.00

        // Reset watchlist to defaults
        for item in account.watchlistItems {
            modelContext.delete(item)
        }
        account.watchlistItems = defaultWatchlist()

        save()
    }

    // MARK: - Persistence

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
