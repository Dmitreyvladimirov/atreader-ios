import Foundation

final class InMemoryProgressRepository: ProgressRepository {
    private var storage: [String: ReadingPosition] = [:]

    func saveLocal(_ position: ReadingPosition) throws {
        let key = "\(position.workId)-\(position.chapterId)"
        storage[key] = position
    }

    func loadLocal(workId: Int, chapterId: Int) throws -> ReadingPosition? {
        storage["\(workId)-\(chapterId)"]
    }
}
