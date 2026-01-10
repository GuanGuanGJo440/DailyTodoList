import SwiftUI
import Combine

/// A base protocol for all coordinators to handle navigation and lifecycle.
protocol Coordinator: ObservableObject {
    var path: NavigationPath { get set }
    func start()
}

/// A base class providing common coordinator functionality.
class BaseCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    // Common navigation methods can be added here
    func popToRoot() {
        path.removeLast(path.count)
    }
}
