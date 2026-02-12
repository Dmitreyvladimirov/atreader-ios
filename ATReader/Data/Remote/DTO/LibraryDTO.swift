import Foundation

struct UserLibraryItemDTO: Decodable {
    let id: Int
    let title: String
    let authorName: String?
    let coverUrl: String?

    func toDomain() -> Work {
        Work(
            id: id,
            title: title,
            authorName: authorName ?? "Unknown",
            coverURL: coverUrl.flatMap(URL.init(string:))
        )
    }
}

struct UserLibraryResponseDTO: Decodable {
    let items: [UserLibraryItemDTO]
}
