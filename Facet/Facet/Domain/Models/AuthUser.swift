import Foundation

enum UserRole: Equatable {
    case endUser
    case admin
}

struct AuthUser: Equatable {
    let username: String
    let role: UserRole
}
