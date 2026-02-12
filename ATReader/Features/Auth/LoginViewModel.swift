import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let loginUseCase: LoginUseCase

    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
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
}
