import SwiftUI

// MARK: - Edit View
struct EditTodoView: View {
    let todo: Todo
    let viewModel: TodoListViewModel
    @State private var title: String
    @State private var notes: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var priority: TodoPriority
    @State private var category: TodoCategory
    @Environment(\.dismiss) private var dismiss

    init(todo: Todo, viewModel: TodoListViewModel) {
        self.todo = todo
        self.viewModel = viewModel
        _title = State(initialValue: todo.title)
        _notes = State(initialValue: todo.notes)
        _hasDueDate = State(initialValue: todo.dueDate != nil)
        _dueDate = State(initialValue: todo.dueDate ?? Date())
        _priority = State(initialValue: todo.priority)
        _category = State(initialValue: todo.category)
    }
    
    var body: some View {
        Form {
            Section("Task Details") {
                TextField("Title", text: $title)
                
                Picker("Category", selection: $category) {
                    ForEach(TodoCategory.allCases, id: \.self) { cat in
                        Label(cat.rawValue, systemImage: cat.icon)
                            .tag(cat)
                    }
                }
                
                Picker("Priority", selection: $priority) {
                    ForEach(TodoPriority.allCases, id: \.self) { pri in
                        Label(pri.rawValue, systemImage: pri.icon)
                            .tag(pri)
                    }
                }
                
                HStack {
                    Text("Status")
                    Spacer()
                    Text(todo.isCompleted ? "Completed" : "Active")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Due Date") {
                Toggle("Set Due Date", isOn: $hasDueDate)
                
                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            
            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(height: 100)
            }
            
            Section("Metadata") {
                HStack {
                    Text("Created")
                    Spacer()
                    Text(todo.createdAt, style: .date)
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button("Save Changes") {
                    viewModel.updateTodo(
                        todo,
                        title: title,
                        dueDate: hasDueDate ? dueDate : nil,
                        priority: priority,
                        category: category,
                        notes: notes
                    )
                    dismiss()
                }
                .accessibilityHint("Save modifications to this task")
            }

            Section {
                Button(role: .destructive) {
                    viewModel.deleteTodo(todo)
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Task")
                        Spacer()
                    }
                }
                .accessibilityLabel("Delete task")
                .accessibilityHint("Permanently remove this task")
            }
        }
        .navigationTitle("Edit Task")
        .navigationBarTitleDisplayMode(.inline)
    }
}
