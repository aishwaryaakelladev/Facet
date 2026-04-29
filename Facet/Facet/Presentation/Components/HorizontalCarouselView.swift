internal import SwiftUI

struct HorizontalCarouselView: View {
    let data: CarouselData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle
            carouselItems
        }
    }

    private var sectionTitle: some View {
        Text(data.title)
            .font(.headline)
            .padding(.horizontal)
    }

    private var carouselItems: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(data.items) { item in
                    CarouselChipView(item: item)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Chip

private struct CarouselChipView: View {
    let item: CarouselItem
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6C47FF").opacity(0.15), Color(hex: "C850C0").opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                Image(systemName: item.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            Text(item.label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
        }
        .frame(width: 72)
        .onTapGesture { router.push(.categoryDetail(item)) }
    }
}

#Preview {
    HorizontalCarouselView(data: CarouselData(
        title: "Browse Topics",
        items: [
            CarouselItem(id: "1", label: "Tech", iconName: "cpu", deeplink: nil),
            CarouselItem(id: "2", label: "Health", iconName: "heart", deeplink: nil),
            CarouselItem(id: "3", label: "Science", iconName: "atom", deeplink: nil)
        ]
    ))
    .environmentObject(NavigationRouter())
}
