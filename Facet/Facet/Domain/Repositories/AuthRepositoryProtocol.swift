import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials

    var errorDescription: String? {
        "Invalid username or password."
    }
}

protocol AuthRepositoryProtocol {
    func login(username: String, password: String) throws -> AuthUser
}
