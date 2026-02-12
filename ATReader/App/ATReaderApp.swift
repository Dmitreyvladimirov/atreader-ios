import SwiftUI

@main
struct ATReaderApp: App {
    private let container: AppContainer
    @StateObject private var coordinator: AppCoordinator
    @AppStorage("app_theme") private var appTheme = "light"
    @AppStorage("app_language") private var appLanguage = "ru"

    init() {
        let container = AppContainer()
        self.container = container
        _coordinator = StateObject(
            wrappedValue: AppCoordinator(
                authRepository: container.authRepository,
                accountRepository: container.accountRepository
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if coordinator.isAuthenticated {
                    LibraryView(
                        viewModel: LibraryViewModel(
                            fetchLibraryUseCase: FetchLibraryUseCase(libraryRepository: container.libraryRepository)
                        ),
                        readerRepository: container.readerRepository
                    )
                } else {
                    LoginView(
                        viewModel: LoginViewModel(
                            loginUseCase: LoginUseCase(authRepository: container.authRepository),
                            loginWithWebSSOUseCase: LoginWithWebSSOUseCase(authRepository: container.authRepository)
                        ),
                        onSuccess: coordinator.didLogin
                    )
                }
            }
            .preferredColorScheme(appTheme == "dark" ? .dark : .light)
            .environment(\.locale, Locale(identifier: appLanguage))
            .task {
                await coordinator.bootstrap()
            }
        }
    }
}
