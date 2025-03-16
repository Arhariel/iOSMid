import Foundation
import FirebaseFirestore
import Combine

class FirestoreViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private var db = Firestore.firestore()
    
    func fetchTasks() {
        db.collection("tasks").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Нет документов в Firestore")
                return
            }
            self.tasks = documents.compactMap { doc -> Task? in
                try? doc.data(as: Task.self)
            }
        }
    }
    
    func addTask(title: String, category: String, note: String?) {
        let newTask = Task(title: title, category: category, note: note)
        do {
            _ = try db.collection("tasks").addDocument(from: newTask)
        } catch {
            print("Ошибка записи в Firestore: \(error)")
        }
    }
    
    func deleteTask(task: Task) {
        guard let taskId = task.id else { return }
        db.collection("tasks").document(taskId).delete { error in
            if let error = error {
                print("Ошибка удаления задачи: \(error)")
            } else {
                print("Задача успешно удалена")
            }
        }
    }
    
    func updateTask(task: Task, newTitle: String, newNote: String?) {
        guard let taskId = task.id else { return }
        var data: [String: Any] = ["title": newTitle]
        if let newNote = newNote {
            data["note"] = newNote
        }
        db.collection("tasks").document(taskId).updateData(data) { error in
            if let error = error {
                print("Ошибка обновления задачи: \(error)")
            } else {
                print("Задача успешно обновлена")
            }
        }
    }
}
