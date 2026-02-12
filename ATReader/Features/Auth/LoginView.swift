import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    let onSuccess: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Single Sign-On") {
                    Button("Sign in with Author.Today web login") {
                        viewModel.beginWebSSO()
                    }
                    .disabled(viewModel.isLoading)
                }

                Section("Credentials") {
                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    SecureField("Password", text: $viewModel.password)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                Button(viewModel.isLoading ? "Signing in..." : "Sign in") {
                    Task { await viewModel.login(onSuccess: onSuccess) }
                }
                .disabled(viewModel.isLoading)
            }
            .navigationTitle("Author.Today")
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
}
