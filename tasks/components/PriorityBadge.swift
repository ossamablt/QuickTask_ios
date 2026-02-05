//
//  PriorityBadge.swift
//  tasks
//
//  Colored badge component for displaying task priority
//

import SwiftUI

struct PriorityBadge: View {
    let priority: TodoPriority

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.icon)
            Text(priority.rawValue.capitalized)
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.priorityColor(for: priority))
        .cornerRadius(6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(priority.rawValue.capitalized) priority")
    }
}
