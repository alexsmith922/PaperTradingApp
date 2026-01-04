import SwiftUI

struct TradeSheetView: View {
    let stock: Stock
    @EnvironmentObject var tradeVM: TradeViewModel
    @EnvironmentObject var portfolioVM: PortfolioViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Stock Header
                stockHeader

                // Trade Type Picker
                tradeTypePicker

                // Shares Input
                sharesInputSection

                // Quick Select Buttons
                quickSelectButtons

                // Trade Summary
                tradeSummary

                Spacer()

                // Execute Button
                executeButton
            }
            .padding()
            .background(Color.cardGray)
            .navigationTitle(tradeVM.tradeType == .buy ? "Buy \(stock.symbol)" : "Sell \(stock.symbol)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        tradeVM.closeTradeSheet()
                    }
                    .foregroundColor(Color.primaryCoral)
                }
            }
            .overlay {
                if tradeVM.showConfirmation {
                    confirmationOverlay
                }
            }
        }
    }

    // MARK: - Stock Header
    private var stockHeader: some View {
        VStack(spacing: 8) {
            Text(stock.name)
                .font(.headline)
                .foregroundColor(Color.textDark)
            Text(stock.formattedPrice)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.textDark)
            HStack {
                Image(systemName: stock.isPositive ? "arrow.up.right" : "arrow.down.right")
                Text("\(stock.formattedChange) (\(stock.formattedPercent))")
            }
            .font(.subheadline)
            .foregroundColor(stock.isPositive ? Color.gainsGreen : Color.lossesRed)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.backgroundWhite)
        .cornerRadius(16)
    }

    // MARK: - Trade Type Picker
    private var tradeTypePicker: some View {
        HStack(spacing: 0) {
            tradeTypeButton(type: .buy, label: "Buy")
            tradeTypeButton(type: .sell, label: "Sell")
        }
        .background(Color.backgroundWhite)
        .cornerRadius(12)
    }

    private func tradeTypeButton(type: TradeType, label: String) -> some View {
        Button(action: {
            tradeVM.setTradeType(type)
        }) {
            Text(label)
                .font(.headline)
                .foregroundColor(tradeVM.tradeType == type ? .white : Color.textMedium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    tradeVM.tradeType == type
                        ? (type == .buy ? Color.gainsGreen : Color.lossesRed)
                        : Color.clear
                )
                .cornerRadius(12)
        }
    }

    // MARK: - Shares Input
    private var sharesInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Number of Shares")
                    .font(.subheadline)
                    .foregroundColor(Color.textMedium)
                Spacer()
                if tradeVM.tradeType == .buy {
                    Text("Cash: \(tradeVM.formattedCashBalance)")
                        .font(.caption)
                        .foregroundColor(Color.textMedium)
                } else if tradeVM.hasPosition {
                    Text("Owned: \(String(format: "%.2f", tradeVM.sharesOwned))")
                        .font(.caption)
                        .foregroundColor(Color.textMedium)
                }
            }

            HStack {
                TextField("0", text: $tradeVM.sharesInput)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color.textDark)
                    .multilineTextAlignment(.center)

                Text("shares")
                    .font(.title3)
                    .foregroundColor(Color.textMedium)
            }
            .padding()
            .background(Color.backgroundWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        tradeVM.validationMessage != nil ? Color.lossesRed : Color.clear,
                        lineWidth: 2
                    )
            )

            if let message = tradeVM.validationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(Color.lossesRed)
            }
        }
    }

    // MARK: - Quick Select Buttons
    private var quickSelectButtons: some View {
        HStack(spacing: 12) {
            quickSelectButton(.one)
            quickSelectButton(.five)
            quickSelectButton(.ten)
            quickSelectButton(.max)
        }
    }

    private func quickSelectButton(_ amount: QuickSelectAmount) -> some View {
        Button(action: {
            tradeVM.quickSelectShares(amount)
        }) {
            Text(amount.label)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color.primaryCoral)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.primaryCoral.opacity(0.1))
                .cornerRadius(8)
        }
    }

    // MARK: - Trade Summary
    private var tradeSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Price per share")
                    .foregroundColor(Color.textMedium)
                Spacer()
                Text(stock.formattedPrice)
                    .fontWeight(.medium)
            }

            HStack {
                Text("Shares")
                    .foregroundColor(Color.textMedium)
                Spacer()
                Text(tradeVM.isValidInput ? String(format: "%.2f", tradeVM.shares) : "—")
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Text(tradeVM.tradeType == .buy ? "Total Cost" : "Total Proceeds")
                    .font(.headline)
                Spacer()
                Text(tradeVM.isValidInput ? tradeVM.formattedTotalValue : "—")
                    .font(.headline)
                    .foregroundColor(tradeVM.tradeType == .buy ? Color.lossesRed : Color.gainsGreen)
            }
        }
        .font(.subheadline)
        .foregroundColor(Color.textDark)
        .padding()
        .background(Color.backgroundWhite)
        .cornerRadius(12)
    }

    // MARK: - Execute Button
    private var executeButton: some View {
        Button(action: {
            tradeVM.executeTrade()
        }) {
            HStack {
                if tradeVM.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(tradeVM.tradeType == .buy ? "Buy \(stock.symbol)" : "Sell \(stock.symbol)")
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                tradeVM.canExecuteTrade
                    ? (tradeVM.tradeType == .buy ? Color.gainsGreen : Color.lossesRed)
                    : Color.textMedium.opacity(0.5)
            )
            .cornerRadius(14)
        }
        .disabled(!tradeVM.canExecuteTrade || tradeVM.isProcessing)
    }

    // MARK: - Confirmation Overlay
    private var confirmationOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.gainsGreen)

            Text("Trade Complete!")
                .font(.title2.weight(.bold))
                .foregroundColor(Color.textDark)

            Text(tradeVM.tradeSummary)
                .font(.subheadline)
                .foregroundColor(Color.textMedium)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color.backgroundWhite)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 20)
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    TradeSheetView(stock: Stock.sampleStocks[0])
        .environmentObject(TradeViewModel())
        .environmentObject(PortfolioViewModel())
}
