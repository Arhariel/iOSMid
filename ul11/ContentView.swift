import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = FirestoreViewModel()
    @State private var showAddTaskSheet = false

    var body: some View {
        NavigationView {
            VStack {
                let groupedTasks = Dictionary(grouping: viewModel.tasks, by: { $0.category.isEmpty ? "Без категории" : $0.category })

                List {
                    ForEach(groupedTasks.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category).font(.headline)) {
                            ForEach(groupedTasks[category] ?? []) { task in
                                NavigationLink(destination: TaskDetailView(viewModel: viewModel, task: task)) {
                                    Text(task.title)
                                        .font(.headline)
                                        .padding(12)
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Список задач")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTaskSheet.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchTasks()
        }
        .sheet(isPresented: $showAddTaskSheet) {
            AddTaskSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
