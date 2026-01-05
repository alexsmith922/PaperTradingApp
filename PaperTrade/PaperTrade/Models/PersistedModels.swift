import Foundation
import SwiftData

/// Persisted user account data
@Model
final class UserAccount {
    var id: UUID
    var cashBalance: Double
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var holdings: [PersistedHolding]

    @Relationship(deleteRule: .cascade)
    var trades: [PersistedTrade]

    @Relationship(deleteRule: .cascade)
    var watchlistItems: [WatchlistItem]

    init(
        id: UUID = UUID(),
        cashBalance: Double = 10_000.00,
        createdAt: Date = Date(),
        holdings: [PersistedHolding] = [],
        trades: [PersistedTrade] = [],
        watchlistItems: [WatchlistItem] = []
    ) {
        self.id = id
        self.cashBalance = cashBalance
        self.createdAt = createdAt
        self.holdings = holdings
        self.trades = trades
        self.watchlistItems = watchlistItems
    }
}

/// Persisted stock holding
@Model
final class PersistedHolding {
    var id: UUID
    var symbol: String
    var name: String
    var shares: Double
    var averageCost: Double
    var purchaseDate: Date

    init(
        id: UUID = UUID(),
        symbol: String,
        name: String,
        shares: Double,
        averageCost: Double,
        purchaseDate: Date = Date()
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.shares = shares
        self.averageCost = averageCost
        self.purchaseDate = purchaseDate
    }

    /// Convert to view model Holding struct
    func toHolding(currentPrice: Double) -> Holding {
        Holding(
            symbol: symbol,
            name: name,
            shares: shares,
            averageCost: averageCost,
            currentPrice: currentPrice
        )
    }
}

/// Persisted trade record
@Model
final class PersistedTrade {
    var id: UUID
    var symbol: String
    var name: String
    var tradeType: String // "buy" or "sell"
    var shares: Double
    var pricePerShare: Double
    var timestamp: Date

    init(
        id: UUID = UUID(),
        symbol: String,
        name: String,
        tradeType: String,
        shares: Double,
        pricePerShare: Double,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.tradeType = tradeType
        self.shares = shares
        self.pricePerShare = pricePerShare
        self.timestamp = timestamp
    }

    /// Convert to view model Trade struct
    func toTrade() -> Trade {
        Trade(
            symbol: symbol,
            name: name,
            type: tradeType == "buy" ? .buy : .sell,
            shares: shares,
            pricePerShare: pricePerShare,
            timestamp: timestamp
        )
    }

    /// Create from Trade struct
    static func from(_ trade: Trade) -> PersistedTrade {
        PersistedTrade(
            id: trade.id,
            symbol: trade.symbol,
            name: trade.name,
            tradeType: trade.type == .buy ? "buy" : "sell",
            shares: trade.shares,
            pricePerShare: trade.pricePerShare,
            timestamp: trade.timestamp
        )
    }
}

/// Persisted watchlist item
@Model
final class WatchlistItem {
    var id: UUID
    var symbol: String
    var addedAt: Date

    init(id: UUID = UUID(), symbol: String, addedAt: Date = Date()) {
        self.id = id
        self.symbol = symbol
        self.addedAt = addedAt
    }
}
