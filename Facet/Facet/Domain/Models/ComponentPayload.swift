import Foundation

enum ComponentPayload {
    case heroBanner(HeroBannerData)
    case horizontalCarousel(CarouselData)
    case cardList(CardListData)
    case quoteBlock(QuoteData)
    case unknown
}

// MARK: - Hero Banner

struct HeroBannerData: Hashable {
    let imageURL: URL?
    let headline: String
    let subtitle: String
    let deeplink: String?
}

// MARK: - Horizontal Carousel

struct CarouselData {
    let title: String
    let items: [CarouselItem]
}

struct CarouselItem: Identifiable, Hashable {
    let id: String
    let label: String
    let iconName: String
    let deeplink: String?
}

// MARK: - Card List

struct CardListData {
    let title: String
    let cards: [ArticleCard]
}

struct ArticleCard: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
    let imageURL: URL?
    let deeplink: String?
}

// MARK: - Quote Block

struct QuoteData: Hashable {
    let quote: String
    let author: String
}
