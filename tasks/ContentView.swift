import SwiftUI
import Combine

// MARK: - Todo Model
struct Todo: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    let createdAt: Date
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// MARK: - Filter Type
enum TodoFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

// MARK: - ViewModel
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = [] {
        didSet { saveTodos() }
    }
    
    @Published var filter: TodoFilter = .all
    
    private let storageKey = "todos_storage"
    
    init() {
        loadTodos()
    }
    
    var filteredTodos: [Todo] {
        switch filter {
        case .all:
            return todos
        case .active:
            return todos.filter { !$0.isCompleted }
        case .completed:
            return todos.filter { $0.isCompleted }
        }
    }
    
    func addTodo(title: String) {
        let todo = Todo(title: title)
        todos.append(todo)
    }
    
    func toggle(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].isCompleted.toggle()
    }
    
    func update(_ todo: Todo, title: String) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].title = title
    }
    
    func delete(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
    }
    
    // MARK: - Persistence
    private func saveTodos() {
        if let data = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadTodos() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let savedTodos = try? JSONDecoder().decode([Todo].self, from: data)
        else { return }
        
        todos = savedTodos
    }
}

// MARK: - Content View
struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var newTitle = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Add Todo
                HStack {
                    TextField("New task...", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        let trimmed = newTitle.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        viewModel.addTodo(title: trimmed)
                        newTitle = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                
                // Filter
                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(TodoFilter.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // List
                List {
                    ForEach(viewModel.filteredTodos) { todo in
                        NavigationLink {
                            EditTodoView(todo: todo, viewModel: viewModel)
                        } label: {
                            TodoRow(todo: todo) {
                                viewModel.toggle(todo)
                            }
                        }
                    }
                    .onDelete(perform: viewModel.delete)
                }
                .listStyle(.plain)
            }
            .navigationTitle("My Tasks")
        }
    }
}

// MARK: - Todo Row
struct TodoRow: View {
    let todo: Todo
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                
                Text(todo.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Edit View
struct EditTodoView: View {
    let todo: Todo
    @ObservedObject var viewModel: TodoViewModel
    @State private var title: String
    
    init(todo: Todo, viewModel: TodoViewModel) {
        self.todo = todo
        self.viewModel = viewModel
        _title = State(initialValue: todo.title)
    }
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            
            Button("Save") {
                viewModel.update(todo, title: title)
            }
        }
        .navigationTitle("Edit Task")
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
