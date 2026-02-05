import Foundation
import SwiftUI
import SwiftData

// MARK: - Todo Model
@Model
final class Todo {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var priority: TodoPriority
    var category: TodoCategory
    var notes: String

    // New properties for enhanced functionality
    var sortOrder: Int
    var notificationIdentifier: String?
    var lastModified: Date
    @Transient var isSyncing: Bool = false // Ephemeral, not persisted

    init(id: UUID = UUID(),
         title: String,
         isCompleted: Bool = false,
         createdAt: Date = Date(),
         dueDate: Date? = nil,
         priority: TodoPriority = .medium,
         category: TodoCategory = .other,
         notes: String = "",
         sortOrder: Int = 0,
         notificationIdentifier: String? = nil,
         lastModified: Date = Date(),
         isSyncing: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        self.notes = notes
        self.sortOrder = sortOrder
        self.notificationIdentifier = notificationIdentifier
        self.lastModified = lastModified
        self.isSyncing = isSyncing
    }

    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }
}
