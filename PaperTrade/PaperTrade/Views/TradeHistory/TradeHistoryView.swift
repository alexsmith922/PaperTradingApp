import SwiftUI

struct TradeHistoryView: View {
    @State private var selectedFilter = "All"
    let filters = ["All", "Buys", "Sells"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Pills
                FilterPillsView(selectedFilter: $selectedFilter, filters: filters)
                    .padding()

                // Trade List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        TradeSection(date: "Today")
                        TradeSection(date: "Yesterday")
                        TradeSection(date: "Dec 28, 2025")
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.cardGray)
            .navigationTitle("History")
        }
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
                    selectedFilter = filter
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
struct TradeSection: View {
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color.textMedium)
                .padding(.top, 16)

            VStack(spacing: 0) {
                if date == "Today" {
                    TradeRow(
                        symbol: "AAPL",
                        action: "Bought",
                        shares: "5 shares",
                        price: "$178.25",
                        total: "$891.25",
                        time: "2:30 PM",
                        isBuy: true
                    )
                } else if date == "Yesterday" {
                    TradeRow(
                        symbol: "TSLA",
                        action: "Sold",
                        shares: "2 shares",
                        price: "$242.10",
                        total: "$484.20",
                        time: "11:15 AM",
                        isBuy: false
                    )
                    Divider().padding(.horizontal)
                    TradeRow(
                        symbol: "NVDA",
                        action: "Bought",
                        shares: "3 shares",
                        price: "$480.50",
                        total: "$1,441.50",
                        time: "9:45 AM",
                        isBuy: true
                    )
                } else {
                    TradeRow(
                        symbol: "GOOGL",
                        action: "Bought",
                        shares: "5 shares",
                        price: "$141.80",
                        total: "$709.00",
                        time: "3:20 PM",
                        isBuy: true
                    )
                }
            }
            .background(Color.backgroundWhite)
            .cornerRadius(12)
        }
    }
}

// MARK: - Trade Row
struct TradeRow: View {
    let symbol: String
    let action: String
    let shares: String
    let price: String
    let total: String
    let time: String
    let isBuy: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Action Icon
            Circle()
                .fill(isBuy ? Color.gainsGreen.opacity(0.15) : Color.lossesRed.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: isBuy ? "arrow.down.left" : "arrow.up.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isBuy ? Color.gainsGreen : Color.lossesRed)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(action)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(isBuy ? Color.gainsGreen : Color.lossesRed)
                    Text(symbol)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color.textDark)
                }
                Text("\(shares) @ \(price)")
                    .font(.caption)
                    .foregroundColor(Color.textMedium)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(isBuy ? "-\(total)" : "+\(total)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.textDark)
                Text(time)
                    .font(.caption)
                    .foregroundColor(Color.textMedium)
            }
        }
        .padding(16)
    }
}

#Preview {
    TradeHistoryView()
}
