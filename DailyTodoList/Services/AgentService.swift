import Foundation
import Combine

class AgentService: ObservableObject {
    @Published var currentState: ConversationState = .idle
    
    func processInput(_ text: String) {
        let input = text.lowercased()
        
        if input.contains("gym") && !input.contains("at") {
            currentState = .missingInformation(.time)
        } else if input.contains("water") {
            currentState = .readyToSchedule(WaterReminder(title: "Drink Water"))
        } else {
            currentState = .idle
        }
    }
}
