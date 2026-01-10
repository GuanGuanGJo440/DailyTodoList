import Foundation

enum MissingField: String {
    case time, duration, quantity, activityName
}

enum ConversationState: Equatable {
    case idle
    case listening
    case missingInformation(MissingField)
    case readyToSchedule(any DailyAction)
    case processing

    static func == (lhs: ConversationState, rhs: ConversationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.listening, .listening):
            return true
        case (.processing, .processing):
            return true
        case (.missingInformation(let lField), .missingInformation(let rField)):
            return lField == rField
        case (.readyToSchedule(let lAction), .readyToSchedule(let rAction)):
            // Compare by ID since DailyAction is a protocol
            return lAction.id == rAction.id
        default:
            return false
        }
    }
}
