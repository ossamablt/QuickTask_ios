import SwiftUI

// MARK: - Add Todo View
struct AddTodoView: View {
    let viewModel: TodoListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var notes = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var priority: TodoPriority = .medium
    @State private var category: TodoCategory = .other
    
    var body: some View {
        NavigationStack {
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
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityHint("Discard changes and close")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmed = title.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }

                        viewModel.addTodo(
                            title: trimmed,
                            dueDate: hasDueDate ? dueDate : nil,
                            priority: priority,
                            category: category,
                            notes: notes
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityHint("Create task with current details")
                }
            }
        }
    }
}
