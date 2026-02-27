import SwiftUI

struct TableOfContentsView: View {
    let chapters: [Chapter]
    let onSelectChapter: ((Chapter) -> Void)?

    @State private var searchText = ""
    @State private var selectedId: Int?
    @Environment(\.dismiss) private var dismiss

    init(chapters: [Chapter], selectedChapterId: Int?, onSelectChapter: ((Chapter) -> Void)? = nil) {
        self.chapters = chapters.sorted(by: { $0.order < $1.order })
        self.onSelectChapter = onSelectChapter
        _selectedId = State(initialValue: selectedChapterId)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            searchRow
            List(filteredChapters) { chapter in
                Button {
                    selectedId = chapter.id
                    onSelectChapter?(chapter)
                    if onSelectChapter != nil {
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: selectedId == chapter.id ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(selectedId == chapter.id ? ATTheme.brandBlue : ATTheme.textSecondary)
                            .font(.title2)

                        Text(chapter.title)
                            .font(.title3)
                            .foregroundStyle(ATTheme.textPrimary)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(ATTheme.background)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
        .background(ATTheme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.white)
            }

            Text(String(localized: "toc.title"))
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(ATTheme.brandBlue)
    }

    private var searchRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ATTheme.textSecondary)
            TextField(String(localized: "toc.search.placeholder"), text: $searchText)
        }
        .padding(12)
        .background(ATTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(16)
    }

    private var filteredChapters: [Chapter] {
        if searchText.isEmpty { return chapters }
        return chapters.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}

#Preview("Table of Contents") {
    NavigationStack {
        TableOfContentsView(
            chapters: [
                Chapter(id: 1, workId: 1, title: "Chapter 1", order: 1),
                Chapter(id: 2, workId: 1, title: "Chapter 2", order: 2),
                Chapter(id: 3, workId: 1, title: "Chapter 3", order: 3),
                Chapter(id: 4, workId: 1, title: "Chapter 4", order: 4),
                Chapter(id: 5, workId: 1, title: "Chapter 5", order: 5),
                Chapter(id: 6, workId: 1, title: "Chapter 6", order: 6),
                Chapter(id: 7, workId: 1, title: "Chapter 7", order: 7),
                Chapter(id: 8, workId: 1, title: "Chapter 8", order: 8),
                Chapter(id: 9, workId: 1, title: "Chapter 9", order: 9)
            ],
            selectedChapterId: 9
        )
    }
}
