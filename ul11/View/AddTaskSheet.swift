import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FirestoreViewModel
    
    @State private var newTaskTitle = ""
    @State private var newTaskCategory = ""
    @State private var newTaskNote = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Добавить задачу").font(.headline)) {
                    TextField("Название задачи", text: $newTaskTitle)
                        .textFieldStyle(GlassTextFieldStyle())

                    TextField("Категория", text: $newTaskCategory)
                        .textFieldStyle(GlassTextFieldStyle())
                }
                .listRowBackground(Color.clear)

                Section(header: Text("Заметка").font(.headline)) {
                    TextEditor(text: $newTaskNote)
                        .frame(height: 100)
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                        .listRowBackground(Color.clear)
                }
                .listRowBackground(Color.clear)

                Section {
                    Button("Добавить") {
                        guard !newTaskTitle.isEmpty else { return }
                        viewModel.addTask(
                            title: newTaskTitle,
                            category: newTaskCategory,
                            note: newTaskNote.isEmpty ? nil : newTaskNote
                        )
                        dismiss()
                    }
                    .buttonStyle(GlassButtonStyle(backgroundColor: .blue))
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)
            .navigationTitle("Новая задача")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
