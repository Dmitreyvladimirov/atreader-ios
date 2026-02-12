import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    let onSuccess: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                ATTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar

                    ScrollView {
                        VStack(spacing: 18) {
                            credentialsBlock
                            actionButtons
                            socialDivider
                            socialButtons
                            forgotPassword
                        }
                        .padding(20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.isWebLoginPresented) {
                WebSSOLoginSheet(
                    isLoading: viewModel.isLoading,
                    onCancel: { viewModel.isWebLoginPresented = false },
                    onLoginCookieCaptured: { cookie in
                        Task { await viewModel.completeWebSSO(loginCookie: cookie, onSuccess: onSuccess) }
                    }
                )
            }
        }
    }

    private var topBar: some View {
        HStack {
            Text("Authorization")
                .font(.system(size: 38, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white)
            Spacer()
            Image(systemName: "xmark")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(ATTheme.brandBlue)
    }

    private var credentialsBlock: some View {
        VStack(spacing: 14) {
            iconField(systemName: "person.fill", placeholder: "Email", text: $viewModel.email)
            iconSecureField(systemName: "lock.fill", placeholder: "Password", text: $viewModel.password)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(viewModel.isLoading ? "Signing in..." : "Sign in") {
                Task { await viewModel.login(onSuccess: onSuccess) }
            }
            .buttonStyle(ATFilledButtonStyle(background: ATTheme.successGreen))
            .disabled(viewModel.isLoading)

            Button("Register") {}
                .buttonStyle(ATOutlineButtonStyle())
        }
    }

    private var socialDivider: some View {
        HStack(spacing: 10) {
            Rectangle().fill(ATTheme.textSecondary.opacity(0.35)).frame(height: 1)
            Text("Sign in via social")
                .font(.title3)
                .foregroundStyle(ATTheme.textSecondary)
            Rectangle().fill(ATTheme.textSecondary.opacity(0.35)).frame(height: 1)
        }
        .padding(.top, 6)
    }

    private var socialButtons: some View {
        VStack(spacing: 10) {
            Button {
                viewModel.beginWebSSO()
            } label: {
                Label("VK ID", systemImage: "person.crop.circle.badge.checkmark")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ATFilledButtonStyle(background: Color(red: 0.08, green: 0.47, blue: 0.92)))

            HStack(spacing: 10) {
                Button("Google") { viewModel.beginWebSSO() }
                    .buttonStyle(ATOutlineButtonStyle())
                Button("Yandex ID") { viewModel.beginWebSSO() }
                    .buttonStyle(ATFilledButtonStyle(background: .black))
            }
        }
    }

    private var forgotPassword: some View {
        Button("Forgot password?") {}
            .font(.title3)
            .foregroundStyle(ATTheme.brandBlue)
            .padding(.top, 8)
    }

    private func iconField(systemName: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .foregroundStyle(ATTheme.textSecondary)
                .frame(width: 24)
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func iconSecureField(systemName: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .foregroundStyle(ATTheme.textSecondary)
                .frame(width: 24)
            SecureField(placeholder, text: text)
            Image(systemName: "eye")
                .foregroundStyle(ATTheme.textSecondary)
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ATFilledButtonStyle: ButtonStyle {
    var background: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(background.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ATOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(ATTheme.brandBlue)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(configuration.isPressed ? 0.7 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ATTheme.textSecondary.opacity(0.25), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("Login") {
    LoginView(
        viewModel: LoginViewModel(
            loginUseCase: LoginUseCase(authRepository: LoginPreviewAuthRepository()),
            loginWithWebSSOUseCase: LoginWithWebSSOUseCase(authRepository: LoginPreviewAuthRepository())
        ),
        onSuccess: {}
    )
}

private struct LoginPreviewAuthRepository: AuthRepository {
    func login(email: String, password: String) async throws -> AuthSession {
        AuthSession(accessToken: "preview", refreshToken: nil, expiresAt: .now.addingTimeInterval(3600), userId: 1)
    }

    func loginWithWebSSO(loginCookie: String) async throws -> AuthSession {
        AuthSession(accessToken: "preview", refreshToken: nil, expiresAt: .now.addingTimeInterval(3600), userId: 1)
    }

    func refreshToken() async throws -> AuthSession {
        AuthSession(accessToken: "preview", refreshToken: nil, expiresAt: .now.addingTimeInterval(3600), userId: 1)
    }

    func logout() async throws {}

    func currentSession() async -> AuthSession? {
        nil
    }
}
