import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let api: NetworkClient
    private let authManager: AuthManager

    init(api: NetworkClient, authManager: AuthManager) {
        self.api = api
        self.authManager = authManager
    }

    func login(email: String, password: String) async throws -> AuthSession {
        let dto: AuthSessionDTO = try await api.request(
            .loginByPassword,
            body: LoginRequestDTO(email: email, password: password),
            retryOn401: false
        )
        let session = dto.toDomain()
        try await authManager.updateSession(session)
        return session
    }

    func refreshToken() async throws -> AuthSession {
        let dto: AuthSessionDTO = try await api.request(.refreshToken, retryOn401: false)
        let session = dto.toDomain()
        try await authManager.updateSession(session)
        return session
    }

    func logout() async throws {
        try await authManager.clear()
    }

    func currentSession() async -> AuthSession? {
        await authManager.session
    }
}
