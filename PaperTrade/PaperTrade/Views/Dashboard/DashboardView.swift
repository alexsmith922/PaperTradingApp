import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Card
                    BalanceCardView()

                    // Quick Stats
                    QuickStatsView()

                    // Watchlist Preview
                    WatchlistPreviewView()
                }
                .padding()
            }
            .background(Color.cardGray)
            .navigationTitle("Home")
            .refreshable {
                await marketVM.refreshPrices()
                portfolioVM.updatePrices(from: marketVM.allStocks)
            }
        }
    }
}

// MARK: - Balance Card
struct BalanceCardView: View {
    @EnvironmentObject var portfolioVM: PortfolioViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Balance")
                .font(.subheadline)
                .foregroundColor(Color.textMedium)

            Text(portfolioVM.formattedTotalValue)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.textDark)

            HStack {
                Image(systemName: portfolioVM.isPositive ? "arrow.up.right" : "arrow.down.right")
                Text("\(portfolioVM.formattedAllTimeReturn) (\(portfolioVM.formattedAllTimeReturnPercent))")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(portfolioVM.isPositive ? Color.gainsGreen : Color.lossesRed)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

// MARK: - Quick Stats
struct QuickStatsView: View {
    @EnvironmentObject var portfolioVM: PortfolioViewModel

    var body: some View {
        HStack(spacing: 12) {
            StatBox(title: "Invested", value: portfolioVM.formattedHoldingsValue, color: Color.primaryCoral)
            StatBox(title: "Cash", value: portfolioVM.formattedCashBalance, color: Color.secondaryTeal)
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color.textMedium)
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundColor(Color.textDark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Watchlist Preview
struct WatchlistPreviewView: View {
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Watchlist")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    WatchlistFullView()
                }
                .font(.subheadline)
                .foregroundColor(Color.primaryCoral)
            }

            if marketVM.watchlist.isEmpty {
                Text("No stocks in watchlist yet")
                    .font(.subheadline)
                    .foregroundColor(Color.textMedium)
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(Color.backgroundWhite)
                    .cornerRadius(12)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(marketVM.watchlist.prefix(3))) { stock in
                        WatchlistRowView(stock: stock)
                        if stock.id != marketVM.watchlist.prefix(3).last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color.backgroundWhite)
                .cornerRadius(12)
            }
        }
    }
}

struct WatchlistRowView: View {
    let stock: Stock
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        Button(action: {
            tradeVM.openTradeSheet(for: stock)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.symbol)
                        .font(.headline)
                        .foregroundColor(Color.textDark)
                    Text(stock.name)
                        .font(.caption)
                        .foregroundColor(Color.textMedium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(stock.formattedPrice)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Color.textDark)
                    Text(stock.formattedPercent)
                        .font(.caption.weight(.medium))
                        .foregroundColor(stock.isPositive ? Color.gainsGreen : Color.lossesRed)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Full Watchlist View
struct WatchlistFullView: View {
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        List {
            ForEach(marketVM.watchlist) { stock in
                Button(action: {
                    tradeVM.openTradeSheet(for: stock)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stock.symbol)
                                .font(.headline)
                                .foregroundColor(Color.textDark)
                            Text(stock.name)
                                .font(.caption)
                                .foregroundColor(Color.textMedium)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(stock.formattedPrice)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(Color.textDark)
                            Text(stock.formattedPercent)
                                .font(.caption.weight(.medium))
                                .foregroundColor(stock.isPositive ? Color.gainsGreen : Color.lossesRed)
                        }
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    marketVM.removeFromWatchlist(marketVM.watchlist[index])
                }
            }
        }
        .navigationTitle("Watchlist")
    }
}

#Preview {
    DashboardView()
        .environmentObject(PortfolioViewModel())
        .environmentObject(MarketViewModel())
        .environmentObject(TradeViewModel())
}
