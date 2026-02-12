import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let api: NetworkClient
    private let authManager: AuthManager
    private let webSSOAuthService: WebSSOAuthService

    init(api: NetworkClient, authManager: AuthManager, webSSOAuthService: WebSSOAuthService) {
        self.api = api
        self.authManager = authManager
        self.webSSOAuthService = webSSOAuthService
    }

    func login(email: String, password: String) async throws -> AuthSession {
        let dto: AuthSessionDTO = try await api.request(
            .loginByPassword,
            body: LoginRequestDTO(email: email, password: password),
            retryOn401: false
        )
        let session = dto.toDomain()
        try authManager.updateSession(session)
        return session
    }

    func refreshToken() async throws -> AuthSession {
        let dto: AuthSessionDTO = try await api.request(.refreshToken, retryOn401: false)
        let session = dto.toDomain()
        try authManager.updateSession(session)
        return session
    }

    func loginWithWebSSO(loginCookie: String) async throws -> AuthSession {
        let session = try await webSSOAuthService.exchangeLoginCookieForSession(loginCookie: loginCookie)
        try authManager.updateSession(session)
        return session
    }

    func logout() async throws {
        try authManager.clear()
    }

    func currentSession() async -> AuthSession? {
        authManager.session
    }
}
