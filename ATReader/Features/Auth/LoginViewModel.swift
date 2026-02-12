import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isWebLoginPresented = false

    private let loginUseCase: LoginUseCase
    private let loginWithWebSSOUseCase: LoginWithWebSSOUseCase

    init(loginUseCase: LoginUseCase, loginWithWebSSOUseCase: LoginWithWebSSOUseCase) {
        self.loginUseCase = loginUseCase
        self.loginWithWebSSOUseCase = loginWithWebSSOUseCase
    }

    func login(onSuccess: () -> Void) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = String(localized: "login.error.empty_credentials")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await loginUseCase.execute(email: email, password: password)
            errorMessage = nil
            onSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func beginWebSSO() {
        errorMessage = nil
        isWebLoginPresented = true
    }

    func completeWebSSO(loginCookie: String, onSuccess: () -> Void) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await loginWithWebSSOUseCase.execute(loginCookie: loginCookie)
            errorMessage = nil
            isWebLoginPresented = false
            onSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
