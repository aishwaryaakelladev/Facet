import Combine
internal import SwiftUI

@MainActor
final class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ destination: AppDestination) {
        path.append(destination)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
