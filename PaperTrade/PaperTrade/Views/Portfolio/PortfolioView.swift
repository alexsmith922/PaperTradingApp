import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Portfolio Summary
                    PortfolioSummaryView()

                    // Holdings List
                    HoldingsListView()
                }
                .padding()
            }
            .background(Color.cardGray)
            .navigationTitle("Portfolio")
            .refreshable {
                await marketVM.refreshPrices()
                portfolioVM.updatePrices(from: marketVM.allStocks)
            }
        }
    }
}

// MARK: - Portfolio Summary
struct PortfolioSummaryView: View {
    @EnvironmentObject var portfolioVM: PortfolioViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Total Value
            VStack(spacing: 8) {
                Text("Total Holdings")
                    .font(.subheadline)
                    .foregroundColor(Color.textMedium)
                Text(portfolioVM.formattedHoldingsValue)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.textDark)

                if portfolioVM.totalCostBasis > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: portfolioVM.totalGainLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(formatCurrency(portfolioVM.totalGainLoss)) (\(String(format: "%.1f%%", portfolioVM.totalGainLossPercent)))")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(portfolioVM.totalGainLoss >= 0 ? Color.gainsGreen : Color.lossesRed)
                }
            }
            .padding(.vertical, 8)

            // Allocation Chart (if holdings exist)
            if !portfolioVM.holdings.isEmpty {
                AllocationBarView(holdings: portfolioVM.holdings)
            }
        }
        .padding(20)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private func formatCurrency(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return String(format: "%@$%.2f", sign, abs(value))
    }
}

struct AllocationBarView: View {
    let holdings: [Holding]

    var total: Double {
        holdings.reduce(0) { $0 + $1.currentValue }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Bar chart
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(Array(holdings.enumerated()), id: \.element.id) { index, holding in
                        Rectangle()
                            .fill(colorForIndex(index))
                            .frame(width: geo.size.width * CGFloat(holding.currentValue / total))
                    }
                }
            }
            .frame(height: 8)
            .cornerRadius(4)

            // Legend
            HStack(spacing: 16) {
                ForEach(Array(holdings.prefix(3).enumerated()), id: \.element.id) { index, holding in
                    LegendItem(
                        color: colorForIndex(index),
                        label: "\(holding.symbol) (\(String(format: "%.0f%%", (holding.currentValue / total) * 100)))"
                    )
                }
                if holdings.count > 3 {
                    LegendItem(color: Color.textMedium, label: "+\(holdings.count - 3) more")
                }
            }
            .font(.caption)
        }
    }

    func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [.primaryCoral, .secondaryTeal, .accentYellow, .gainsGreen, .lossesRed]
        return colors[index % colors.count]
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(Color.textMedium)
        }
    }
}

// MARK: - Holdings List
struct HoldingsListView: View {
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Holdings")
                .font(.headline)

            if portfolioVM.holdings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundColor(Color.textMedium)
                    Text("No holdings yet")
                        .font(.headline)
                        .foregroundColor(Color.textDark)
                    Text("Start trading to build your portfolio!")
                        .font(.subheadline)
                        .foregroundColor(Color.textMedium)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color.backgroundWhite)
                .cornerRadius(12)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(portfolioVM.holdings.enumerated()), id: \.element.id) { index, holding in
                        HoldingRowView(holding: holding)
                        if index < portfolioVM.holdings.count - 1 {
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

struct HoldingRowView: View {
    let holding: Holding
    @EnvironmentObject var marketVM: MarketViewModel
    @EnvironmentObject var tradeVM: TradeViewModel

    var body: some View {
        Button(action: {
            if let stock = marketVM.stock(for: holding.symbol) {
                tradeVM.openTradeSheet(for: stock, type: .sell)
            }
        }) {
            HStack {
                // Stock Icon
                Circle()
                    .fill(Color.secondaryTeal.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(holding.symbol.prefix(2)))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.secondaryTeal)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(holding.symbol)
                        .font(.headline)
                        .foregroundColor(Color.textDark)
                    Text(holding.formattedShares)
                        .font(.caption)
                        .foregroundColor(Color.textMedium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(holding.formattedValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.textDark)
                    HStack(spacing: 4) {
                        Text(holding.formattedGainLoss)
                        Text("(\(holding.formattedGainLossPercent))")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundColor(holding.isPositive ? Color.gainsGreen : Color.lossesRed)
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    PortfolioView()
        .environmentObject(PortfolioViewModel())
        .environmentObject(MarketViewModel())
        .environmentObject(TradeViewModel())
}
