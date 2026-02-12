import AuthenticationServices
import Foundation
import UIKit

enum WebSSOAuthError: LocalizedError {
    case invalidLoginURL
    case noCallbackURL
    case missingToken
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .invalidLoginURL:
            return "Failed to build login URL"
        case .noCallbackURL:
            return "SSO callback was not received"
        case .missingToken:
            return "Bearer token was not returned"
        case .malformedResponse:
            return "Unexpected bearer-token response format"
        }
    }
}

final class WebSSOAuthService: NSObject {
    private let callbackScheme = "atreader"
    private let callbackHost = "auth-callback"
    private let loginBaseURL = URL(string: "https://author.today/account/login")!
    private let bearerTokenURL = URL(string: "https://author.today/account/bearer-token")!
    private var session: ASWebAuthenticationSession?
    private lazy var presentationProvider = WebSSOPresentationContextProvider()

    func authenticate() async throws -> AuthSession {
        let callbackURL = "\(callbackScheme)://\(callbackHost)"

        var components = URLComponents(url: loginBaseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "returnUrl", value: callbackURL)
        ]

        guard let loginURL = components?.url else {
            throw WebSSOAuthError.invalidLoginURL
        }

        let resolvedCallbackURL = try await startAuthSession(loginURL: loginURL)

        if let token = extractToken(from: resolvedCallbackURL) {
            return makeSession(token: token)
        }

        let token = try await requestBearerTokenFromCookie()
        return makeSession(token: token)
    }

    private func startAuthSession(loginURL: URL) async throws -> URL? {
        try await withCheckedThrowingContinuation { continuation in
            let authSession = ASWebAuthenticationSession(
                url: loginURL,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: callbackURL)
            }

            authSession.prefersEphemeralWebBrowserSession = false
            authSession.presentationContextProvider = presentationProvider
            self.session = authSession

            if !authSession.start() {
                continuation.resume(throwing: WebSSOAuthError.noCallbackURL)
            }
        }
    }

    private func extractToken(from callbackURL: URL?) -> String? {
        guard let callbackURL else { return nil }
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false) else { return nil }

        let queryToken = components.queryItems?.first(where: { $0.name == "token" || $0.name == "access_token" })?.value
        if let queryToken, !queryToken.isEmpty {
            return queryToken
        }

        if let fragment = components.fragment {
            let pairs = fragment.split(separator: "&")
            for pair in pairs {
                let parts = pair.split(separator: "=", maxSplits: 1)
                guard parts.count == 2 else { continue }
                if parts[0] == "token" || parts[0] == "access_token" {
                    return String(parts[1])
                }
            }
        }

        return nil
    }

    private func requestBearerTokenFromCookie() async throws -> String {
        var request = URLRequest(url: bearerTokenURL)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(statusCode) else {
            throw APIError(statusCode: statusCode, message: String(data: data, encoding: .utf8) ?? "Unable to load bearer token")
        }

        if let dto = try? JSONDecoder().decode(BearerTokenResponseDTO.self, from: data), !dto.token.isEmpty {
            return dto.token
        }

        if let raw = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty {
            if raw.hasPrefix("{") {
                throw WebSSOAuthError.malformedResponse
            }
            return raw.replacingOccurrences(of: "\"", with: "")
        }

        throw WebSSOAuthError.missingToken
    }

    private func makeSession(token: String) -> AuthSession {
        AuthSession(
            accessToken: token,
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            userId: nil
        )
    }
}

private final class WebSSOPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
