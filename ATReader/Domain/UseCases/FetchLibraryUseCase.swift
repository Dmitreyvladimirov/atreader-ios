import Foundation

struct FetchLibraryUseCase {
    let libraryRepository: LibraryRepository

    func execute(page: Int = 1, pageSize: Int = 20) async throws -> [Work] {
        try await libraryRepository.fetchLibrary(page: page, pageSize: pageSize)
    }
}
