import SwiftUI

@main
struct PaperTradeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appState.portfolio)
                .environmentObject(appState.market)
                .environmentObject(appState.trade)
        }
    }
}
