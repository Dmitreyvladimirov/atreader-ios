import Foundation

protocol AccountRepository {
    func currentUser() async throws -> User
}
