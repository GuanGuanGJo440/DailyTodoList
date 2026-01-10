import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @State private var userInput: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                Text("Today's Progress")
                    .font(.largeTitle).bold()
                
                List(viewModel.actions, id: \.id) { action in
                    Text(action.title)
                }
                
                Spacer()
                
                HStack {
                    TextField("Tell the AI Agent...", text: $userInput)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") {
                        viewModel.handleAgentInput(userInput)
                        userInput = ""
                    }
                }
                .padding()
            }
            .navigationTitle("Daily Task Aggregator")
        }
    }
}
