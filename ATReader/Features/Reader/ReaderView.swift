import SwiftUI

struct ReaderView: View {
    @StateObject var viewModel: ReaderViewModel
    let work: Work
    let chapters: [Chapter]
    let initialChapterId: Int

    @State private var currentChapterId: Int
    @State private var isTOCPresented = false
    @Environment(\.dismiss) private var dismiss

    init(viewModel: @autoclosure @escaping () -> ReaderViewModel, work: Work, chapters: [Chapter], initialChapterId: Int) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.work = work
        self.chapters = chapters
        self.initialChapterId = initialChapterId
        _currentChapterId = State(initialValue: initialChapterId)
    }

    var body: some View {
        ZStack {
            ATTheme.background.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView(String(localized: "reader.loading"))
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    ContentUnavailableView(
                        String(localized: "common.error"),
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                    Button(String(localized: "common.retry")) {
                        Task { await viewModel.load(workId: work.id, chapterId: currentChapterId) }
                    }
                }
            } else {
                ScrollView {
                    VStack(alignment: .center, spacing: 24) {
                        Text(work.title)
                            .font(.system(size: 28, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(ATTheme.textPrimary)

                        Text(currentChapterTitle)
                            .font(ATTheme.titleFont(64))
                            .foregroundStyle(ATTheme.textPrimary)

                        Text(viewModel.text)
                            .font(.system(size: 21, weight: .regular, design: .rounded))
                            .lineSpacing(8)
                            .foregroundStyle(ATTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Image(systemName: "gearshape")
                    .foregroundStyle(.white)

                Button {
                    isTOCPresented = true
                } label: {
                    Image(systemName: "list.bullet")
                        .foregroundStyle(.white)
                }

                Image(systemName: "ellipsis.vertical")
                    .foregroundStyle(.white)
            }
        }
        .toolbarBackground(ATTheme.brandBlue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isTOCPresented) {
            NavigationStack {
                TableOfContentsView(chapters: chapters, selectedChapterId: currentChapterId) { chapter in
                    currentChapterId = chapter.id
                }
            }
        }
        .task {
            await viewModel.load(workId: work.id, chapterId: currentChapterId)
        }
        .onChange(of: currentChapterId) { _, newValue in
            Task { await viewModel.load(workId: work.id, chapterId: newValue) }
        }
    }

    private var currentChapterTitle: String {
        let chapter = chapters.first(where: { $0.id == currentChapterId })
        return chapter?.title ?? String(localized: "reader.chapter.default")
    }
}

#Preview("Reader") {
    NavigationStack {
        ReaderView(
            viewModel: ReaderViewModel(readerRepository: ReaderPreviewRepository()),
            work: Work(id: 1001, title: "Merciless Healer. Vol. 3", authorName: "Konstantin Zaitsev", coverURL: nil),
            chapters: [
                Chapter(id: 7, workId: 1001, title: "Chapter 7", order: 7),
                Chapter(id: 8, workId: 1001, title: "Chapter 8", order: 8),
                Chapter(id: 9, workId: 1001, title: "Chapter 9", order: 9)
            ],
            initialChapterId: 9
        )
    }
}

private struct ReaderPreviewRepository: ReaderRepository {
    func fetchWorkContent(workId: Int) async throws -> [Chapter] {
        [Chapter(id: 9, workId: workId, title: "Chapter 9", order: 9)]
    }

    func fetchChapterText(workId: Int, chapterId: Int) async throws -> String {
        """
        The way back was remembered in fragments, as if I had taken too much cheap wine.

        I remembered hands on my face, a tired laugh in the dark, and then a gray veil pulling me away.
        """
    }

    func sendProgress(_ position: ReadingPosition) async throws {}

    func syncProgress(since: Date?) async throws -> [ReadingPosition] {
        []
    }
}
