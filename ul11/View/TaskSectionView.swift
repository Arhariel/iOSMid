import Foundation
import SwiftUI

struct TaskSectionView: View {
    let category: String
    let tasks: [Task]
    let viewModel: FirestoreViewModel

    var body: some View {
        Section(header: Text(category).font(.headline)) {
            ForEach(tasks) { task in
                TaskRowView(task: task, viewModel: viewModel)
            }
        }
    }
}
