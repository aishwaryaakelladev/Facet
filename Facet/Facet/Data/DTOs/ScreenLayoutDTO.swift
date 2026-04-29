import Foundation

// MARK: - Root DTO

struct ScreenLayoutDTO: Codable {
    let screenId: String
    let title: String
    let components: [ComponentDTO]
}

// MARK: - Component DTO (polymorphic coding)

struct ComponentDTO: Decodable {
    let id: String
    let type: String
    let data: ComponentDataDTO

    // Direct init used by admin dashboard to create new components without JSON round-trip
    init(id: String, type: String, data: ComponentDataDTO) {
        self.id   = id
        self.type = type
        self.data = data
    }

    enum CodingKeys: String, CodingKey {
        case id, type, data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id   = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)

        switch type {
        case "hero_banner":
            data = try container.decode(HeroBannerDTO.self, forKey: .data)
        case "horizontal_carousel":
            data = try container.decode(CarouselDTO.self, forKey: .data)
        case "card_list":
            data = try container.decode(CardListDTO.self, forKey: .data)
        case "quote_block":
            data = try container.decode(QuoteDTO.self, forKey: .data)
        default:
            data = UnknownComponentDTO()
        }
    }
}

// Custom Encodable: cast the protocol existential back to its concrete type
extension ComponentDTO: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id,   forKey: .id)
        try container.encode(type, forKey: .type)
        if let dto = data as? HeroBannerDTO      { try container.encode(dto, forKey: .data) }
        else if let dto = data as? CarouselDTO   { try container.encode(dto, forKey: .data) }
        else if let dto = data as? CardListDTO   { try container.encode(dto, forKey: .data) }
        else if let dto = data as? QuoteDTO      { try container.encode(dto, forKey: .data) }
        // UnknownComponentDTO: omit — we don't re-publish unknown types
    }
}

// MARK: - ComponentDataDTO Protocol

protocol ComponentDataDTO {}

struct UnknownComponentDTO: ComponentDataDTO {}

// MARK: - Concrete DTOs (Codable for both fetch & publish)

struct HeroBannerDTO: ComponentDataDTO, Codable {
    let imageUrl: String?
    let headline: String
    let subtitle: String
    let deeplink: String?
}

struct CarouselDTO: ComponentDataDTO, Codable {
    let title: String
    let items: [CarouselItemDTO]
}

struct CarouselItemDTO: Codable {
    let id: String
    let label: String
    let iconName: String
    let deeplink: String?
}

struct CardListDTO: ComponentDataDTO, Codable {
    let title: String
    let cards: [ArticleCardDTO]
}

struct ArticleCardDTO: Codable {
    let id: String
    let title: String
    let body: String
    let imageUrl: String?
    let deeplink: String?
}

struct QuoteDTO: ComponentDataDTO, Codable {
    let quote: String
    let author: String
}
