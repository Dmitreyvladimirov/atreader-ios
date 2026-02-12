import SwiftUI

struct BookDetailsView: View {
    let work: Work
    @StateObject var viewModel: BookDetailsViewModel
    let readerRepository: ReaderRepository

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.chapters.isEmpty {
                ProgressView("Loading chapters")
            } else if let errorMessage = viewModel.errorMessage, viewModel.chapters.isEmpty {
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            } else {
                List(viewModel.chapters) { chapter in
                    NavigationLink {
                        ReaderView(
                            viewModel: ReaderViewModel(readerRepository: readerRepository),
                            workId: work.id,
                            chapterId: chapter.id
                        )
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Chapter \(chapter.order)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(chapter.title)
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .navigationTitle(work.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load(workId: work.id)
        }
    }
}

#Preview("Book Details") {
    NavigationStack {
        BookDetailsView(
            work: Work(id: 1001, title: "The Last Orbit", authorName: "A. Writer", coverURL: nil),
            viewModel: BookDetailsViewModel(
                fetchWorkContentUseCase: FetchWorkContentUseCase(readerRepository: BookDetailsPreviewReaderRepository())
            ),
            readerRepository: BookDetailsPreviewReaderRepository()
        )
    }
}

private struct BookDetailsPreviewReaderRepository: ReaderRepository {
    func fetchWorkContent(workId: Int) async throws -> [Chapter] {
        [
            Chapter(id: 1, workId: workId, title: "Arrival", order: 1),
            Chapter(id: 2, workId: workId, title: "Signal", order: 2),
            Chapter(id: 3, workId: workId, title: "Drift", order: 3)
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
