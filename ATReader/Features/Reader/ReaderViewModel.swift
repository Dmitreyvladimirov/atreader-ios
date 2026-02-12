import Foundation

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
            errorMessage = error.localizedDescription
        }
    }
}
