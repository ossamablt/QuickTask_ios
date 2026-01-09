import SwiftUI
import Combine

// MARK: - Todo Model
struct Todo: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - Todo View Model
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    
    func addTodo(title: String) {
        let newTodo = Todo(title: title)
        todos.append(newTodo)
    }
    
    func toggleComplete(todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
        }
    }
    
    func deleteTodo(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var newTodoTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Input field
                HStack {
                    TextField("Enter new todo", text: $newTodoTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addTodo) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(newTodoTitle.isEmpty)
                }
                .padding()
                
                // Todo list
                List {
                    ForEach(viewModel.todos) { todo in
                        TodoRow(todo: todo) {
                            viewModel.toggleComplete(todo: todo)
                        }
                    }
                    .onDelete(perform: viewModel.deleteTodo)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func addTodo() {
        guard !newTodoTitle.isEmpty else { return }
        viewModel.addTodo(title: newTodoTitle)
        newTodoTitle = ""
    }
}

// MARK: - Todo Row View
struct TodoRow: View {
    let todo: Todo
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(todo.title)
                .strikethrough(todo.isCompleted)
                .foregroundColor(todo.isCompleted ? .gray : .primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
