//
//  Color+Theme.swift
//  tasks
//
//  Theme colors and color utilities
//

import SwiftUI

struct ColorTheme {
    // MARK: - Backgrounds
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)

    // MARK: - Shadows & Overlays
    static let cardShadow = Color.black.opacity(0.1)
    static let lightShadow = Color.black.opacity(0.05)
    static let pressedOverlay = Color.black.opacity(0.03)

    // MARK: - Accents
    static let primaryAccent = Color.blue
    static let successAccent = Color.green
    static let warningAccent = Color.orange
    static let dangerAccent = Color.red

    // MARK: - Text
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color(.tertiaryLabel)
}

extension Color {
    // MARK: - Priority Colors
    static func priorityColor(for priority: TodoPriority) -> Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }

    // MARK: - Category Colors
    static func categoryColor(for category: TodoCategory) -> Color {
        switch category {
        case .work:
            return .blue
        case .personal:
            return .purple
        case .shopping:
            return .green
        case .health:
            return .pink
        case .other:
            return .gray
        }
    }
}
