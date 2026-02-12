import Foundation

final class LibraryRepositoryImpl: LibraryRepository {
    private let api: NetworkClient

    init(api: NetworkClient) {
        self.api = api
    }

    func fetchLibrary(page: Int, pageSize: Int) async throws -> [Work] {
        let dto: UserLibraryResponseDTO = try await api.request(.userLibrary(page: page, pageSize: pageSize))
        return dto.items.map { $0.toDomain() }
    }
}
