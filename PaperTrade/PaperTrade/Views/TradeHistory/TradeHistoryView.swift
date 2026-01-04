import SwiftUI

struct TradeHistoryView: View {
    @EnvironmentObject var portfolioVM: PortfolioViewModel
    @State private var selectedFilter = "All"
    let filters = ["All", "Buys", "Sells"]

    var filteredTrades: [Trade] {
        switch selectedFilter {
        case "Buys":
            return portfolioVM.tradeHistory.filter { $0.type == .buy }
        case "Sells":
            return portfolioVM.tradeHistory.filter { $0.type == .sell }
        default:
            return portfolioVM.tradeHistory
        }
    }

    var groupedTrades: [(date: String, trades: [Trade])] {
        let grouped = Dictionary(grouping: filteredTrades) { $0.formattedDate }
        let sorted = grouped.sorted { first, second in
            guard let firstTrade = first.value.first,
                  let secondTrade = second.value.first else {
                return false
            }
            return firstTrade.timestamp > secondTrade.timestamp
        }
        return sorted.map { (date: $0.key, trades: $0.value) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Pills
                FilterPillsView(selectedFilter: $selectedFilter, filters: filters)
                    .padding()

                // Trade List
                if filteredTrades.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(groupedTrades, id: \.date) { group in
                                TradeSectionView(date: group.date, trades: group.trades)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color.cardGray)
            .navigationTitle("History")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundColor(Color.textMedium)
            Text("No trades yet")
                .font(.headline)
                .foregroundColor(Color.textDark)
            Text("Your buy and sell history will appear here")
                .font(.subheadline)
                .foregroundColor(Color.textMedium)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

// MARK: - Filter Pills
struct FilterPillsView: View {
    @Binding var selectedFilter: String
    let filters: [String]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(filters, id: \.self) { filter in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                }) {
                    Text(filter)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(selectedFilter == filter ? .white : Color.textMedium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(selectedFilter == filter ? Color.primaryCoral : Color.backgroundWhite)
                        .cornerRadius(20)
                }
            }
            Spacer()
        }
    }
}

// MARK: - Trade Section
struct TradeSectionView: View {
    let date: String
    let trades: [Trade]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color.textMedium)
                .padding(.top, 16)

            VStack(spacing: 0) {
                ForEach(Array(trades.enumerated()), id: \.element.id) { index, trade in
                    TradeRowView(trade: trade)
                    if index < trades.count - 1 {
                        Divider().padding(.horizontal)
                    }
                }
            }
            .background(Color.backgroundWhite)
            .cornerRadius(12)
        }
    }
}

// MARK: - Trade Row
struct TradeRowView: View {
    let trade: Trade

    var body: some View {
        HStack(spacing: 12) {
            // Action Icon
            Circle()
                .fill(trade.type.isBuy ? Color.gainsGreen.opacity(0.15) : Color.lossesRed.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: trade.type.isBuy ? "arrow.down.left" : "arrow.up.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(trade.type.isBuy ? Color.gainsGreen : Color.lossesRed)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(trade.actionText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(trade.type.isBuy ? Color.gainsGreen : Color.lossesRed)
                    Text(trade.symbol)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color.textDark)
                }
                Text("\(trade.formattedShares) @ \(trade.formattedPrice)")
                    .font(.caption)
                    .foregroundColor(Color.textMedium)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(trade.type.isBuy ? "-\(trade.formattedTotal)" : "+\(trade.formattedTotal)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.textDark)
                Text(trade.formattedTime)
                    .font(.caption)
                    .foregroundColor(Color.textMedium)
            }
        }
        .padding(16)
    }
}

#Preview {
    TradeHistoryView()
        .environmentObject(PortfolioViewModel())
}
