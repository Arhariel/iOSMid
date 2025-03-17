import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var viewModel: FirestoreViewModel
    var task: Task
    @State private var title: String = ""
    @State private var note: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Редактировать задачу").font(.headline)) {
                TextField("Название задачи", text: $title)
                    .textFieldStyle(GlassTextFieldStyle())
            }
            .listRowBackground(Color.clear)
            
            Section(header: Text("Заметка").font(.headline)) {
                TextEditor(text: $note)
                    .frame(height: 100)
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
            }
            .listRowBackground(Color.clear)
            
            Section {
                Button(action: {
                    viewModel.updateTask(task: task, newTitle: title, newNote: note)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Сохранить изменения")
                        .font(.headline)
                }
                .buttonStyle(GlassButtonStyle(backgroundColor: .green))
                .disabled(title.isEmpty)
            }
            .listRowBackground(Color.clear)
            
            Section {
                Button(role: .destructive, action: {
                    viewModel.deleteTask(task: task)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Удалить задачу")
                        .font(.headline)
                }
                .buttonStyle(GlassButtonStyle(backgroundColor: .red))
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Детали задачи")
        .onAppear {
            self.title = task.title
            self.note = task.note ?? ""
        }
        .background(.ultraThinMaterial)
    }
}
