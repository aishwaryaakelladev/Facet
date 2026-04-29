import Foundation

struct AppConfiguration {
    let screenURLs: [String: URL]

    // MARK: - Environments

    /// Production: reads from your GitHub Gist (update the URL after creating your gist)
    static let production = AppConfiguration(screenURLs: [
        "home": URL(string: "https://gist.github.com/aishwaryaakelladev/8ce900c641df754dafdda1ccb31783ee")!
    ])

    /// Development: reads from a local JSON server (e.g. `python3 -m http.server 8080`)
    static let development = AppConfiguration(screenURLs: [
        "home": URL(string: "http://localhost:8080/home.json")!
    ])
}
