import SwiftUI

struct StockDetailView: View {
    let symbol: String
    let name: String
    @State private var selectedTimeframe = "1D"
    let timeframes = ["1D", "1W", "1M", "3M", "1Y", "ALL"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Price Header
                PriceHeaderView()

                // Chart Placeholder
                ChartView(selectedTimeframe: $selectedTimeframe, timeframes: timeframes)

                // Action Buttons
                ActionButtonsView()

                // Key Stats
                KeyStatsView()

                // About
                AboutSectionView(name: name)
            }
            .padding()
        }
        .background(Color.cardGray)
        .navigationTitle(symbol)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Price Header
struct PriceHeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("$178.25")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(Color.textDark)

            HStack(spacing: 8) {
                Image(systemName: "arrow.up.right")
                Text("+$2.15 (1.22%)")
                Text("Today")
                    .foregroundColor(Color.textMedium)
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(Color.gainsGreen)
        }
        .padding(.vertical)
    }
}

// MARK: - Chart View
struct ChartView: View {
    @Binding var selectedTimeframe: String
    let timeframes: [String]

    var body: some View {
        VStack(spacing: 16) {
            // Placeholder chart
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backgroundWhite)
                .frame(height: 200)
                .overlay(
                    // Fake chart line
                    GeometryReader { geo in
                        Path { path in
                            let width = geo.size.width - 32
                            let height = geo.size.height - 32
                            let points: [CGFloat] = [0.5, 0.4, 0.6, 0.55, 0.7, 0.65, 0.8, 0.75, 0.85]

                            path.move(to: CGPoint(x: 16, y: 16 + height * (1 - points[0])))

                            for i in 1..<points.count {
                                let x = 16 + (width / CGFloat(points.count - 1)) * CGFloat(i)
                                let y = 16 + height * (1 - points[i])
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        .stroke(Color.gainsGreen, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
                )

            // Timeframe Selector
            HStack(spacing: 0) {
                ForEach(timeframes, id: \.self) { tf in
                    Button(action: {
                        selectedTimeframe = tf
                    }) {
                        Text(tf)
                            .font(.caption.weight(.medium))
                            .foregroundColor(selectedTimeframe == tf ? .white : Color.textMedium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedTimeframe == tf ? Color.primaryCoral : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(Color.backgroundWhite)
            .cornerRadius(12)
        }
    }
}

// MARK: - Action Buttons
struct ActionButtonsView: View {
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                HStack {
                    Image(systemName: "arrow.down.left")
                    Text("Buy")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.gainsGreen)
                .cornerRadius(12)
            }

            Button(action: {}) {
                HStack {
                    Image(systemName: "arrow.up.right")
                    Text("Sell")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.lossesRed)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Key Stats
struct KeyStatsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Stats")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatItem(label: "Open", value: "$176.50")
                StatItem(label: "High", value: "$179.20")
                StatItem(label: "Low", value: "$175.80")
                StatItem(label: "Volume", value: "52.3M")
                StatItem(label: "Market Cap", value: "$2.8T")
                StatItem(label: "P/E Ratio", value: "28.5")
            }
            .padding(16)
            .background(Color.backgroundWhite)
            .cornerRadius(12)
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(Color.textMedium)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color.textDark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - About Section
struct AboutSectionView: View {
    let name: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About \(name)")
                .font(.headline)

            Text("Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company offers iPhone, Mac, iPad, and wearables, home and accessories.")
                .font(.subheadline)
                .foregroundColor(Color.textMedium)
                .lineSpacing(4)
                .padding(16)
                .background(Color.backgroundWhite)
                .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationStack {
        StockDetailView(symbol: "AAPL", name: "Apple Inc.")
    }
}
