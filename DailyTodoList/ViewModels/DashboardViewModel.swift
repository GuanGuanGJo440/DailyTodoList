import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var actions: [DailyAction] = []
    
    let agentService: AgentService
    private let healthService: HealthService
    private var cancellables = Set<AnyCancellable>()
    
    init(agentService: AgentService, healthService: HealthService) {
        self.agentService = agentService
        self.healthService = healthService
        
        // Observe the agent service to update local state if needed
        agentService.$currentState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                if case .readyToSchedule(let action) = state {
                    self?.actions.append(action)
                }
            }
            .store(in: &cancellables)
    }
    
    func handleAgentInput(_ input: String) {
        agentService.processInput(input)
    }
}
