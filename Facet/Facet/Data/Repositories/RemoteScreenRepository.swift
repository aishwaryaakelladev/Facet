import Foundation

final class RemoteScreenRepository: ScreenRepositoryProtocol {
    private let networkService: NetworkService
    private let mapper: ScreenLayoutMapper
    private let screenURLs: [String: URL]

    init(
        networkService: NetworkService,
        mapper: ScreenLayoutMapper = ScreenLayoutMapper(),
        screenURLs: [String: URL]
    ) {
        self.networkService = networkService
        self.mapper = mapper
        self.screenURLs = screenURLs
    }

    func fetchScreen(id: String) async throws -> ScreenLayout {
        guard let url = screenURLs[id] else {
            throw NetworkError.invalidURL
        }
        let dto = try await networkService.fetch(ScreenLayoutDTO.self, from: url)
        return mapper.map(dto)
    }
}

// MARK: - Mock (for tests & SwiftUI previews)

final class MockScreenRepository: ScreenRepositoryProtocol {
    func fetchScreen(id: String) async throws -> ScreenLayout {
        ScreenLayout(
            screenId: id,
            title: "Good Morning",
            components: [
                ComponentItem(id: "1", payload: .heroBanner(HeroBannerData(
                    imageURL: nil,
                    headline: "Tuesday Digest",
                    subtitle: "5 things to know today",
                    deeplink: nil
                ))),
                ComponentItem(id: "2", payload: .horizontalCarousel(CarouselData(
                    title: "Browse Topics",
                    items: [
                        CarouselItem(id: "t1", label: "Tech", iconName: "cpu", deeplink: nil),
                        CarouselItem(id: "t2", label: "Health", iconName: "heart", deeplink: nil),
                        CarouselItem(id: "t3", label: "Science", iconName: "atom", deeplink: nil),
                        CarouselItem(id: "t4", label: "Design", iconName: "paintpalette", deeplink: nil),
                        CarouselItem(id: "t5", label: "Finance", iconName: "chart.bar", deeplink: nil)
                    ]
                ))),
                ComponentItem(id: "3", payload: .cardList(CardListData(
                    title: "Featured",
                    cards: [
                        ArticleCard(id: "a1", title: "The Rise of Server-Driven UI", body: "How companies like Airbnb and DoorDash ship UI changes without App Store updates.", imageURL: nil, deeplink: nil),
                        ArticleCard(id: "a2", title: "SwiftUI Performance Tips", body: "Practical techniques to keep your views fast and your users happy.", imageURL: nil, deeplink: nil)
                    ]
                ))),
                ComponentItem(id: "4", payload: .quoteBlock(QuoteData(
                    quote: "Design is not just what it looks like. Design is how it works.",
                    author: "Steve Jobs"
                )))
            ]
        )
    }
}
