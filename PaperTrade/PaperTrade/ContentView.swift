import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(1)

            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "chart.pie.fill")
                }
                .tag(2)

            TradeHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(3)

            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "lightbulb.fill")
                }
                .tag(4)
        }
        .tint(Color.primaryCoral)
        .sheet(isPresented: $tradeVM.isShowingTradeSheet) {
            if let stock = tradeVM.stock {
                TradeSheetView(stock: stock)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(PortfolioViewModel())
        .environmentObject(MarketViewModel())
        .environmentObject(TradeViewModel())
}
