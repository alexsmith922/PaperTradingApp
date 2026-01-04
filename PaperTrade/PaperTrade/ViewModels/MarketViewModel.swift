import Foundation
import SwiftUI

/// Manages stock market data, search, and watchlist
@MainActor
class MarketViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var allStocks: [Stock] = []
    @Published var watchlist: [Stock] = []
    @Published var watchlistSymbols: Set<String> = []
    @Published var trendingStocks: [Stock] = []
    @Published var topGainers: [Stock] = []
    @Published var topLosers: [Stock] = []
    @Published var searchText: String = ""
    @Published var searchResults: [Stock] = []
    @Published var isLoading: Bool = false
    @Published var selectedStock: Stock?

    // MARK: - Categories
    let categories = ["Tech", "Health", "Finance", "Energy", "Retail", "Auto"]

    // MARK: - Computed Properties

    /// Stocks filtered by search text
    var filteredStocks: [Stock] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return allStocks.filter {
            $0.symbol.lowercased().contains(query) ||
            $0.name.lowercased().contains(query)
        }
    }

    /// Stocks grouped by sector
    var stocksBySector: [String: [Stock]] {
        Dictionary(grouping: allStocks) { $0.sector ?? "Other" }
    }

    // MARK: - Initialization

    init() {
        loadSampleData()
    }

    // MARK: - Public Methods

    /// Search for stocks matching query
    func search(_ query: String) {
        searchText = query
        if query.isEmpty {
            searchResults = []
        } else {
            searchResults = filteredStocks
        }
    }

    /// Clear search
    func clearSearch() {
        searchText = ""
        searchResults = []
    }

    /// Get stock by symbol
    func stock(for symbol: String) -> Stock? {
        allStocks.first { $0.symbol == symbol }
    }

    /// Add stock to watchlist
    func addToWatchlist(_ stock: Stock) {
        guard !watchlistSymbols.contains(stock.symbol) else { return }
        watchlistSymbols.insert(stock.symbol)
        watchlist.append(stock)
    }

    /// Add stock to watchlist by symbol
    func addToWatchlist(symbol: String) {
        guard let stock = stock(for: symbol) else { return }
        addToWatchlist(stock)
    }

    /// Remove stock from watchlist
    func removeFromWatchlist(_ stock: Stock) {
        watchlistSymbols.remove(stock.symbol)
        watchlist.removeAll { $0.symbol == stock.symbol }
    }

    /// Remove stock from watchlist by symbol
    func removeFromWatchlist(symbol: String) {
        watchlistSymbols.remove(symbol)
        watchlist.removeAll { $0.symbol == symbol }
    }

    /// Toggle watchlist status
    func toggleWatchlist(_ stock: Stock) {
        if isInWatchlist(stock) {
            removeFromWatchlist(stock)
        } else {
            addToWatchlist(stock)
        }
    }

    /// Check if stock is in watchlist
    func isInWatchlist(_ stock: Stock) -> Bool {
        watchlistSymbols.contains(stock.symbol)
    }

    /// Check if symbol is in watchlist
    func isInWatchlist(symbol: String) -> Bool {
        watchlistSymbols.contains(symbol)
    }

    /// Get stocks for a category/sector
    func stocks(for category: String) -> [Stock] {
        allStocks.filter { $0.sector == category }
    }

    /// Refresh stock prices (simulated)
    func refreshPrices() async {
        isLoading = true

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Simulate price changes
        for i in allStocks.indices {
            let changePercent = Double.random(in: -0.02...0.02)
            let newPrice = allStocks[i].currentPrice * (1 + changePercent)
            allStocks[i] = Stock(
                id: allStocks[i].id,
                name: allStocks[i].name,
                currentPrice: newPrice,
                previousClose: allStocks[i].previousClose,
                dayHigh: max(allStocks[i].dayHigh, newPrice),
                dayLow: min(allStocks[i].dayLow, newPrice),
                volume: allStocks[i].volume + Int.random(in: 10000...100000),
                marketCap: allStocks[i].marketCap,
                peRatio: allStocks[i].peRatio,
                sector: allStocks[i].sector
            )
        }

        // Update derived lists
        updateWatchlistPrices()
        updateTopMovers()

        isLoading = false
    }

    // MARK: - Private Methods

    private func loadSampleData() {
        // Load all sample stocks
        allStocks = Stock.sampleStocks + additionalSampleStocks

        // Set up default watchlist
        let defaultWatchlistSymbols = ["AAPL", "GOOGL", "TSLA"]
        for symbol in defaultWatchlistSymbols {
            if let stock = stock(for: symbol) {
                addToWatchlist(stock)
            }
        }

        // Set trending stocks
        trendingStocks = Array(allStocks.prefix(5))

        // Update top movers
        updateTopMovers()
    }

    private func updateWatchlistPrices() {
        watchlist = watchlistSymbols.compactMap { stock(for: $0) }
    }

    private func updateTopMovers() {
        let sorted = allStocks.sorted { abs($0.percentChange) > abs($1.percentChange) }
        topGainers = sorted.filter { $0.isPositive }.prefix(5).map { $0 }
        topLosers = sorted.filter { !$0.isPositive }.prefix(5).map { $0 }
    }

    /// Additional sample stocks for variety
    private var additionalSampleStocks: [Stock] {
        [
            Stock(
                id: "META",
                name: "Meta Platforms",
                currentPrice: 505.75,
                previousClose: 495.20,
                dayHigh: 510.00,
                dayLow: 493.50,
                volume: 18_200_000,
                marketCap: 1_300_000_000_000,
                peRatio: 32.5,
                sector: "Tech"
            ),
            Stock(
                id: "AMZN",
                name: "Amazon.com",
                currentPrice: 178.25,
                previousClose: 175.50,
                dayHigh: 180.00,
                dayLow: 174.20,
                volume: 35_600_000,
                marketCap: 1_850_000_000_000,
                peRatio: 42.3,
                sector: "Retail"
            ),
            Stock(
                id: "JPM",
                name: "JPMorgan Chase",
                currentPrice: 198.50,
                previousClose: 201.20,
                dayHigh: 202.00,
                dayLow: 197.30,
                volume: 12_400_000,
                marketCap: 570_000_000_000,
                peRatio: 11.8,
                sector: "Finance"
            ),
            Stock(
                id: "JNJ",
                name: "Johnson & Johnson",
                currentPrice: 156.80,
                previousClose: 155.40,
                dayHigh: 157.50,
                dayLow: 154.90,
                volume: 7_800_000,
                marketCap: 378_000_000_000,
                peRatio: 15.2,
                sector: "Health"
            ),
            Stock(
                id: "XOM",
                name: "Exxon Mobil",
                currentPrice: 104.25,
                previousClose: 106.80,
                dayHigh: 107.20,
                dayLow: 103.50,
                volume: 14_500_000,
                marketCap: 420_000_000_000,
                peRatio: 12.4,
                sector: "Energy"
            ),
            Stock(
                id: "GME",
                name: "GameStop",
                currentPrice: 24.50,
                previousClose: 21.80,
                dayHigh: 26.00,
                dayLow: 21.50,
                volume: 8_900_000,
                marketCap: 10_500_000_000,
                peRatio: nil,
                sector: "Retail"
            ),
            Stock(
                id: "AMC",
                name: "AMC Entertainment",
                currentPrice: 5.20,
                previousClose: 5.67,
                dayHigh: 5.85,
                dayLow: 5.10,
                volume: 25_600_000,
                marketCap: 2_400_000_000,
                peRatio: nil,
                sector: "Retail"
            ),
            Stock(
                id: "RIVN",
                name: "Rivian Automotive",
                currentPrice: 18.75,
                previousClose: 17.50,
                dayHigh: 19.20,
                dayLow: 17.25,
                volume: 32_100_000,
                marketCap: 18_800_000_000,
                peRatio: nil,
                sector: "Auto"
            ),
            Stock(
                id: "PFE",
                name: "Pfizer Inc.",
                currentPrice: 28.45,
                previousClose: 28.90,
                dayHigh: 29.10,
                dayLow: 28.20,
                volume: 42_300_000,
                marketCap: 160_000_000_000,
                peRatio: 12.8,
                sector: "Health"
            ),
            Stock(
                id: "BA",
                name: "Boeing Co.",
                currentPrice: 178.90,
                previousClose: 182.30,
                dayHigh: 183.50,
                dayLow: 177.60,
                volume: 5_600_000,
                marketCap: 107_000_000_000,
                peRatio: nil,
                sector: "Tech"
            )
        ]
    }
}
