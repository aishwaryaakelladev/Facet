import Foundation

// Each case maps to a tappable component.
// Hashable is required by NavigationStack(path:) to type-erase destinations.
enum AppDestination: Hashable {
    case articleDetail(ArticleCard)
    case categoryDetail(CarouselItem)
    case quoteDetail(QuoteData)
    case bannerDetail(HeroBannerData)
}
