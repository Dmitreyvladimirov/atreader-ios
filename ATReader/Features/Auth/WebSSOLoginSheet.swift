import SwiftUI
import WebKit

struct WebSSOLoginSheet: View {
    let isLoading: Bool
    let onCancel: () -> Void
    let onLoginCookieCaptured: (String) -> Void

    @State private var hasCapturedCookie = false
    @State private var helperText = "After successful sign-in, this screen will continue automatically."

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WebLoginView { cookies in
                    guard !hasCapturedCookie else { return }
                    guard let loginCookie = cookies.first(where: { $0.name == "LoginCookie" })?.value,
                          !loginCookie.isEmpty else {
                        return
                    }

                    hasCapturedCookie = true
                    helperText = "Login detected. Completing authorization..."
                    onLoginCookieCaptured(loginCookie)
                }

                HStack {
                    Text(helperText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .padding(.trailing)
                    }
                }
            }
            .navigationTitle("Author.Today Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { onCancel() }
                        .disabled(isLoading)
                }
            }
        }
    }
}

private struct WebLoginView: UIViewRepresentable {
    let onCookiesChanged: ([HTTPCookie]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCookiesChanged: onCookiesChanged)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator

        let request = URLRequest(url: URL(string: "https://author.today/account/login")!)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let onCookiesChanged: ([HTTPCookie]) -> Void

        init(onCookiesChanged: @escaping ([HTTPCookie]) -> Void) {
            self.onCookiesChanged = onCookiesChanged
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                self.onCookiesChanged(cookies)
            }
        }
    }
}

#Preview("Web SSO Sheet") {
    WebSSOLoginSheet(
        isLoading: false,
        onCancel: {},
        onLoginCookieCaptured: { _ in }
    )
}
