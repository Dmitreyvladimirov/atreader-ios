import SwiftUI

struct LibraryView: View {
    @StateObject var viewModel: LibraryViewModel
    let readerRepository: ReaderRepository

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.works.isEmpty {
                    ProgressView("Loading library")
                } else if let errorMessage = viewModel.errorMessage, viewModel.works.isEmpty {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else {
                    List(viewModel.works) { work in
                        NavigationLink {
                            BookDetailsView(
                                work: work,
                                viewModel: BookDetailsViewModel(
                                    fetchWorkContentUseCase: FetchWorkContentUseCase(readerRepository: readerRepository)
                                ),
                                readerRepository: readerRepository
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(work.title)
                                    .font(.headline)
                                Text(work.authorName)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Library")
            .task { await viewModel.refresh() }
            .refreshable { await viewModel.refresh() }
        }
    }
}

#Preview("Library") {
    LibraryView(
        viewModel: LibraryViewModel(
            fetchLibraryUseCase: FetchLibraryUseCase(libraryRepository: LibraryPreviewRepository())
        ),
        readerRepository: LibraryPreviewReaderRepository()
    )
}

private struct LibraryPreviewRepository: LibraryRepository {
    func fetchLibrary(page: Int, pageSize: Int) async throws -> [Work] {
        [
            Work(id: 1001, title: "The Last Orbit", authorName: "A. Writer", coverURL: nil),
            Work(id: 1002, title: "City of Brass", authorName: "B. Novelist", coverURL: nil),
            Work(id: 1003, title: "Cold Signal", authorName: "C. Author", coverURL: nil)
        ]
    }
}

private struct LibraryPreviewReaderRepository: ReaderRepository {
    func fetchWorkContent(workId: Int) async throws -> [Chapter] {
        [
            Chapter(id: 1, workId: workId, title: "Arrival", order: 1),
            Chapter(id: 2, workId: workId, title: "Signal", order: 2)
        ]
    }

    func fetchChapterText(workId: Int, chapterId: Int) async throws -> String {
        "Preview chapter text"
    }

    func sendProgress(_ position: ReadingPosition) async throws {}

    func syncProgress(since: Date?) async throws -> [ReadingPosition] {
        []
    }
}
