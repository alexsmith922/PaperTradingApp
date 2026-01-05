import SwiftUI
import SwiftData

@main
struct PaperTradeApp: App {
    let modelContainer: ModelContainer

    @StateObject private var appState: AppState

    init() {
        // Set up SwiftData model container
        let schema = Schema([
            UserAccount.self,
            PersistedHolding.self,
            PersistedTrade.self,
            WatchlistItem.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            self.modelContainer = container

            // Create AppState with the model context
            let context = container.mainContext
            let dataService = DataService(modelContext: context)
            let state = AppState(dataService: dataService)
            _appState = StateObject(wrappedValue: state)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(appState.portfolio)
                .environmentObject(appState.market)
                .environmentObject(appState.trade)
        }
        .modelContainer(modelContainer)
    }
}
