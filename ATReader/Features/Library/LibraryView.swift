import SwiftUI

struct LibraryView: View {
    @StateObject var viewModel: LibraryViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.works.isEmpty {
                    ProgressView("Loading library")
                } else if let errorMessage = viewModel.errorMessage, viewModel.works.isEmpty {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else {
                    List(viewModel.works) { work in
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
            .navigationTitle("Library")
            .task { await viewModel.refresh() }
            .refreshable { await viewModel.refresh() }
        }
    }
}
