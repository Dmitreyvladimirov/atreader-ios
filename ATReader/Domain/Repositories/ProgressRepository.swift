import Foundation

protocol ProgressRepository {
    func saveLocal(_ position: ReadingPosition) throws
    func loadLocal(workId: Int, chapterId: Int) throws -> ReadingPosition?
}
