internal import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = AdminDashboardViewModel()

    @AppStorage("facet_gist_id")    private var gistId:      String = ""
    @AppStorage("facet_github_pat") private var githubToken: String = ""
    @AppStorage("facet_gist_raw_url") private var gistRawURL: String = ""

    @State private var showAddComponent = false
    @State private var showSettings     = false
    @State private var showPreview      = false
    @State private var isEditMode       = EditMode.inactive

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                componentList
                addButton
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .environment(\.editMode, $isEditMode)
            .sheet(isPresented: $showAddComponent) {
                AddComponentView { viewModel.add($0) }
            }
            .sheet(isPresented: $showSettings) {
                AdminSettingsView()
            }
            .sheet(isPresented: $showPreview) {
                previewSheet
            }
            .overlay(publishBanner)
        }
        .task {
            await viewModel.loadContent(from: URL(string: gistRawURL))
        }
    }

    // MARK: - Component list

    private var componentList: some View {
        List {
            if viewModel.isLoadingContent {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .listRowBackground(Color.clear)
            } else if viewModel.components.isEmpty {
                emptyState
            } else {
                ForEach(viewModel.components, id: \.id) { component in
                    ComponentRowView(component: component)
                }
                .onDelete { viewModel.delete(at: $0) }
                .onMove   { viewModel.move(from: $0, to: $1) }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.easeInOut, value: viewModel.components.count)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 44))
                .foregroundStyle(Color(hex: "6C47FF").opacity(0.5))
            Text("No components yet")
                .font(.headline)
            Text("Tap + to add your first component")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowBackground(Color.clear)
    }

    // MARK: - FAB

    private var addButton: some View {
        Button {
            showAddComponent = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color(hex: "6C47FF").opacity(0.4), radius: 12, y: 4)
        }
        .padding(24)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                session.logout()
            } label: {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(.red)
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                showPreview = true
            } label: {
                Label("Preview", systemImage: "eye")
            }

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gear")
            }

            Button {
                Task { await viewModel.publish(gistId: gistId, token: githubToken) }
            } label: {
                publishLabel
            }
            .disabled(viewModel.components.isEmpty || viewModel.publishState == .publishing)
        }
    }

    @ViewBuilder
    private var publishLabel: some View {
        switch viewModel.publishState {
        case .publishing:
            ProgressView().scaleEffect(0.8)
        case .success:
            Label("Published!", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        default:
            Label("Publish", systemImage: "arrow.up.circle.fill")
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
        }
    }

    // MARK: - Publish banner overlay

    @ViewBuilder
    private var publishBanner: some View {
        if case .error(let msg) = viewModel.publishState {
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.circle.fill").foregroundStyle(.red)
                    Text(msg).font(.caption)
                    Spacer()
                }
                .padding(14)
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Preview sheet

    private var previewSheet: some View {
        let layout    = viewModel.makePreviewLayout()
        let mockRepo  = PreviewMockRepository(layout)
        let useCase   = FetchScreenUseCase(repository: mockRepo)
        let vm        = ScreenViewModel(fetchScreen: useCase)
        return NavigationStack {
            ScreenView(viewModel: vm)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showPreview = false }
                    }
                }
        }
        .environmentObject(NavigationRouter())
    }
}

// MARK: - Component row

private struct ComponentRowView: View {
    let component: ComponentDTO

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: [Color(hex: "6C47FF").opacity(0.12), Color(hex: "C850C0").opacity(0.12)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 42, height: 42)
                Image(systemName: component.displayIcon)
                    .foregroundStyle(Color(hex: "6C47FF"))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(component.displayTypeName)
                    .font(.subheadline.weight(.semibold))
                Text(component.previewText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview-only mock repository

final class PreviewMockRepository: ScreenRepositoryProtocol {
    private let layout: ScreenLayout
    init(_ layout: ScreenLayout) { self.layout = layout }
    func fetchScreen(id: String) async throws -> ScreenLayout { layout }
}

#Preview {
    AdminDashboardView()
        .environmentObject(SessionStore())
        .environmentObject(NavigationRouter())
}
