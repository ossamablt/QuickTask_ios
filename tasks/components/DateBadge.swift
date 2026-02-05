//
//  DateBadge.swift
//  tasks
//
//  Badge component for displaying due dates with overdue indicator
//

import SwiftUI

struct DateBadge: View {
    let date: Date
    let isOverdue: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
            Text(date.relativeFormatted)
        }
        .font(.caption)
        .fontWeight(isOverdue ? .semibold : .regular)
        .foregroundColor(isOverdue ? .white : .secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isOverdue ? Color.red : Color(.systemGray5))
        .cornerRadius(6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Due \(date.relativeFormatted)\(isOverdue ? ", overdue" : "")")
    }
}
