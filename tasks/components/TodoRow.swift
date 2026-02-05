import SwiftUI

// MARK: - Todo Row
struct TodoRow: View {
    let todo: Todo
    let onToggle: () -> Void

    @State private var isPressed = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Animated Checkbox
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
                    .font(.title3)
                    .scaleEffect(todo.isCompleted ? AnimationConstants.completedScale : 1.0)
                    .animation(AnimationConstants.checkboxToggle, value: todo.isCompleted)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(todo.title)
                        .strikethrough(todo.isCompleted)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                        .animation(AnimationConstants.spring, value: todo.isCompleted)
                    
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
        .scaleEffect(isPressed ? AnimationConstants.pressedScale : 1.0)
        .animation(AnimationConstants.cardPress, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        HapticService.shared.buttonPressed(intensity: 0.5)
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}
