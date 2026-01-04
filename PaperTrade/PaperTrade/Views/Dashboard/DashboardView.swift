import SwiftUI

struct DashboardView: View {
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
        }
    }
}

// MARK: - Balance Card
struct BalanceCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Balance")
                .font(.subheadline)
                .foregroundColor(Color.textMedium)

            Text("$10,000.00")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.textDark)

            HStack {
                Image(systemName: "arrow.up.right")
                Text("+$250.00 (2.5%)")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(Color.gainsGreen)
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
    var body: some View {
        HStack(spacing: 12) {
            StatBox(title: "Invested", value: "$7,500", color: Color.primaryCoral)
            StatBox(title: "Cash", value: "$2,500", color: Color.secondaryTeal)
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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Watchlist")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    // Navigate to full watchlist
                }
                .font(.subheadline)
                .foregroundColor(Color.primaryCoral)
            }

            VStack(spacing: 0) {
                WatchlistRowView(symbol: "AAPL", name: "Apple", price: "$178.25", change: "+1.2%", isPositive: true)
                Divider()
                WatchlistRowView(symbol: "GOOGL", name: "Google", price: "$141.80", change: "-0.5%", isPositive: false)
                Divider()
                WatchlistRowView(symbol: "TSLA", name: "Tesla", price: "$245.30", change: "+3.1%", isPositive: true)
            }
            .background(Color.backgroundWhite)
            .cornerRadius(12)
        }
    }
}

struct WatchlistRowView: View {
    let symbol: String
    let name: String
    let price: String
    let change: String
    let isPositive: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(symbol)
                    .font(.headline)
                    .foregroundColor(Color.textDark)
                Text(name)
                    .font(.caption)
                    .foregroundColor(Color.textMedium)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(price)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(Color.textDark)
                Text(change)
                    .font(.caption.weight(.medium))
                    .foregroundColor(isPositive ? Color.gainsGreen : Color.lossesRed)
            }
        }
        .padding(16)
    }
}

#Preview {
    DashboardView()
}
