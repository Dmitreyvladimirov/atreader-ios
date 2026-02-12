import Foundation

struct Work: Identifiable, Equatable {
    let id: Int
    let title: String
    let authorName: String
    let coverURL: URL?
}
