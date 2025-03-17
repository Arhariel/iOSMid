import Foundation
import SwiftUI

struct TaskRowView: View {
    let task: Task
    let viewModel: FirestoreViewModel

    var body: some View {
        NavigationLink(destination: TaskDetailView(viewModel: viewModel, task: task)) {
            Text(task.title)
                .font(.headline)
                .padding(12)
                .background(.ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .listRowBackground(Color.clear)
    }
}
