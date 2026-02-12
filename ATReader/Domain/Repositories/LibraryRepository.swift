import Foundation

protocol LibraryRepository {
    func fetchLibrary(page: Int, pageSize: Int) async throws -> [Work]
}
