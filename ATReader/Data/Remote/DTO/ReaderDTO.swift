import Foundation

struct WorkContentResponseDTO: Decodable {
    let chapters: [ChapterDTO]
}

struct ChapterDTO: Decodable {
    let id: Int
    let title: String
    let order: Int

    func toDomain(workId: Int) -> Chapter {
        Chapter(id: id, workId: workId, title: title, order: order)
    }
}

struct ChapterTextResponseDTO: Decodable {
    let text: String
}

struct ReadingPositionDTO: Codable {
    let workId: Int
    let chapterId: Int
    let offset: Double
    let percent: Double
    let updatedAt: Date

    func toDomain() -> ReadingPosition {
        ReadingPosition(
            workId: workId,
            chapterId: chapterId,
            offset: offset,
            percent: percent,
            updatedAt: updatedAt
        )
    }

    static func fromDomain(_ position: ReadingPosition) -> ReadingPositionDTO {
        ReadingPositionDTO(
            workId: position.workId,
            chapterId: position.chapterId,
            offset: position.offset,
            percent: position.percent,
            updatedAt: position.updatedAt
        )
    }
}
