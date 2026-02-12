import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func bootstrap() async {
        isAuthenticated = await authRepository.currentSession() != nil
    }

    func didLogin() {
        isAuthenticated = true
    }

    func didLogout() {
        isAuthenticated = false
    }
}
