import Foundation

final class AccountRepositoryImpl: AccountRepository {
    private let api: NetworkClient

    init(api: NetworkClient) {
        self.api = api
    }

    func currentUser() async throws -> User {
        let dto: CurrentUserDTO = try await api.request(.currentUser)
        return dto.toDomain()
    }
}
