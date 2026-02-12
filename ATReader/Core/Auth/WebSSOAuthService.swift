import Foundation

enum WebSSOAuthError: LocalizedError {
    case missingLoginCookie
    case missingToken
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .missingLoginCookie:
            return "LoginCookie not found. Finish sign-in in web view first."
        case .missingToken:
            return "Bearer token was not returned"
        case .malformedResponse:
            return "Unexpected bearer-token response format"
        }
    }
}

final class WebSSOAuthService {
    private let bearerTokenURL = URL(string: "https://author.today/account/bearer-token")!

    func exchangeLoginCookieForSession(loginCookie: String) async throws -> AuthSession {
        guard !loginCookie.isEmpty else {
            throw WebSSOAuthError.missingLoginCookie
        }

        let config = URLSessionConfiguration.ephemeral
        let cookieStorage = HTTPCookieStorage()
        config.httpCookieStorage = cookieStorage

        if let cookie = HTTPCookie(properties: [
            .domain: "author.today",
            .path: "/",
            .name: "LoginCookie",
            .value: loginCookie,
            .secure: "TRUE",
            .expires: Date().addingTimeInterval(60 * 15)
        ]) {
            cookieStorage.setCookie(cookie)
        }

        var request = URLRequest(url: bearerTokenURL)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession(configuration: config).data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(statusCode) else {
            throw APIError(
                statusCode: statusCode,
                message: String(data: data, encoding: .utf8) ?? "Unable to load bearer token"
            )
        }

        let token = try parseToken(data: data)
        return AuthSession(
            accessToken: token,
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            userId: nil
        )
    }

    private func parseToken(data: Data) throws -> String {
        if let dto = try? JSONDecoder().decode(BearerTokenResponseDTO.self, from: data), !dto.token.isEmpty {
            return normalizeToken(dto.token)
        }

        if let raw = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty {
            if raw.hasPrefix("{") {
                throw WebSSOAuthError.malformedResponse
            }
            return normalizeToken(raw.replacingOccurrences(of: "\"", with: ""))
        }

        throw WebSSOAuthError.missingToken
    }

    private func normalizeToken(_ token: String) -> String {
        let cleaned = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.lowercased().hasPrefix("bearer ") {
            return String(cleaned.dropFirst(7))
        }
        return cleaned
    }
}
