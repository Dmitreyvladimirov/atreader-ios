import Foundation

struct FetchWorkContentUseCase {
    let readerRepository: ReaderRepository

    func execute(workId: Int) async throws -> [Chapter] {
        try await readerRepository.fetchWorkContent(workId: workId)
    }
}
