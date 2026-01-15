import Foundation

// MARK: - Filter Type
enum TodoFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

// MARK: - Sort Type
enum TodoSort: String, CaseIterable {
    case createdDate = "Created Date"
    case dueDate = "Due Date"
    case priority = "Priority"
    case title = "Title"
}
