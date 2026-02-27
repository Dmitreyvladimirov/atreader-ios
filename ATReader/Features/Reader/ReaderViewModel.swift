import Foundation
import Combine

@MainActor
final class ReaderViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let readerRepository: ReaderRepository

    init(readerRepository: ReaderRepository) {
        self.readerRepository = readerRepository
    }

    func load(workId: Int, chapterId: Int) async {
        isLoading = true
        defer { isLoading = false }

        do {
            text = try await readerRepository.fetchChapterText(workId: workId, chapterId: chapterId)
            errorMessage = nil
        } catch {
            if let apiError = error as? APIError {
                errorMessage = apiError.userFacingMessage
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}
