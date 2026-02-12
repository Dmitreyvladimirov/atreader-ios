import Foundation

protocol ReaderRepository {
    func fetchWorkContent(workId: Int) async throws -> [Chapter]
    func fetchChapterText(workId: Int, chapterId: Int) async throws -> String
    func sendProgress(_ position: ReadingPosition) async throws
    func syncProgress(since: Date?) async throws -> [ReadingPosition]
}
