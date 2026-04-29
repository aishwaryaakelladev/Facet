import Foundation

struct ScreenLayout {
    let screenId: String
    let title: String
    let components: [ComponentItem]
}

struct ComponentItem: Identifiable {
    let id: String
    let payload: ComponentPayload
}
