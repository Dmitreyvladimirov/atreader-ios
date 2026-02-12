import SwiftUI

struct ReaderView: View {
    @StateObject var viewModel: ReaderViewModel
    let workId: Int
    let chapterId: Int

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading chapter")
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            } else {
                ScrollView {
                    Text(viewModel.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
        .navigationTitle("Reader")
        .task {
            await viewModel.load(workId: workId, chapterId: chapterId)
        }
    }
}

#Preview("Reader") {
    NavigationStack {
        ReaderView(
            viewModel: ReaderViewModel(readerRepository: ReaderPreviewRepository()),
            workId: 1,
            chapterId: 1
        )
    }
}

private struct ReaderPreviewRepository: ReaderRepository {
    func fetchWorkContent(workId: Int) async throws -> [Chapter] {
        [Chapter(id: 1, workId: workId, title: "Chapter 1", order: 1)]
    }

    func fetchChapterText(workId: Int, chapterId: Int) async throws -> String {
        """
        A thin line of light crossed the room.

        He reached for the terminal, reading the message one more time.
        Nothing had changed, except the hour and his confidence.
        """
    }

    func sendProgress(_ position: ReadingPosition) async throws {}

    func syncProgress(since: Date?) async throws -> [ReadingPosition] {
        []
    }
}
