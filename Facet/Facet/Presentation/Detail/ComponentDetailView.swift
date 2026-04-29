internal import SwiftUI

// Entry point: routes each AppDestination to the right detail layout.
struct ComponentDetailView: View {
    let destination: AppDestination

    var body: some View {
        switch destination {
        case .articleDetail(let card):
            ArticleDetailPage(card: card)
        case .categoryDetail(let item):
            CategoryDetailPage(item: item)
        case .quoteDetail(let data):
            QuoteDetailPage(data: data)
        case .bannerDetail(let data):
            BannerDetailPage(data: data)
        }
    }
}

// MARK: - Article Detail

private struct ArticleDetailPage: View {
    let card: ArticleCard
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroHeader
                articleBody
                    .padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showShareSheet = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [card.title, card.body])
        }
    }

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            if let url = card.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: gradientPlaceholder
                    }
                }
            } else {
                gradientPlaceholder
            }
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
            Text(card.title)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(20)
        }
        .frame(height: 280)
        .clipped()
    }

    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var articleBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("5 min read", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label("Today", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Text(card.body)
                .font(.body)
                .lineSpacing(6)

            // Extended placeholder body to make the detail feel complete
            Text("""
                This is where the full article content would appear, loaded from your server-driven JSON response. By storing the full body in your backend JSON, you can update article content, fix typos, or expand coverage without submitting a new App Store build.

                The server-driven architecture means this entire page — its layout, its content, and even which sections appear — are all determined at runtime by the JSON your server returns. The iOS app is purely a renderer.

                This approach is how teams at Airbnb, DoorDash, and Spotify ship UI changes to millions of users in minutes rather than weeks.
                """)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
        }
    }
}

// MARK: - Category Detail

private struct CategoryDetailPage: View {
    let item: CarouselItem

    private let placeholderCards = [
        ("Getting Started", "A beginner's guide to this topic."),
        ("Deep Dive", "An advanced look at the latest trends."),
        ("Expert Insights", "What practitioners say about this field."),
        ("Tools & Resources", "The best tools for practitioners.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                categoryHeader
                Divider().padding(.horizontal)
                articlesList
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(item.label)
        .navigationBarTitleDisplayMode(.large)
    }

    private var categoryHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                Image(systemName: item.iconName)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(.white)
            }
            .shadow(color: Color(hex: "6C47FF").opacity(0.4), radius: 16, y: 8)

            Text("Explore \(item.label)")
                .font(.title3.bold())
            Text("\(placeholderCards.count) articles in this topic")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }

    private var articlesList: some View {
        VStack(spacing: 12) {
            ForEach(placeholderCards, id: \.0) { title, body in
                HStack(alignment: .top, spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            colors: [Color(hex: "6C47FF").opacity(0.15), Color(hex: "C850C0").opacity(0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 56, height: 56)
                        .overlay(Image(systemName: item.iconName)
                            .foregroundStyle(Color(hex: "6C47FF")))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(.subheadline.weight(.semibold))
                        Text(body).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Quote Detail

private struct QuoteDetailPage: View {
    let data: QuoteData
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                decorativeHeader
                quoteContent
                authorSection
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Quote")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showShareSheet = true } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["\"\(data.quote)\" — \(data.author)"])
        }
    }

    private var decorativeHeader: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(hex: "6C47FF").opacity(0.1), Color(hex: "C850C0").opacity(0.1)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 120, height: 120)
            Image(systemName: "quote.bubble")
                .font(.system(size: 48))
                .foregroundStyle(LinearGradient(
                    colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
        }
        .padding(.top, 20)
    }

    private var quoteContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "quote.opening")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color(hex: "6C47FF").opacity(0.4))

            Text(data.quote)
                .font(.title3.italic())
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(
                    LinearGradient(
                        colors: [Color(hex: "6C47FF").opacity(0.3), Color(hex: "C850C0").opacity(0.3)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 1.5
                ))
        )
    }

    private var authorSection: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(width: 40, height: 2)
            Text(data.author)
                .font(.headline)
            Spacer()
        }
    }
}

// MARK: - Banner Detail

private struct BannerDetailPage: View {
    let data: HeroBannerData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroHeader
                bannerBody.padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            if let url = data.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: gradientPlaceholder
                    }
                }
            } else {
                gradientPlaceholder
            }
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 6) {
                Text(data.headline).font(.largeTitle.bold()).foregroundStyle(.white)
                Text(data.subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.85))
            }
            .padding(20)
        }
        .frame(height: 320)
        .clipped()
    }

    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var bannerBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            Text("Today's Highlights")
                .font(.headline)
            Text("""
                This featured story is curated daily by our editorial team and surfaced via your server-driven JSON. Changing the featured story requires only a backend update — no App Store release needed.

                This is the power of server-driven UI: your content editors and designers have full control over what users see, and when they see it.
                """)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
        }
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
