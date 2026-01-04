import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Categories
                    CategoriesView()

                    // Trending Stocks
                    TrendingStocksView()

                    // Top Movers
                    TopMoversView()
                }
                .padding()
            }
            .background(Color.cardGray)
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search stocks...")
        }
    }
}

// MARK: - Categories
struct CategoriesView: View {
    let categories = ["Tech", "Health", "Finance", "Energy", "Retail"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        CategoryChip(name: category)
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

// MARK: - Trending Stocks
struct TrendingStocksView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trending")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TrendingCard(symbol: "NVDA", name: "NVIDIA", price: "$485.09", change: "+4.2%")
                    TrendingCard(symbol: "META", name: "Meta", price: "$505.75", change: "+2.1%")
                    TrendingCard(symbol: "AMZN", name: "Amazon", price: "$178.25", change: "+1.5%")
                }
            }
        }
    }
}

struct TrendingCard: View {
    let symbol: String
    let name: String
    let price: String
    let change: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Stock icon placeholder
            Circle()
                .fill(Color.secondaryTeal.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(symbol.prefix(1)))
                        .font(.headline)
                        .foregroundColor(Color.secondaryTeal)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(symbol)
                    .font(.headline)
                    .foregroundColor(Color.textDark)
                Text(name)
                    .font(.caption)
                    .foregroundColor(Color.textMedium)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(price)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.textDark)
                Text(change)
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color.gainsGreen)
            }
        }
        .frame(width: 140, height: 160)
        .padding(16)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Top Movers
struct TopMoversView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Movers Today")
                .font(.headline)

            VStack(spacing: 0) {
                MoverRow(symbol: "GME", name: "GameStop", price: "$24.50", change: "+12.5%", isPositive: true)
                Divider().padding(.horizontal)
                MoverRow(symbol: "AMC", name: "AMC Entertainment", price: "$5.20", change: "-8.3%", isPositive: false)
                Divider().padding(.horizontal)
                MoverRow(symbol: "RIVN", name: "Rivian", price: "$18.75", change: "+7.2%", isPositive: true)
            }
            .background(Color.backgroundWhite)
            .cornerRadius(12)
        }
    }
}

struct MoverRow: View {
    let symbol: String
    let name: String
    let price: String
    let change: String
    let isPositive: Bool

    var body: some View {
        HStack {
            Circle()
                .fill(isPositive ? Color.gainsGreen.opacity(0.2) : Color.lossesRed.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isPositive ? Color.gainsGreen : Color.lossesRed)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(symbol)
                    .font(.headline)
                    .foregroundColor(Color.textDark)
                Text(name)
                    .font(.caption)
                    .foregroundColor(Color.textMedium)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(price)
                    .font(.subheadline.weight(.medium))
                Text(change)
                    .font(.caption.weight(.bold))
                    .foregroundColor(isPositive ? Color.gainsGreen : Color.lossesRed)
            }
        }
        .padding(16)
    }
}

#Preview {
    ExploreView()
}
