// Models/ActionModels.swift
import Foundation

struct Meeting: SchedulableAction {
    let id = UUID()
    var title: String
    var startTime: Date
    var duration: TimeInterval
    var category: ActionCategory = .work
    var blocksTimeline: Bool = true
}

struct WaterReminder: RecurringAction {
    let id = UUID()
    var title: String = "Drink Water"
    var frequencyInterval: TimeInterval = 3600 // Every hour
    var category: ActionCategory = .diet
    var blocksTimeline: Bool = false
    var isPausedByBlockingActions: Bool = true
}

// Example of a Health Task that doesn't block the timeline
struct GymSession: SchedulableAction {
    let id = UUID()
    var title: String
    var startTime: Date
    var duration: TimeInterval
    var category: ActionCategory = .health
    var blocksTimeline: Bool = false // You can still get water reminders at the gym!
}
