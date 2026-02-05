import SwiftUI

// MARK: - Todo Row
struct TodoRow: View {
    let todo: Todo
    let onToggle: () -> Void

    @State private var isPressed = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Animated Checkbox
            AnimatedCheckbox(isCompleted: todo.isCompleted, action: onToggle)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(todo.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? ColorTheme.secondaryText : ColorTheme.primaryText)
                    .animation(AnimationConstants.spring, value: todo.isCompleted)

                // Badges
                HStack(spacing: 8) {
                    // Priority Badge
                    PriorityBadge(priority: todo.priority)

                    // Category Badge
                    HStack(spacing: 4) {
                        Image(systemName: todo.category.icon)
                        Text(todo.category.rawValue)
                    }
                    .font(.caption)
                    .foregroundColor(Color.categoryColor(for: todo.category))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.categoryColor(for: todo.category).opacity(0.15))
                    .cornerRadius(6)

                    // Due Date Badge
                    if let dueDate = todo.dueDate {
                        DateBadge(date: dueDate, isOverdue: todo.isOverdue && !todo.isCompleted)
                    }
                }

                // Notes Preview
                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.caption)
                        .foregroundColor(ColorTheme.tertiaryText)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorTheme.cardBackground)
                .shadow(
                    color: ColorTheme.cardShadow,
                    radius: isPressed ? 2 : 4,
                    x: 0,
                    y: isPressed ? 1 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
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
