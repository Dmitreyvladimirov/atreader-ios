import Foundation

struct LoginWithWebSSOUseCase {
    let authRepository: AuthRepository

    func execute() async throws {
        _ = try await authRepository.loginWithWebSSO()
    }
}
