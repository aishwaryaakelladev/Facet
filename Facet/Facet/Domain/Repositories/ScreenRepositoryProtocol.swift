import Foundation

protocol ScreenRepositoryProtocol {
    func fetchScreen(id: String) async throws -> ScreenLayout
}
