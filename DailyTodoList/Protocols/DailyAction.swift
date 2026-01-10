
import Foundation

enum ActionCategory {
    case work, health, diet, general
}

/// The base protocol for anything that appears in the Daily Timeline.
protocol DailyAction {
    var id: UUID { get }
    var title: String { get }
    var category: ActionCategory { get }
    
    /// Determines if this action prevents other non-essential notifications
    /// (e.g., a Meeting or a Date).
    var blocksTimeline: Bool { get }
}

/// For items with a fixed start time and length (Calendar events, Gym sessions).
protocol SchedulableAction: DailyAction {
    var startTime: Date { get }
    var duration: TimeInterval { get }
}

/// For items that repeat (Water intake, Posture checks, Vitamin reminders).
protocol RecurringAction: DailyAction {
    var frequencyInterval: TimeInterval { get }
    var isPausedByBlockingActions: Bool { get }
}
