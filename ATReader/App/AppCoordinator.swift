import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false

    private let authRepository: AuthRepository
    private let accountRepository: AccountRepository

    init(authRepository: AuthRepository, accountRepository: AccountRepository) {
        self.authRepository = authRepository
        self.accountRepository = accountRepository
    }

    func bootstrap() async {
        guard await authRepository.currentSession() != nil else {
            isAuthenticated = false
            return
        }

        do {
            _ = try await accountRepository.currentUser()
            isAuthenticated = true
        } catch {
            try? await authRepository.logout()
            isAuthenticated = false
        }
    }

    func didLogin() {
        isAuthenticated = true
    }

    func didLogout() {
        isAuthenticated = false
    }
}
