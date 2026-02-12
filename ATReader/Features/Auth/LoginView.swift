import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    let onSuccess: () -> Void

    var body: some View {
        NavigationStack {
            Form {
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
        }
    }
}
