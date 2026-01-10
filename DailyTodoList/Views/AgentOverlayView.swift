import SwiftUI

struct AgentOverlayView: View {
    let state: ConversationState
    
    var body: some View {
        VStack(spacing: 12) {
            switch state {
            case .listening:
                ProgressView("Agent is thinking...")
                    .tint(.blue)
            
            case .missingInformation(let field):
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                    Text("I need to know the \(field.rawValue) before I can add that.")
                }
                .padding()
                .background(Color.orange.opacity(0.2))
                .cornerRadius(10)
                
            case .readyToSchedule(let action):
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Ready to add: \(action.title)")
                }
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(10)
                
            default:
                EmptyView()
            }
        }
        .padding()
        .animation(.spring(), value: state)
    }
}
