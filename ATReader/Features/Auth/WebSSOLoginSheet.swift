import SwiftUI
import WebKit

struct WebSSOLoginSheet: View {
    let isLoading: Bool
    let onCancel: () -> Void
    let onLoginCookieCaptured: (String) -> Void

    @State private var loginCookieValue: String?
    @State private var helperText = String(localized: "sso.helper.initial")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WebLoginView { cookies in
                    guard let loginCookie = cookies.first(where: { $0.name == "LoginCookie" && $0.domain.contains("author.today") })?.value,
                          !loginCookie.isEmpty else {
                        return
                    }
                    loginCookieValue = loginCookie
                    helperText = String(localized: "sso.helper.ready")
                }

                VStack(spacing: 10) {
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

                    Button(String(localized: "sso.continue")) {
                        guard let cookie = loginCookieValue else { return }
                        helperText = String(localized: "sso.helper.completing")
                        onLoginCookieCaptured(cookie)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading || loginCookieValue == nil)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle(String(localized: "sso.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.close")) { onCancel() }
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
