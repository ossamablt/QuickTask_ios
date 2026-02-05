//
//  TodoListViewModel.swift
//  tasks
//
//  Modern ViewModel using @Observable (iOS 17+) with SwiftData integration
//

import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
final class TodoListViewModel {
    // MARK: - Properties

    var filter: TodoFilter = .all
    var sortBy: TodoSort = .createdDate
    var searchText: String = ""
    var selectedCategory: TodoCategory?

    private let modelContext: ModelContext
    private let hapticService = HapticService.shared
    private let notificationService = NotificationService.shared

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD Operations

    func addTodo(title: String,
                 dueDate: Date? = nil,
                 priority: TodoPriority = .medium,
                 category: TodoCategory = .other,
                 notes: String = "") {
        // Get current max sortOrder
        let descriptor = FetchDescriptor<Todo>(sortBy: [SortDescriptor(\.sortOrder, order: .reverse)])
        let maxSortOrder = (try? modelContext.fetch(descriptor).first?.sortOrder) ?? -1

        let todo = Todo(
            title: title,
            dueDate: dueDate,
            priority: priority,
            category: category,
            notes: notes,
            sortOrder: maxSortOrder + 1
        )

        modelContext.insert(todo)
        saveContext()

        // Trigger haptic feedback
        hapticService.taskAdded()

        // Schedule notification if has due date
        if dueDate != nil {
            Task {
                await notificationService.scheduleNotification(for: todo)
            }
        }
    }

    func toggleCompletion(_ todo: Todo) {
        withAnimation(AnimationConstants.checkboxToggle) {
            todo.isCompleted.toggle()
            todo.lastModified = Date()
        }

        saveContext()

        // Trigger haptic feedback
        if todo.isCompleted {
            hapticService.taskCompleted()
            // Cancel notification when completed
            notificationService.cancelNotification(for: todo)
        } else {
            hapticService.taskUncompleted()
            // Reschedule notification when uncompleted
            if todo.dueDate != nil {
                Task {
                    await notificationService.scheduleNotification(for: todo)
                }
            }
        }
    }

    func updateTodo(_ todo: Todo,
                    title: String,
                    dueDate: Date?,
                    priority: TodoPriority,
                    category: TodoCategory,
                    notes: String) {
        let oldDueDate = todo.dueDate

        todo.title = title
        todo.dueDate = dueDate
        todo.priority = priority
        todo.category = category
        todo.notes = notes
        todo.lastModified = Date()

        saveContext()

        // Update notification if due date changed
        if oldDueDate != dueDate {
            notificationService.cancelNotification(for: todo)
            if let _ = dueDate, !todo.isCompleted {
                Task {
                    await notificationService.scheduleNotification(for: todo)
                }
            }
        }
    }

    func deleteTodo(_ todo: Todo) {
        withAnimation(AnimationConstants.listDelete) {
            modelContext.delete(todo)
        }

        saveContext()

        // Trigger haptic and cancel notification
        hapticService.taskDeleted()
        notificationService.cancelNotification(for: todo)
    }

    func moveTodos(from source: IndexSet, to destination: Int, in todos: [Todo]) {
        var updatedTodos = todos
        updatedTodos.move(fromOffsets: source, toOffset: destination)

        // Update sortOrder for all affected todos
        for (index, todo) in updatedTodos.enumerated() {
            todo.sortOrder = index
        }

        saveContext()
    }

    func clearCompleted(todos: [Todo]) {
        let completedTodos = todos.filter { $0.isCompleted }

        withAnimation(AnimationConstants.listDelete) {
            for todo in completedTodos {
                notificationService.cancelNotification(for: todo)
                modelContext.delete(todo)
            }
        }

        saveContext()
        hapticService.taskDeleted()
    }

    // MARK: - Statistics

    func calculateStatistics(todos: [Todo]) -> (total: Int, completed: Int, active: Int, overdue: Int, completionRate: Double) {
        let total = todos.count
        let completed = todos.filter { $0.isCompleted }.count
        let active = todos.filter { !$0.isCompleted }.count
        let overdue = todos.filter { $0.isOverdue }.count

        let completionRate: Double = total > 0 ? (Double(completed) / Double(total) * 100) : 0

        return (total, completed, active, overdue, completionRate)
    }

    // MARK: - Filtering & Sorting Helpers

    func priorityValue(_ priority: TodoPriority) -> Int {
        switch priority {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }

    // MARK: - Private Helpers

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
