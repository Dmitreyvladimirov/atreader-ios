import Foundation

final class NetworkClient {
    private let baseURL = URL(string: "https://api.author.today")!
    private let urlSession: URLSession
    private let authManager: AuthManager
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(urlSession: URLSession = .shared, authManager: AuthManager) {
        self.urlSession = urlSession
        self.authManager = authManager
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        body: Encodable? = nil,
        retryOn401: Bool = true
    ) async throws -> T {
        guard let requestURL = makeURL(for: endpoint) else {
            throw APIError(statusCode: -1, message: "Invalid request URL")
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authManager.bearerToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let (data, response) = try await urlSession.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

        if statusCode == 401, retryOn401 {
            throw APIError(statusCode: 401, message: "Unauthorized")
        }

        guard (200..<300).contains(statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError(statusCode: statusCode, message: message)
        }

        return try decoder.decode(T.self, from: data)
    }

    private func makeURL(for endpoint: Endpoint) -> URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = endpoint.path
        components?.queryItems = endpoint.queryItems
        return components?.url
    }
}
