internal import SwiftUI

struct ScreenView: View {
    @StateObject var viewModel: ScreenViewModel
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    loadingView
                case .loaded(let layout):
                    contentView(layout)
                case .error(let message):
                    errorView(message)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Facet")
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            // Register all possible detail destinations here, once.
            .navigationDestination(for: AppDestination.self) { destination in
                ComponentDetailView(destination: destination)
            }
        }
        .task { await viewModel.loadScreen() }
    }

    // MARK: - Sub-views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Loading your digest...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func contentView(_ layout: ScreenLayout) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(layout.components) { component in
                    ComponentRenderer(component: component)
                }
            }
            .padding(.vertical, 12)
        }
        .refreshable { await viewModel.retry() }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("Couldn't load content")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                Task { await viewModel.retry() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ScreenView(
        viewModel: ScreenViewModel(
            fetchScreen: FetchScreenUseCase(repository: MockScreenRepository())
        )
    )
    .environmentObject(NavigationRouter())
}
