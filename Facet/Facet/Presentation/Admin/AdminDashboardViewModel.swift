import Combine
import Foundation
internal import SwiftUI

@MainActor
final class AdminDashboardViewModel: ObservableObject {

    enum PublishState: Equatable {
        case idle, publishing, success, error(String)
    }

    @Published private(set) var components: [ComponentDTO] = []
    @Published private(set) var isLoadingContent = false
    @Published private(set) var publishState: PublishState = .idle

    private let networkService = NetworkService()
    private let gistService    = GistUpdateService()
    private let mapper         = ScreenLayoutMapper()

    // MARK: - Load current content from Gist

    func loadContent(from url: URL?) async {
        guard let url else { return }
        isLoadingContent = true
        defer { isLoadingContent = false }
        do {
            let dto = try await networkService.fetch(ScreenLayoutDTO.self, from: url)
            components = dto.components
        } catch {
            // Start with empty list if fetch fails (offline / first time)
        }
    }

    // MARK: - Editing

    func add(_ component: ComponentDTO) {
        components.append(component)
    }

    func delete(at offsets: IndexSet) {
        components.remove(atOffsets: offsets)
    }

    func move(from source: IndexSet, to destination: Int) {
        components.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Publish

    func publish(gistId: String, token: String) async {
        publishState = .publishing
        let layout = ScreenLayoutDTO(screenId: "home", title: "Good Morning", components: components)
        do {
            let creds = GistCredentials(gistId: gistId, personalAccessToken: token)
            try await gistService.publish(layout, credentials: creds)
            publishState = .success
            try? await Task.sleep(for: .seconds(2))
            publishState = .idle
        } catch {
            publishState = .error(error.localizedDescription)
            try? await Task.sleep(for: .seconds(3))
            publishState = .idle
        }
    }

    // MARK: - Preview

    /// Builds a ScreenLayout from current draft so AdminDashboardView can show a user-facing preview
    func makePreviewLayout() -> ScreenLayout {
        let dto = ScreenLayoutDTO(screenId: "home", title: "Preview", components: components)
        return mapper.map(dto)
    }
}

// MARK: - ComponentDTO display helpers

extension ComponentDTO {
    var displayTypeName: String {
        switch type {
        case "hero_banner":         return "Hero Banner"
        case "horizontal_carousel": return "Carousel"
        case "card_list":           return "Article List"
        case "quote_block":         return "Quote"
        default:                    return "Unknown"
        }
    }

    var displayIcon: String {
        switch type {
        case "hero_banner":         return "photo"
        case "horizontal_carousel": return "rectangle.3.group"
        case "card_list":           return "doc.text"
        case "quote_block":         return "quote.bubble"
        default:                    return "questionmark.circle"
        }
    }

    var previewText: String {
        if let d = data as? HeroBannerDTO  { return d.headline }
        if let d = data as? QuoteDTO       { return "\"\(d.quote.prefix(60))\"" }
        if let d = data as? CardListDTO    { return "\(d.cards.count) article(s) — \(d.title)" }
        if let d = data as? CarouselDTO    { return "\(d.items.count) topic(s) — \(d.title)" }
        return "—"
    }
}
