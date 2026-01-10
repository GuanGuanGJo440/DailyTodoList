import Foundation
import UserNotifications

class NotificationService {
    
    /// Determines if a recurring reminder should be sent based on the current timeline.
    /// - Parameters:
    ///   - action: The recurring task (e.g., Water Intake)
    ///   - timeline: All actions scheduled for today
    ///   - currentTime: Usually Date(), but injectable for testing
    func shouldSuppressNotification(for action: RecurringAction, in timeline: [DailyAction], at currentTime: Date = Date()) -> Bool {
        
        // 1. If the action doesn't care about blocking, never suppress it (e.g., Medication)
        guard action.isPausedByBlockingActions else { return false }
        
        // 2. Identify all active "Schedulable" actions that block the timeline
        let blockingActions = timeline.compactMap { $0 as? SchedulableAction }
            .filter { $0.blocksTimeline }
        
        // 3. Check if current time falls within the window of any blocking action
        let isCurrentlyBusy = blockingActions.contains { busyItem in
            let start = busyItem.startTime
            let end = busyItem.startTime.addingTimeInterval(busyItem.duration)
            return currentTime >= start && currentTime <= end
        }
        
        return isCurrentlyBusy
    }
    
    /// Entry point for the AI or ViewModel to request a notification schedule
    func scheduleRequest(for action: DailyAction, timeline: [DailyAction]) {
        if let recurring = action as? RecurringAction {
            let isSuppressed = shouldSuppressNotification(for: recurring, in: timeline)
            
            if isSuppressed {
                print("🔇 Suppressing \(action.title): User is in a blocking event.")
                // Logic to retry later or silent log
            } else {
                sendImmediateNotification(title: action.title, body: "Time to hydrate!")
            }
        }
    }
    
    private func sendImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
