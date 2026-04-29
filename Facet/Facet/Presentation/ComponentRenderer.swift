internal import SwiftUI

// Open/Closed Principle: add a new case + a new View; nothing else changes.
struct ComponentRenderer: View {
    let component: ComponentItem

    var body: some View {
        switch component.payload {
        case .heroBanner(let data):
            HeroBannerView(data: data)
        case .horizontalCarousel(let data):
            HorizontalCarouselView(data: data)
        case .cardList(let data):
            CardListView(data: data)
        case .quoteBlock(let data):
            QuoteBlockView(data: data)
        case .unknown:
            EmptyView()
        }
    }
}
