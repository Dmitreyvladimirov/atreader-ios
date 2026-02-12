import Foundation

struct CurrentUserDTO: Decodable {
    let id: Int?
    let userName: String?
    let username: String?
    let name: String?
    let avatarUrl: String?
    let avatar: String?
    let isEmailConfirmed: Bool?

    func toDomain() -> User {
        User(
            id: id ?? 0,
            username: userName ?? username ?? name ?? "Unknown",
            avatarURL: URL(string: avatarUrl ?? avatar ?? ""),
            isEmailConfirmed: isEmailConfirmed ?? false
        )
    }
}
