import Foundation

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

struct AuthSessionDTO: Decodable {
    let token: String
    let refreshToken: String?
    let expiresAt: Date
    let userId: Int?

    func toDomain() -> AuthSession {
        AuthSession(
            accessToken: token,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            userId: userId
        )
    }
}
