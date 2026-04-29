import Foundation

// MARK: - Errors

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:               return "Invalid URL."
        case .invalidResponse:          return "Invalid server response."
        case .statusCode(let code):     return "Server returned error \(code)."
        case .decodingFailed(let err):  return "Failed to parse data: \(err.localizedDescription)"
        }
    }
}

// MARK: - Service

final class NetworkService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.statusCode(http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
