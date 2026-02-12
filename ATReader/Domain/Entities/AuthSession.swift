import Foundation

struct AuthSession: Equatable, Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date
    let userId: Int?
}
