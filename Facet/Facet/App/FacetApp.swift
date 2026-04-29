import Combine
internal import SwiftUI

@main
struct FacetApp: App {
    @StateObject private var router  = NavigationRouter()
    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(session)
        }
    }
}

// MARK: - Root routing

struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        if !session.isLoggedIn {
            LoginView()
        } else if session.isAdmin {
            AdminDashboardView()
        } else {
            userFeedView
        }
    }

    private var userFeedView: some View {
        let repository = makeRepository()
        let useCase    = FetchScreenUseCase(repository: repository)
        return ScreenView(viewModel: ScreenViewModel(fetchScreen: useCase))
    }

    private func makeRepository() -> ScreenRepositoryProtocol {
        #if DEBUG
        return MockScreenRepository()
        #else
        return RemoteScreenRepository(
            networkService: NetworkService(),
            screenURLs: AppConfiguration.production.screenURLs
        )
        #endif
    }
}
