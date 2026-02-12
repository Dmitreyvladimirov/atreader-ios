import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let loginUseCase: LoginUseCase
    private let loginWithWebSSOUseCase: LoginWithWebSSOUseCase

    init(loginUseCase: LoginUseCase, loginWithWebSSOUseCase: LoginWithWebSSOUseCase) {
        self.loginUseCase = loginUseCase
        self.loginWithWebSSOUseCase = loginWithWebSSOUseCase
    }

    func login(onSuccess: () -> Void) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password"
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

    func loginWithWebSSO(onSuccess: () -> Void) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await loginWithWebSSOUseCase.execute()
            errorMessage = nil
            onSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
