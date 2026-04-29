import Foundation

// Hardcoded credentials for demo/portfolio.
// In production: replace with a real auth API + JWT.
final class LocalAuthRepository: AuthRepositoryProtocol {

    private struct Credential {
        let username: String
        let password: String
        let role: UserRole
    }

    private let store: [Credential] = [
        Credential(username: "user",  password: "user123",  role: .endUser),
        Credential(username: "admin", password: "admin123", role: .admin)
    ]

    func login(username: String, password: String) throws -> AuthUser {
        guard let match = store.first(where: { $0.username == username && $0.password == password }) else {
            throw AuthError.invalidCredentials
        }
        return AuthUser(username: match.username, role: match.role)
    }
}
