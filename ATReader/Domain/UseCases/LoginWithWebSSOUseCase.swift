import Foundation

struct LoginWithWebSSOUseCase {
    let authRepository: AuthRepository

    func execute(loginCookie: String) async throws {
        _ = try await authRepository.loginWithWebSSO(loginCookie: loginCookie)
    }
}
