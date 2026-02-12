import Foundation

struct LoginUseCase {
    let authRepository: AuthRepository

    func execute(email: String, password: String) async throws {
        _ = try await authRepository.login(email: email, password: password)
    }
}
