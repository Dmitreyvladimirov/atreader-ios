import Foundation

private struct UpdateProgressRequestDTO: Encodable {
    let workId: Int
    let chapterId: Int
    let offset: Double
    let percent: Double
}

private struct SyncProgressResponseDTO: Decodable {
    let positions: [ReadingPositionDTO]
}

final class ReaderRepositoryImpl: ReaderRepository {
    private let api: NetworkClient

    init(api: NetworkClient) {
        self.api = api
    }

    func fetchWorkContent(workId: Int) async throws -> [Chapter] {
        let dto: WorkContentResponseDTO = try await api.request(.workContent(workId: workId))
        return dto.chapters.map { $0.toDomain(workId: workId) }
    }

    func fetchChapterText(workId: Int, chapterId: Int) async throws -> String {
        let dto: ChapterTextResponseDTO = try await api.request(.chapterText(workId: workId, chapterId: chapterId))
        return dto.text
    }

    func sendProgress(_ position: ReadingPosition) async throws {
        let body = UpdateProgressRequestDTO(
            workId: position.workId,
            chapterId: position.chapterId,
            offset: position.offset,
            percent: position.percent
        )
        let _: EmptyResponse = try await api.request(.updateProgress, body: body)
    }

    func syncProgress(since: Date?) async throws -> [ReadingPosition] {
        let dateString = since.map { ISO8601DateFormatter().string(from: $0) }
        let dto: SyncProgressResponseDTO = try await api.request(.syncProgress(lastSyncTime: dateString))
        return dto.positions.map { $0.toDomain() }
    }
}

struct EmptyResponse: Decodable {}
