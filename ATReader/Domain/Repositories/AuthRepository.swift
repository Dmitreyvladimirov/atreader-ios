import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> AuthSession
    func loginWithWebSSO(loginCookie: String) async throws -> AuthSession
    func refreshToken() async throws -> AuthSession
    func logout() async throws
    func currentSession() async -> AuthSession?
}
