internal import SwiftUI

enum NewComponentType: String, CaseIterable, Identifiable {
    case article = "Article"
    case quote   = "Quote"
    case banner  = "Hero Banner"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .article: return "doc.text"
        case .quote:   return "quote.bubble"
        case .banner:  return "photo"
        }
    }
}

struct AddComponentView: View {
    let onAdd: (ComponentDTO) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: NewComponentType = .article

    // Article fields
    @State private var articleTitle    = ""
    @State private var articleBody     = ""
    @State private var articleImageUrl = ""

    // Quote fields
    @State private var quoteText   = ""
    @State private var quoteAuthor = ""

    // Banner fields
    @State private var bannerHeadline = ""
    @State private var bannerSubtitle = ""
    @State private var bannerImageUrl = ""

    private var canSave: Bool {
        switch selectedType {
        case .article: return !articleTitle.isEmpty && !articleBody.isEmpty
        case .quote:   return !quoteText.isEmpty && !quoteAuthor.isEmpty
        case .banner:  return !bannerHeadline.isEmpty && !bannerSubtitle.isEmpty
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                typePicker
                dynamicFields
            }
            .navigationTitle("Add Component")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") { save() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
        }
    }

    // MARK: - Type picker

    private var typePicker: some View {
        Section("Component Type") {
            Picker("Type", selection: $selectedType) {
                ForEach(NewComponentType.allCases) { type in
                    Label(type.rawValue, systemImage: type.icon).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    // MARK: - Dynamic fields

    @ViewBuilder
    private var dynamicFields: some View {
        switch selectedType {
        case .article:
            Section("Article Details") {
                TextField("Title", text: $articleTitle)
                TextField("Body / Summary", text: $articleBody, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Image URL (optional)", text: $articleImageUrl)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

        case .quote:
            Section("Quote Details") {
                TextField("Quote text", text: $quoteText, axis: .vertical)
                    .lineLimit(2...5)
                TextField("Author", text: $quoteAuthor)
            }

        case .banner:
            Section("Banner Details") {
                TextField("Headline", text: $bannerHeadline)
                TextField("Subtitle", text: $bannerSubtitle)
                TextField("Image URL (optional)", text: $bannerImageUrl)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
        }
    }

    // MARK: - Build DTO

    private func save() {
        let newId = UUID().uuidString
        let dto: ComponentDTO

        switch selectedType {
        case .article:
            dto = ComponentDTO(
                id: newId,
                type: "card_list",
                data: CardListDTO(
                    title: articleTitle,
                    cards: [ArticleCardDTO(
                        id: UUID().uuidString,
                        title: articleTitle,
                        body: articleBody,
                        imageUrl: articleImageUrl.isEmpty ? nil : articleImageUrl,
                        deeplink: nil
                    )]
                )
            )
        case .quote:
            dto = ComponentDTO(
                id: newId,
                type: "quote_block",
                data: QuoteDTO(quote: quoteText, author: quoteAuthor)
            )
        case .banner:
            dto = ComponentDTO(
                id: newId,
                type: "hero_banner",
                data: HeroBannerDTO(
                    imageUrl: bannerImageUrl.isEmpty ? nil : bannerImageUrl,
                    headline: bannerHeadline,
                    subtitle: bannerSubtitle,
                    deeplink: nil
                )
            )
        }

        onAdd(dto)
        dismiss()
    }
}
