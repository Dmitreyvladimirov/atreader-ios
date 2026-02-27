import Foundation

final class AppContainer {
    let authManager: AuthManager
    let authRepository: AuthRepository
    let accountRepository: AccountRepository
    let libraryRepository: LibraryRepository
    let readerRepository: ReaderRepository
    let progressRepository: ProgressRepository

    init() {
        let tokenStore = KeychainTokenStore(service: "app.author.today.ios")
        let authManager = AuthManager(tokenStore: tokenStore)
        let api = NetworkClient(authManager: authManager)
        let webSSOAuthService = WebSSOAuthService()

        self.authManager = authManager
        self.authRepository = AuthRepositoryImpl(api: api, authManager: authManager, webSSOAuthService: webSSOAuthService)
        self.accountRepository = AccountRepositoryImpl(api: api)
        self.libraryRepository = LibraryRepositoryImpl(api: api)
        self.readerRepository = ReaderRepositoryImpl(api: api)
        self.progressRepository = InMemoryProgressRepository()
    }
}
