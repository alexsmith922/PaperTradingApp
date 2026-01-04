import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Banner
                    WelcomeBannerView()

                    // Quick Tips
                    QuickTipsView()

                    // Learning Topics
                    LearningTopicsView()
                }
                .padding()
            }
            .background(Color.cardGray)
            .navigationTitle("Learn")
        }
    }
}

// MARK: - Welcome Banner
struct WelcomeBannerView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("New to Trading?")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                    Text("Start with our beginner's guide and learn the basics in plain English.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.3))
            }

            Button(action: {}) {
                Text("Start Learning")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.primaryCoral)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(20)
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.primaryCoral, Color.primaryCoral.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

// MARK: - Quick Tips
struct QuickTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Tips")
                    .font(.headline)
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color.accentYellow)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TipCard(
                        emoji: "📊",
                        title: "What's a Stock?",
                        description: "A tiny piece of a company you can own"
                    )
                    TipCard(
                        emoji: "💰",
                        title: "Buy Low, Sell High",
                        description: "The golden rule of making money"
                    )
                    TipCard(
                        emoji: "🎯",
                        title: "Diversify",
                        description: "Don't put all eggs in one basket"
                    )
                }
            }
        }
    }
}

struct TipCard: View {
    let emoji: String
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(emoji)
                .font(.system(size: 32))

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color.textDark)

            Text(description)
                .font(.caption)
                .foregroundColor(Color.textMedium)
                .lineLimit(2)
        }
        .frame(width: 150, height: 130, alignment: .topLeading)
        .padding(16)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Learning Topics
struct LearningTopicsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Topics")
                .font(.headline)

            VStack(spacing: 12) {
                TopicRow(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: Color.gainsGreen,
                    title: "Understanding Charts",
                    subtitle: "Learn to read price movements",
                    progress: 0.0
                )
                TopicRow(
                    icon: "dollarsign.circle",
                    iconColor: Color.secondaryTeal,
                    title: "How Prices Work",
                    subtitle: "Supply, demand, and market forces",
                    progress: 0.0
                )
                TopicRow(
                    icon: "shield.checkered",
                    iconColor: Color.primaryCoral,
                    title: "Managing Risk",
                    subtitle: "Protect yourself from big losses",
                    progress: 0.0
                )
                TopicRow(
                    icon: "building.columns",
                    iconColor: Color.accentYellow,
                    title: "Market Basics",
                    subtitle: "How the stock market works",
                    progress: 0.0
                )
            }
        }
    }
}

struct TopicRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let progress: Double

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            RoundedRectangle(cornerRadius: 12)
                .fill(iconColor.opacity(0.15))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.textDark)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.textMedium)

                if progress > 0 {
                    ProgressView(value: progress)
                        .tint(Color.gainsGreen)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.textMedium)
        }
        .padding(16)
        .background(Color.backgroundWhite)
        .cornerRadius(12)
    }
}

#Preview {
    LearnView()
}
