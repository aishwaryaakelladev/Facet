import Foundation

struct GistCredentials {
    let gistId: String
    let personalAccessToken: String
}

enum GistError: Error, LocalizedError {
    case missingCredentials
    case uploadFailed(Int)

    var errorDescription: String? {
        switch self {
        case .missingCredentials:   return "Enter your Gist ID and GitHub token in Settings."
        case .uploadFailed(let c):  return "GitHub returned error \(c). Check your token permissions."
        }
    }
}

final class GistUpdateService {

    func publish(_ layout: ScreenLayoutDTO, credentials: GistCredentials) async throws {
        guard !credentials.gistId.isEmpty, !credentials.personalAccessToken.isEmpty else {
            throw GistError.missingCredentials
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let layoutData = try encoder.encode(layout)
        guard let layoutString = String(data: layoutData, encoding: .utf8) else {
            throw NetworkError.invalidResponse
        }

        let body = GistPatchBody(files: ["home.json": GistFileContent(content: layoutString)])
        let bodyData = try JSONEncoder().encode(body)

        guard let url = URL(string: "https://api.github.com/gists/\(credentials.gistId)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(credentials.personalAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json",               forHTTPHeaderField: "Accept")
        request.setValue("application/json",                           forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw GistError.uploadFailed(http.statusCode) }
    }
}

// MARK: - Request models

private struct GistPatchBody: Encodable {
    let files: [String: GistFileContent]
}

private struct GistFileContent: Encodable {
    let content: String
}
