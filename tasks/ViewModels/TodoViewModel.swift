import Foundation
import Combine

// MARK: - ViewModel
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = [] {
        didSet { saveTodos() }
    }
    
    @Published var filter: TodoFilter = .all
    @Published var sortBy: TodoSort = .createdDate
    @Published var searchText: String = ""
    @Published var selectedCategory: TodoCategory?
    
    private let storageKey = "todos_storage"
    
    init() {
        loadTodos()
    }
    
    var filteredTodos: [Todo] {
        var result = todos
        
        // Apply filter
        switch filter {
        case .all:
            break
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting
        switch sortBy {
        case .createdDate:
            result.sort { $0.createdAt > $1.createdAt }
        case .dueDate:
            result.sort { (todo1, todo2) in
                if let date1 = todo1.dueDate, let date2 = todo2.dueDate {
                    return date1 < date2
                } else if todo1.dueDate != nil {
                    return true
                } else {
                    return false
                }
            }
        case .priority:
            result.sort { (todo1, todo2) in
                let priority1 = priorityValue(todo1.priority)
                let priority2 = priorityValue(todo2.priority)
                return priority1 > priority2
            }
        case .title:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
        
        return result
    }
    
    private func priorityValue(_ priority: TodoPriority) -> Int {
        switch priority {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    // MARK: - Statistics
    var totalTasks: Int { todos.count }
    var completedTasks: Int { todos.filter { $0.isCompleted }.count }
    var activeTasks: Int { todos.filter { !$0.isCompleted }.count }
    var overdueTasks: Int { todos.filter { $0.isOverdue }.count }
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks) * 100
    }
    
    // MARK: - CRUD Operations
    func addTodo(title: String,
                 dueDate: Date? = nil,
                 priority: TodoPriority = .medium,
                 category: TodoCategory = .other,
                 notes: String = "") {
        let todo = Todo(title: title,
                       dueDate: dueDate,
                       priority: priority,
                       category: category,
                       notes: notes,
                       sortOrder: todos.count)
        todos.append(todo)
    }

    func toggle(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].isCompleted.toggle()
        todos[index].lastModified = Date()
    }

    func update(_ todo: Todo,
                title: String,
                dueDate: Date?,
                priority: TodoPriority,
                category: TodoCategory,
                notes: String) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].title = title
        todos[index].dueDate = dueDate
        todos[index].priority = priority
        todos[index].category = category
        todos[index].notes = notes
        todos[index].lastModified = Date()
    }
    
    func deleteTodo(_ todo: Todo) {
        todos.removeAll(where: { $0.id == todo.id })
    }
    
    func delete(at offsets: IndexSet) {
        // Remove in descending order to keep remaining indices valid
        for index in offsets.sorted(by: >) {
            todos.remove(at: index)
        }
    }
    
    func clearCompleted() {
        todos.removeAll { $0.isCompleted }
    }
    
    // MARK: - Persistence
    // NOTE: These methods are deprecated and will be removed in Stage 3
    // SwiftData handles persistence automatically via ModelContext
    private func saveTodos() {
        // TODO: Remove in Stage 3 - SwiftData handles persistence
        print("Warning: saveTodos() called but should use SwiftData ModelContext")
    }

    private func loadTodos() {
        // TODO: Remove in Stage 3 - SwiftData handles loading via @Query
        print("Warning: loadTodos() called but should use SwiftData @Query")
    }
}
