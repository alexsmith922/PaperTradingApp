import SwiftUI

struct PortfolioView: View {
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
        }
    }
}

// MARK: - Portfolio Summary
struct PortfolioSummaryView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Total Value
            VStack(spacing: 8) {
                Text("Total Value")
                    .font(.subheadline)
                    .foregroundColor(Color.textMedium)
                Text("$7,750.00")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.textDark)
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                    Text("+$350.00 (4.7%) all time")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color.gainsGreen)
            }
            .padding(.vertical, 8)

            // Allocation Chart Placeholder
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.primaryCoral)
                    .frame(height: 8)
                    .frame(maxWidth: .infinity)
                Rectangle()
                    .fill(Color.secondaryTeal)
                    .frame(height: 8)
                    .frame(width: 80)
                Rectangle()
                    .fill(Color.accentYellow)
                    .frame(height: 8)
                    .frame(width: 50)
            }
            .cornerRadius(4)

            // Legend
            HStack(spacing: 20) {
                LegendItem(color: Color.primaryCoral, label: "Tech (60%)")
                LegendItem(color: Color.secondaryTeal, label: "Health (25%)")
                LegendItem(color: Color.accentYellow, label: "Other (15%)")
            }
            .font(.caption)
        }
        .padding(20)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
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
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Holdings")
                .font(.headline)

            VStack(spacing: 0) {
                HoldingRow(
                    symbol: "AAPL",
                    name: "Apple Inc.",
                    shares: "10 shares",
                    value: "$1,782.50",
                    gainLoss: "+$125.00",
                    percentage: "+7.5%",
                    isPositive: true
                )
                Divider().padding(.horizontal)
                HoldingRow(
                    symbol: "GOOGL",
                    name: "Alphabet Inc.",
                    shares: "5 shares",
                    value: "$709.00",
                    gainLoss: "-$35.50",
                    percentage: "-4.8%",
                    isPositive: false
                )
                Divider().padding(.horizontal)
                HoldingRow(
                    symbol: "MSFT",
                    name: "Microsoft",
                    shares: "8 shares",
                    value: "$3,024.00",
                    gainLoss: "+$180.00",
                    percentage: "+6.3%",
                    isPositive: true
                )
                Divider().padding(.horizontal)
                HoldingRow(
                    symbol: "TSLA",
                    name: "Tesla Inc.",
                    shares: "3 shares",
                    value: "$735.90",
                    gainLoss: "+$45.30",
                    percentage: "+6.6%",
                    isPositive: true
                )
            }
            .background(Color.backgroundWhite)
            .cornerRadius(12)
        }
    }
}

struct HoldingRow: View {
    let symbol: String
    let name: String
    let shares: String
    let value: String
    let gainLoss: String
    let percentage: String
    let isPositive: Bool

    var body: some View {
        HStack {
            // Stock Icon
            Circle()
                .fill(Color.secondaryTeal.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(symbol.prefix(2)))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.secondaryTeal)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(symbol)
                    .font(.headline)
                    .foregroundColor(Color.textDark)
                Text(shares)
                    .font(.caption)
                    .foregroundColor(Color.textMedium)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.textDark)
                HStack(spacing: 4) {
                    Text(gainLoss)
                    Text("(\(percentage))")
                }
                .font(.caption.weight(.medium))
                .foregroundColor(isPositive ? Color.gainsGreen : Color.lossesRed)
            }
        }
        .padding(16)
    }
}

#Preview {
    PortfolioView()
}
