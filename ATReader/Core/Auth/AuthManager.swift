import Foundation

final class AuthManager {
    private let tokenStore: TokenStore
    private(set) var session: AuthSession?

    init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore
        self.session = try? tokenStore.load()
    }

    func bearerToken() -> String? {
        session?.accessToken
    }

    func updateSession(_ newSession: AuthSession) throws {
        session = newSession
        try tokenStore.save(newSession)
    }

    func clear() throws {
        session = nil
        try tokenStore.clear()
    }
}
