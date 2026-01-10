import Foundation

class HealthService {
    func fetchTodaySteps() -> Int { return 4500 }
    func syncWorkout(_ action: DailyAction) {
        print("Syncing \(action.title) to HealthKit")
    }
}
