import Foundation

struct User: Equatable {
    let id: Int
    let username: String
    let avatarURL: URL?
    let isEmailConfirmed: Bool
}
