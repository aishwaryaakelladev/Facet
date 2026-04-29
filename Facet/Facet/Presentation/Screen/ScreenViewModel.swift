import Combine
import Foundation

@MainActor
final class ScreenViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case loaded(ScreenLayout)
        case error(String)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading): return true
            case (.error(let a), .error(let b)):       return a == b
            case (.loaded(let a), .loaded(let b)):     return a.screenId == b.screenId
            default:                                    return false
            }
        }
    }

    @Published private(set) var state: State = .idle

    private let screenId: String
    private let fetchScreen: FetchScreenUseCaseProtocol

    init(screenId: String = "home", fetchScreen: FetchScreenUseCaseProtocol) {
        self.screenId = screenId
        self.fetchScreen = fetchScreen
    }

    func loadScreen() async {
        guard state != .loading else { return }
        state = .loading
        do {
            let layout = try await fetchScreen.execute(screenId: screenId)
            state = .loaded(layout)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func retry() async {
        state = .idle
        await loadScreen()
    }
}
