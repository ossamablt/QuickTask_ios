//
//  AnimatedCheckbox.swift
//  tasks
//
//  Standalone animated checkbox component
//

import SwiftUI

struct AnimatedCheckbox: View {
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
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
            ZStack {
                Circle()
                    .stroke(isCompleted ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 28, height: 28)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                        .scaleEffect(AnimationConstants.completedScale)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(AnimationConstants.checkboxToggle, value: isCompleted)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to mark as \(isCompleted ? "incomplete" : "complete")")
        .accessibilityAddTraits(.isButton)
    }
}
