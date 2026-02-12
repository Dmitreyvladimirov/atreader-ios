import Foundation
import Combine

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published private(set) var works: [Work] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let fetchLibraryUseCase: FetchLibraryUseCase

    init(fetchLibraryUseCase: FetchLibraryUseCase) {
        self.fetchLibraryUseCase = fetchLibraryUseCase
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            works = try await fetchLibraryUseCase.execute()
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
