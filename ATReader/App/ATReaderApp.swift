import SwiftUI

@main
struct ATReaderApp: App {
    private let container: AppContainer
    @StateObject private var coordinator: AppCoordinator

    init() {
        let container = AppContainer()
        self.container = container
        _coordinator = StateObject(wrappedValue: AppCoordinator(authRepository: container.authRepository))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if coordinator.isAuthenticated {
                    LibraryView(
                        viewModel: LibraryViewModel(
                            fetchLibraryUseCase: FetchLibraryUseCase(libraryRepository: container.libraryRepository)
                        )
                    )
                } else {
                    LoginView(
                        viewModel: LoginViewModel(
                            loginUseCase: LoginUseCase(authRepository: container.authRepository)
                        ),
                        onSuccess: coordinator.didLogin
                    )
                }
            }
            .task {
                await coordinator.bootstrap()
            }
        }
    }
}
