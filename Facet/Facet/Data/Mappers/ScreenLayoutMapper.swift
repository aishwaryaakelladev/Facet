import Foundation

struct ScreenLayoutMapper {

    func map(_ dto: ScreenLayoutDTO) -> ScreenLayout {
        ScreenLayout(
            screenId: dto.screenId,
            title: dto.title,
            components: dto.components.map(mapComponent)
        )
    }

    private func mapComponent(_ dto: ComponentDTO) -> ComponentItem {
        ComponentItem(id: dto.id, payload: mapPayload(dto.data))
    }

    private func mapPayload(_ data: ComponentDataDTO) -> ComponentPayload {
        switch data {
        case let dto as HeroBannerDTO:
            return .heroBanner(HeroBannerData(
                imageURL: dto.imageUrl.flatMap(URL.init),
                headline: dto.headline,
                subtitle: dto.subtitle,
                deeplink: dto.deeplink
            ))

        case let dto as CarouselDTO:
            return .horizontalCarousel(CarouselData(
                title: dto.title,
                items: dto.items.map {
                    CarouselItem(id: $0.id, label: $0.label, iconName: $0.iconName, deeplink: $0.deeplink)
                }
            ))

        case let dto as CardListDTO:
            return .cardList(CardListData(
                title: dto.title,
                cards: dto.cards.map {
                    ArticleCard(
                        id: $0.id,
                        title: $0.title,
                        body: $0.body,
                        imageURL: $0.imageUrl.flatMap(URL.init),
                        deeplink: $0.deeplink
                    )
                }
            ))

        case let dto as QuoteDTO:
            return .quoteBlock(QuoteData(quote: dto.quote, author: dto.author))

        default:
            return .unknown
        }
    }
}
