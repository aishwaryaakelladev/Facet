internal import SwiftUI

struct QuoteBlockView: View {
    let data: QuoteData
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(hex: "6C47FF").opacity(0.5))

            Text(data.quote)
                .font(.body.italic())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6C47FF"), Color(hex: "C850C0")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 28, height: 2)
                Text(data.author)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color(hex: "6C47FF").opacity(0.3), Color(hex: "C850C0").opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture { router.push(.quoteDetail(data)) }
    }
}

#Preview {
    QuoteBlockView(data: QuoteData(
        quote: "Design is not just what it looks like. Design is how it works.",
        author: "Steve Jobs"
    ))
    .environmentObject(NavigationRouter())
}
