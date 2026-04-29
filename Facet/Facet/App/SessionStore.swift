import Combine
internal import SwiftUI

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var currentUser: AuthUser?

    var isLoggedIn: Bool { currentUser != nil }
    var isAdmin: Bool    { currentUser?.role == .admin }

    func login(_ user: AuthUser)  { currentUser = user }
    func logout()                 { currentUser = nil }
}
