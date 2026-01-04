import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Search Results (when searching)
                    if !marketVM.searchText.isEmpty {
                        SearchResultsView()
                    } else {
                        // Categories
                        CategoriesView()

                        // Trending Stocks
                        TrendingStocksView()

                        // Top Movers
                        TopMoversView()
                    }
                }
                .padding()
            }
            .background(Color.cardGray)
            .navigationTitle("Explore")
            .searchable(text: $marketVM.searchText, prompt: "Search stocks...")
        }
    }
}

// MARK: - Search Results
struct SearchResultsView: View {
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Results")
                .font(.headline)

            if marketVM.filteredStocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(Color.textMedium)
                    Text("No stocks found")
                        .font(.subheadline)
                        .foregroundColor(Color.textMedium)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color.backgroundWhite)
                .cornerRadius(12)
            } else {
                VStack(spacing: 0) {
                    ForEach(marketVM.filteredStocks) { stock in
                        StockSearchRow(stock: stock)
                        if stock.id != marketVM.filteredStocks.last?.id {
                            Divider().padding(.horizontal)
                        }
                    }
                }
                .background(Color.backgroundWhite)
                .cornerRadius(12)
            }
        }
    }
}

struct StockSearchRow: View {
    let stock: Stock
    @EnvironmentObject var marketVM: MarketViewModel
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
                        .lineLimit(1)
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

                // Watchlist button
                Button(action: {
                    marketVM.toggleWatchlist(stock)
                }) {
                    Image(systemName: marketVM.isInWatchlist(stock) ? "star.fill" : "star")
                        .foregroundColor(marketVM.isInWatchlist(stock) ? Color.accentYellow : Color.textMedium)
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding(16)
        }
    }
}

// MARK: - Categories
struct CategoriesView: View {
    @EnvironmentObject var marketVM: MarketViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(marketVM.categories, id: \.self) { category in
                        NavigationLink(destination: CategoryDetailView(category: category)) {
                            CategoryChip(name: category)
                        }
                    }
                }
            }
        }
    }
}

struct CategoryChip: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.subheadline.weight(.medium))
            .foregroundColor(Color.primaryCoral)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.primaryCoral.opacity(0.1))
            .cornerRadius(20)
    }
}

struct CategoryDetailView: View {
    let category: String
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var stocks: [Stock] {
        marketVM.stocks(for: category)
    }

    var body: some View {
        List(stocks) { stock in
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
        .navigationTitle(category)
    }
}

// MARK: - Trending Stocks
struct TrendingStocksView: View {
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trending")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(marketVM.trendingStocks) { stock in
                        TrendingCard(stock: stock)
                    }
                }
            }
        }
    }
}

struct TrendingCard: View {
    let stock: Stock
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        Button(action: {
            tradeVM.openTradeSheet(for: stock)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Stock icon placeholder
                Circle()
                    .fill(Color.secondaryTeal.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(stock.symbol.prefix(1)))
                            .font(.headline)
                            .foregroundColor(Color.secondaryTeal)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.symbol)
                        .font(.headline)
                        .foregroundColor(Color.textDark)
                    Text(stock.name)
                        .font(.caption)
                        .foregroundColor(Color.textMedium)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.formattedPrice)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.textDark)
                    Text(stock.formattedPercent)
                        .font(.caption.weight(.medium))
                        .foregroundColor(stock.isPositive ? Color.gainsGreen : Color.lossesRed)
                }
            }
            .frame(width: 140, height: 160)
            .padding(16)
            .background(Color.backgroundWhite)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
    }
}

// MARK: - Top Movers
struct TopMoversView: View {
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Movers Today")
                .font(.headline)

            VStack(spacing: 0) {
                // Show top gainers and losers interleaved
                let movers = Array(zip(marketVM.topGainers, marketVM.topLosers)).flatMap { [$0.0, $0.1] }
                ForEach(Array(movers.prefix(4).enumerated()), id: \.element.id) { index, stock in
                    MoverRow(stock: stock)
                    if index < min(movers.count, 4) - 1 {
                        Divider().padding(.horizontal)
                    }
                }
            }
            .background(Color.backgroundWhite)
            .cornerRadius(12)
        }
    }
}

struct MoverRow: View {
    let stock: Stock
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        Button(action: {
            tradeVM.openTradeSheet(for: stock)
        }) {
            HStack {
                Circle()
                    .fill(stock.isPositive ? Color.gainsGreen.opacity(0.2) : Color.lossesRed.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: stock.isPositive ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(stock.isPositive ? Color.gainsGreen : Color.lossesRed)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(stock.symbol)
                        .font(.headline)
                        .foregroundColor(Color.textDark)
                    Text(stock.name)
                        .font(.caption)
                        .foregroundColor(Color.textMedium)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(stock.formattedPrice)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Color.textDark)
                    Text(stock.formattedPercent)
                        .font(.caption.weight(.bold))
                        .foregroundColor(stock.isPositive ? Color.gainsGreen : Color.lossesRed)
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    ExploreView()
        .environmentObject(MarketViewModel())
        .environmentObject(TradeViewModel())
}
