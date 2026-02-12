import Foundation

protocol TokenStore {
    func save(_ session: AuthSession) throws
    func load() throws -> AuthSession?
    func clear() throws
}
