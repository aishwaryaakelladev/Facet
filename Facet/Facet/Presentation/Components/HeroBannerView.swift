internal import SwiftUI

struct HeroBannerView: View {
    let data: HeroBannerData
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundImage
            gradient
            textOverlay
            tapIndicator
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        .contentShape(Rectangle())
        .onTapGesture { router.push(.bannerDetail(data)) }
    }

    private var tapIndicator: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(14)
            }
            Spacer()
        }
    }

    private var backgroundImage: some View {
        Group {
            if let url = data.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholderBackground
                    }
                }
            } else {
                placeholderBackground
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var placeholderBackground: some View {
        LinearGradient(
            colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var gradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.7)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var textOverlay: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(data.headline)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(data.subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(20)
    }
}

#Preview {
    HeroBannerView(data: HeroBannerData(
        imageURL: nil,
        headline: "Tuesday Digest",
        subtitle: "5 things to know today",
        deeplink: nil
    ))
    .environmentObject(NavigationRouter())
    .padding(.vertical)
}
