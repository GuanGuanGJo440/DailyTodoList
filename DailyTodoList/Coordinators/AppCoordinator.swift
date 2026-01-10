import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    // Inject services so they persist across the app
    private let agentService = AgentService()
    private let healthService = HealthService()
    
    @ViewBuilder
    func buildDashboard() -> some View {
        let vm = DashboardViewModel(agentService: agentService, healthService: healthService)
        DashboardView(viewModel: vm)
    }
}
