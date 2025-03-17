import XCTest
import Combine
import FirebaseCore
@testable import ul11

final class FirestoreViewModelIntegrationTests: XCTestCase {
    
    var viewModel: FirestoreViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        // Инициализируем Firebase один раз, если нужно
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        viewModel = FirestoreViewModel() // Ваш реальный init, который внутри использует Firestore.firestore()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        cancellables.removeAll()
    }
    
    // MARK: - Тест fetchTasks
    
    func testFetchTasks() {
        let expectation = XCTestExpectation(description: "Tasks are fetched from Firestore")
        
        // Подпишемся на обновления массива tasks
        viewModel.$tasks
            .dropFirst() // игнорируем начальное пустое значение
            .sink { tasks in
                // Проверяем, что массив обновился
                print("Fetched tasks: \(tasks)")
                // Например, хотим убедиться, что массив не пуст
                XCTAssertFalse(tasks.isEmpty, "Список задач не должен быть пустым (или проверьте логику).")
                
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        // Запускаем метод, который ходит в реальный Firestore
        viewModel.fetchTasks()
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Тест addTask
    
    func testAddTask() {
        let expectation = XCTestExpectation(description: "Newly added task appears in tasks array via snapshotListener")
        
        // Сгенерируем уникальное название, чтобы отличать задачу
        let randomTitle = "IntegrationTest-\(UUID().uuidString.prefix(5))"
        
        // Подпишемся на tasks и будем ждать, когда в массиве появится задача с нашим randomTitle
        viewModel.$tasks
            .dropFirst()
            .sink { tasks in
                if tasks.contains(where: { $0.title == randomTitle }) {
                    // Задача успешно добавлена и пришла в snapshotListener
                    print("✅ Task with title \(randomTitle) was added and observed in tasks.")
                    expectation.fulfill()
                }
            }
            .store(in: &self.cancellables)
        
        // Добавляем задачу
        viewModel.addTask(title: randomTitle, category: "TestCategory", note: "Some note")
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Тест deleteTask
    
    func testDeleteTask() {
        let addExpectation = XCTestExpectation(description: "Task is added before we delete it")
        let deleteExpectation = XCTestExpectation(description: "Task is deleted and removed from tasks array")
        
        let randomTitle = "DeleteTest-\(UUID().uuidString.prefix(5))"
        
        // Логика: сначала дождёмся, когда задача добавится, потом вызовем deleteTask и дождёмся, что задача исчезла.
        
        // 1) Подписываемся на обновления, чтобы отследить добавление, а потом удаление
        viewModel.$tasks
            .dropFirst() // игнорируем начальное состояние
            .sink { [weak self] tasks in
                guard let self = self else { return }
                
                // Если задача с randomTitle появилась — выполняем addExpectation
                if tasks.contains(where: { $0.title == randomTitle }) && !addExpectation.isFulfilled {
                    addExpectation.fulfill()
                    
                    // Как только задача появилась, найдём её, чтобы удалить
                    if let taskToDelete = tasks.first(where: { $0.title == randomTitle }) {
                        self.viewModel.deleteTask(task: taskToDelete)
                    }
                }
                
                // Если задача уже была добавлена и мы вызвали deleteTask,
                // ждём, что она пропадёт из массива
                if addExpectation.isFulfilled {
                    if !tasks.contains(where: { $0.title == randomTitle }) {
                        print("✅ Task with title \(randomTitle) was deleted.")
                        deleteExpectation.fulfill()
                    }
                }
            }
            .store(in: &self.cancellables)
        
        // 2) Добавляем задачу
        viewModel.addTask(title: randomTitle, category: "TestCategory", note: nil)
        
        // Ждём, пока задача добавится и удалится
        wait(for: [addExpectation, deleteExpectation], timeout: 15.0)
    }
    
    // MARK: - Тест updateTask
    
    func testUpdateTask() {
        let addExpectation = XCTestExpectation(description: "Task is added before update")
        let updateExpectation = XCTestExpectation(description: "Task is updated and new title is reflected in tasks array")
        
        let randomTitle = "UpdateTest-\(UUID().uuidString.prefix(5))"
        let updatedTitle = "UpdatedTitle-\(UUID().uuidString.prefix(5))"
        
        // Подпишемся на tasks, чтобы отследить и добавление, и обновление
        viewModel.$tasks
            .dropFirst()
            .sink { [weak self] tasks in
                guard let self = self else { return }
                
                // 1) Сначала ждём, когда задача появится
                if tasks.contains(where: { $0.title == randomTitle }) && !addExpectation.isFulfilled {
                    addExpectation.fulfill()
                    
                    // Берём задачу и обновляем
                    if let taskToUpdate = tasks.first(where: { $0.title == randomTitle }) {
                        self.viewModel.updateTask(task: taskToUpdate,
                                                  newTitle: updatedTitle,
                                                  newNote: "Updated note")
                    }
                }
                
                // 2) После вызова updateTask ждём, что title станет updatedTitle
                if addExpectation.isFulfilled {
                    if tasks.contains(where: { $0.title == updatedTitle }) {
                        print("✅ Task title successfully updated to \(updatedTitle).")
                        updateExpectation.fulfill()
                    }
                }
            }
            .store(in: &self.cancellables)
        
        // Добавляем задачу, чтобы потом обновить
        viewModel.addTask(title: randomTitle, category: "TestCategory", note: nil)
        
        wait(for: [addExpectation, updateExpectation], timeout: 15.0)
    }
}
