import XCTest
import Combine
@testable import ul11

class MockFirestore: FirestoreProtocol {
    var addedTasks: [Task] = []
    var deletedTaskIDs: [String] = []
    var updatedTasks: [String: [String: Any]] = [:]
    
    func simulateFetchTasks(viewModel: FirestoreViewModel) {
        let tasks = [
            Task(id: "1", title: "Test Task 1", category: "Work", note: nil),
            Task(id: "2", title: "Test Task 2", category: "Home", note: "Important")
        ]
        DispatchQueue.main.async {
            viewModel.updateTasks(tasks)
        }
    }
    
    func addDocument(from task: Task) throws {
        addedTasks.append(task)
    }
    
    func document(_ id: String) -> DocumentReferenceProtocol {
        return MockDocumentReference(id: id, mockFirestore: self)
    }
}

class MockDocumentReference: DocumentReferenceProtocol {
    let id: String
    let mockFirestore: MockFirestore
    
    init(id: String, mockFirestore: MockFirestore) {
        self.id = id
        self.mockFirestore = mockFirestore
    }
    
    func delete(completion: ((Error?) -> Void)?) {
        mockFirestore.deletedTaskIDs.append(id)
        completion?(nil)
    }
    
    func updateData(_ data: [String : Any], completion: ((Error?) -> Void)?) {
        mockFirestore.updatedTasks[id] = data
        completion?(nil)
    }
}

class FirestoreViewModelTests: XCTestCase {
    var viewModel: FirestoreViewModel!
    var mockFirestore: MockFirestore!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestore()
        viewModel = FirestoreViewModel(db: mockFirestore)
    }
    
    override func tearDown() {
        viewModel = nil
        mockFirestore = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testFetchTasks() {
        let expectation = XCTestExpectation(description: "Fetch tasks updates published list")
        
        viewModel.$tasks
            .dropFirst()
            .sink { tasks in
                XCTAssertEqual(tasks.count, 2)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockFirestore.simulateFetchTasks(viewModel: viewModel)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddTask() {
        viewModel.addTask(title: "New Task", category: "Work", note: "Some note")
        XCTAssertEqual(mockFirestore.addedTasks.count, 1)
        XCTAssertEqual(mockFirestore.addedTasks.first?.title, "New Task")
    }
    
    func testDeleteTask() {
        let task = Task(id: "123", title: "Task to Delete", category: "Home", note: nil)
        viewModel.deleteTask(task: task)
        XCTAssertEqual(mockFirestore.deletedTaskIDs.first, "123")
    }
    
    func testUpdateTask() {
        let task = Task(id: "123", title: "Old Task", category: "Home", note: "Old Note")
        viewModel.updateTask(task: task, newTitle: "Updated Task", newNote: "Updated Note")
        XCTAssertEqual(mockFirestore.updatedTasks["123"]?["title"] as? String, "Updated Task")
        XCTAssertEqual(mockFirestore.updatedTasks["123"]?["note"] as? String, "Updated Note")
    }
}
