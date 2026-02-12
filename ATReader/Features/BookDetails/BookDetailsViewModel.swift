import Foundation
import Combine

@MainActor
final class BookDetailsViewModel: ObservableObject {
    @Published private(set) var chapters: [Chapter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let fetchWorkContentUseCase: FetchWorkContentUseCase

    init(fetchWorkContentUseCase: FetchWorkContentUseCase) {
        self.fetchWorkContentUseCase = fetchWorkContentUseCase
    }

    func load(workId: Int) async {
        isLoading = true
        defer { isLoading = false }

        do {
            chapters = try await fetchWorkContentUseCase.execute(workId: workId)
                .sorted(by: { $0.order < $1.order })
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
