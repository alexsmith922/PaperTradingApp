import Foundation
import SwiftUI

/// Central app state that manages all ViewModels
@MainActor
class AppState: ObservableObject {
    // MARK: - ViewModels
    @Published var portfolio: PortfolioViewModel
    @Published var market: MarketViewModel
    @Published var trade: TradeViewModel

    // MARK: - Services
    let dataService: DataService?

    // MARK: - App State
    @Published var selectedTab: Int = 0
    @Published var isOnboarded: Bool = true  // Set to false for onboarding flow

    // MARK: - Initialization

    /// Initialize with DataService for persistence
    init(dataService: DataService) {
        self.dataService = dataService
        self.portfolio = PortfolioViewModel(dataService: dataService)
        self.market = MarketViewModel(dataService: dataService)
        self.trade = TradeViewModel()

        // Configure dependencies
        self.trade.configure(with: portfolio)

        // Sync prices between market and portfolio
        syncPrices()
    }

    /// Initialize without persistence (for previews)
    init() {
        self.dataService = nil
        self.portfolio = PortfolioViewModel()
        self.market = MarketViewModel()
        self.trade = TradeViewModel()

        // Configure dependencies
        self.trade.configure(with: portfolio)

        // Sync prices between market and portfolio
        syncPrices()
    }

    // MARK: - Public Methods

    /// Navigate to a specific tab
    func navigateToTab(_ tab: AppTab) {
        selectedTab = tab.rawValue
    }

    /// Open stock detail and optionally start a trade
    func openStock(_ stock: Stock, andTrade: Bool = false) {
        market.selectedStock = stock
        if andTrade {
            trade.openTradeSheet(for: stock)
        }
    }

    /// Refresh all data
    func refreshAll() async {
        await market.refreshPrices()
        syncPrices()
    }

    // MARK: - Private Methods

    private func syncPrices() {
        portfolio.updatePrices(from: market.allStocks)
    }
}

// MARK: - App Tabs

enum AppTab: Int, CaseIterable {
    case dashboard = 0
    case explore = 1
    case portfolio = 2
    case history = 3
    case learn = 4

    var title: String {
        switch self {
        case .dashboard: return "Home"
        case .explore: return "Explore"
        case .portfolio: return "Portfolio"
        case .history: return "History"
        case .learn: return "Learn"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .explore: return "magnifyingglass"
        case .portfolio: return "chart.pie.fill"
        case .history: return "clock.fill"
        case .learn: return "lightbulb.fill"
        }
    }
}
