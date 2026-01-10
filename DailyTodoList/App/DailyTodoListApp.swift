import SwiftUI

@main
struct DailyTodoListApp: App {
    // The Coordinator is the "Brain" of the app's navigation and state
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            // We start by asking the coordinator to build the initial view
            coordinator.buildDashboard()
                .environmentObject(coordinator)
        }
    }
}
