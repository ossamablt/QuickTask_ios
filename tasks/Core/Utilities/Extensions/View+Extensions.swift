//
//  View+Extensions.swift
//  tasks
//
//  Reusable view modifiers and helpers
//

import SwiftUI

extension View {
    // MARK: - Card Style

    func cardStyle(backgroundColor: Color = Color(.systemBackground),
                   cornerRadius: CGFloat = 12,
                   shadowRadius: CGFloat = 4,
                   shadowOpacity: Double = 0.1) -> some View {
        self
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 2)
    }

    // MARK: - Haptic Tap

    func hapticTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .light, action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
            action()
        }
    }

    // MARK: - Conditional Modifiers

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Animated Checkbox

    func animatedCheckbox(isCompleted: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            if isCompleted {
                HapticService.shared.taskUncompleted()
            } else {
                HapticService.shared.taskCompleted()
            }
            withAnimation(AnimationConstants.checkboxToggle) {
                action()
            }
        }) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isCompleted ? .green : .gray)
                .scaleEffect(isCompleted ? 1.1 : 1.0)
                .animation(AnimationConstants.checkboxToggle, value: isCompleted)
        }
        .buttonStyle(.plain)
    }
}
