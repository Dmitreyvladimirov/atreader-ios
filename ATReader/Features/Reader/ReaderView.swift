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
