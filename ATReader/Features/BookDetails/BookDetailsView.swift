import SwiftUI

struct BookDetailsView: View {
    let work: Work
    @StateObject var viewModel: BookDetailsViewModel
    let readerRepository: ReaderRepository

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                topCoverCard
                statsRow
                actionsRow
                descriptionBlock
                tocCard
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
        }
        .background(ATTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(work.title)
                    .font(.headline)
                    .lineLimit(1)
            }
        }
        .task {
            await viewModel.load(workId: work.id)
        }
    }

    private var topCoverCard: some View {
        HStack(alignment: .top, spacing: 14) {
            AsyncImage(url: work.coverURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 126, height: 182)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 8) {
                Text(work.title)
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundStyle(ATTheme.textPrimary)
                    .lineLimit(3)
                Text(work.authorName)
                    .font(.title3)
                    .foregroundStyle(ATTheme.brandBlue)

                HStack(spacing: 8) {
                    Label("In progress", systemImage: "pencil")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(ATTheme.brandBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("Yesterday")
                        .font(.subheadline)
                        .foregroundStyle(ATTheme.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(number: "882", title: "Likes")
            Divider()
            statItem(number: "165", title: "Awards")
            Divider()
            statItem(number: "78", title: "Comments")
        }
        .frame(height: 82)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func statItem(number: String, title: String) -> some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.title3.weight(.semibold))
            Text(title)
                .font(.subheadline)
                .foregroundStyle(ATTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var actionsRow: some View {
        HStack(spacing: 10) {
            Button("Gift 183 ₽") {}
                .buttonStyle(ATSecondaryActionStyle())

            if let first = viewModel.chapters.first {
                NavigationLink {
                    ReaderView(
                        viewModel: ReaderViewModel(readerRepository: readerRepository),
                        work: work,
                        chapters: viewModel.chapters,
                        initialChapterId: first.id
                    )
                } label: {
                    Text("Read")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ATPrimaryActionStyle())
            } else {
                Text("Read")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ATTheme.brandBlue.opacity(0.4))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }

    }

    private var descriptionBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Access paid")
                .font(.title3.weight(.semibold))
                .foregroundStyle(ATTheme.successGreen)

            Text("The one who hurts the tiger will be torn apart by it. A short sample description goes here to mimic the original card and spacing.")
                .font(.body)
                .foregroundStyle(ATTheme.textPrimary)

            Button("show all") {}
                .font(.title3)
                .foregroundStyle(ATTheme.brandBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var tocCard: some View {
        VStack(spacing: 0) {
            NavigationLink {
                TableOfContentsView(chapters: viewModel.chapters, selectedChapterId: viewModel.chapters.first?.id)
            } label: {
                rowLabel(title: "Table of Contents", trailing: "\(viewModel.chapters.count)")
            }
            Divider()
            rowLabel(title: "Information and Statistics", trailing: nil)
            Divider()
            rowLabel(title: "Series", trailing: "3")
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func rowLabel(title: String, trailing: String?) -> some View {
        HStack {
            Text(title)
                .font(.title3)
                .foregroundStyle(ATTheme.textPrimary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.headline)
                    .foregroundStyle(ATTheme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ATTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Image(systemName: "chevron.right")
                .foregroundStyle(ATTheme.textSecondary)
        }
        .padding(14)
    }
}

private struct ATPrimaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .background(ATTheme.brandBlue.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ATSecondaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(ATTheme.textPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .background(.white.opacity(configuration.isPressed ? 0.75 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ATTheme.textSecondary.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("Book Details") {
    NavigationStack {
        BookDetailsView(
            work: Work(id: 1001, title: "Merciless Healer. Vol. 3", authorName: "Konstantin Zaitsev", coverURL: nil),
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
            Chapter(id: 1, workId: workId, title: "Chapter 1", order: 1),
            Chapter(id: 2, workId: workId, title: "Chapter 2", order: 2),
            Chapter(id: 3, workId: workId, title: "Chapter 3", order: 3),
            Chapter(id: 4, workId: workId, title: "Chapter 4", order: 4)
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
