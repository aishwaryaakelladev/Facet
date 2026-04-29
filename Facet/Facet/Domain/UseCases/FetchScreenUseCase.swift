import Foundation

// MARK: - Protocol (Dependency Inversion)

protocol FetchScreenUseCaseProtocol {
    func execute(screenId: String) async throws -> ScreenLayout
}

// MARK: - Concrete Implementation

struct FetchScreenUseCase: FetchScreenUseCaseProtocol {
    private let repository: ScreenRepositoryProtocol

    init(repository: ScreenRepositoryProtocol) {
        self.repository = repository
    }

    func execute(screenId: String) async throws -> ScreenLayout {
        try await repository.fetchScreen(id: screenId)
    }
}
