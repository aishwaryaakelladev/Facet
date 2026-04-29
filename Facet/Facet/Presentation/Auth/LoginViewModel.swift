import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    enum State: Equatable {
        case idle, loading, error(String)
    }

    @Published var username = ""
    @Published var password = ""
    @Published private(set) var state: State = .idle

    // Called with the authenticated user on success — avoids SessionStore injection
    var onLoginSuccess: ((AuthUser) -> Void)?

    private let loginUseCase: LoginUseCaseProtocol

    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    func login() {
        guard canSubmit else { return }
        state = .loading
        do {
            let user = try loginUseCase.execute(username: username, password: password)
            onLoginSuccess?(user)
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
