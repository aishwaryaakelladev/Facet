import Foundation

protocol LoginUseCaseProtocol {
    func execute(username: String, password: String) throws -> AuthUser
}

struct LoginUseCase: LoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(username: String, password: String) throws -> AuthUser {
        try repository.login(username: username.trimmingCharacters(in: .whitespaces),
                             password: password)
    }
}
