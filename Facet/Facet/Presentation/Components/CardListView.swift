internal import SwiftUI

struct CardListView: View {
    let data: CardListData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(data.title)
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(data.cards) { card in
                    ArticleCardView(card: card)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Article Card

private struct ArticleCardView: View {
    let card: ArticleCard
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            cardImage
            cardText
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .contentShape(Rectangle())
        .onTapGesture { router.push(.articleDetail(card)) }
    }

    private var cardImage: some View {
        Group {
            if let url = card.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "6C47FF").opacity(0.2), Color(hex: "C850C0").opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "doc.text")
                    .foregroundStyle(Color(hex: "6C47FF"))
            )
    }

    private var cardText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            Text(card.body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CardListView(data: CardListData(
        title: "Featured",
        cards: [
            ArticleCard(
                id: "1",
                title: "The Rise of Server-Driven UI",
                body: "How companies like Airbnb and DoorDash ship UI changes without App Store updates.",
                imageURL: nil,
                deeplink: nil
            )
        ]
    ))
    .environmentObject(NavigationRouter())
}
