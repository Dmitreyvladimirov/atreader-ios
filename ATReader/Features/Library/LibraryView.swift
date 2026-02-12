import SwiftUI

struct LibraryView: View {
    @StateObject var viewModel: LibraryViewModel
    let readerRepository: ReaderRepository

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                ATTheme.background.ignoresSafeArea()

                if viewModel.isLoading && viewModel.works.isEmpty {
                    ProgressView("Loading library")
                } else if let errorMessage = viewModel.errorMessage, viewModel.works.isEmpty {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            topBar
                            shelfRow

                            LazyVGrid(columns: columns, spacing: 18) {
                                ForEach(viewModel.works) { work in
                                    NavigationLink {
                                        BookDetailsView(
                                            work: work,
                                            viewModel: BookDetailsViewModel(
                                                fetchWorkContentUseCase: FetchWorkContentUseCase(readerRepository: readerRepository)
                                            ),
                                            readerRepository: readerRepository
                                        )
                                    } label: {
                                        LibraryBookCard(work: work)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.bottom, 20)
                        }
                    }
                    .refreshable { await viewModel.refresh() }
                }
            }
            .task { await viewModel.refresh() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var topBar: some View {
        VStack(spacing: 14) {
            HStack(spacing: 18) {
                Image(systemName: "line.3.horizontal")
                Spacer()
                Image(systemName: "magnifyingglass")
                Image(systemName: "envelope")
                Image(systemName: "bell")
                Image(systemName: "message")
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 30, height: 30)
            }
            .font(.title3)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.top, 12)

            HStack {
                Text("My Library")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundStyle(ATTheme.textPrimary)
                Spacer()
                RoundedIconButton(systemName: "line.3.horizontal.decrease.circle")
                RoundedIconButton(systemName: "line.3.horizontal.decrease")
            }
            .padding(.horizontal, 14)
        }
        .padding(.bottom, 8)
        .background(ATTheme.brandBlue)
    }

    private var shelfRow: some View {
        HStack {
            Label("Reading / Listening", systemImage: "bookmark")
                .font(.title3.weight(.semibold))
                .foregroundStyle(ATTheme.textPrimary)
            Spacer()
            Text("\(viewModel.works.count)")
                .font(.headline)
                .foregroundStyle(ATTheme.textSecondary)
            Image(systemName: "chevron.right")
                .foregroundStyle(ATTheme.textSecondary)
        }
        .padding(14)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(ATTheme.textSecondary.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 14)
    }
}

private struct RoundedIconButton: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.headline)
            .foregroundStyle(ATTheme.textPrimary)
            .frame(width: 42, height: 42)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ATTheme.textSecondary.opacity(0.15), lineWidth: 1)
            )
    }
}

private struct LibraryBookCard: View {
    let work: Work

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: work.coverURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.18))
            }
            .frame(height: 152)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(work.title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(ATTheme.textPrimary)
                .lineLimit(3)

            Text(work.authorName)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(ATTheme.textSecondary)
                .lineLimit(2)
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
            Work(id: 1001, title: "Merciless Healer. Volume 3", authorName: "Konstantin Zaitsev", coverURL: nil),
            Work(id: 1002, title: "Legacy Return (Rein 9)", authorName: "Val Veden", coverURL: nil),
            Work(id: 1003, title: "Emptyland", authorName: "Mikhail Ignatov", coverURL: nil),
            Work(id: 1004, title: "I came back to burn his house. Volume 2", authorName: "Storbash N.B.", coverURL: nil),
            Work(id: 1005, title: "Lost Tomorrow", authorName: "Sergey Lukyanenko", coverURL: nil)
        ]
    }
}

private struct LibraryPreviewReaderRepository: ReaderRepository {
    func fetchWorkContent(workId: Int) async throws -> [Chapter] {
        [
            Chapter(id: 1, workId: workId, title: "Chapter 1", order: 1),
            Chapter(id: 2, workId: workId, title: "Chapter 2", order: 2),
            Chapter(id: 3, workId: workId, title: "Chapter 3", order: 3)
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
