import SwiftUI

// MARK: - Todo Row
struct TodoRow: View {
    let todo: Todo
    let onToggle: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(todo.title)
                        .strikethrough(todo.isCompleted)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: todo.priority.icon)
                        .foregroundColor(todo.priority.color)
                        .font(.caption)
                }
                
                HStack(spacing: 8) {
                    Label(todo.category.rawValue, systemImage: todo.category.icon)
                        .font(.caption2)
                        .foregroundColor(todo.category.color)
                    
                    if let dueDate = todo.dueDate {
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
                            Text(dueDate, style: .date)
                        }
                        .font(.caption2)
                        .foregroundColor(todo.isOverdue ? .red : .secondary)
                    }
                    
                    if todo.isOverdue {
                        Text("OVERDUE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    }
                }
                
                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
