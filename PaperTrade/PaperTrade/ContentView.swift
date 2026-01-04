import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
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
        .tint(Color.theme.primary)
    }
}

#Preview {
    ContentView()
}
