import Foundation

struct ReadingPosition: Equatable, Codable {
    let workId: Int
    let chapterId: Int
    let offset: Double
    let percent: Double
    let updatedAt: Date
}
