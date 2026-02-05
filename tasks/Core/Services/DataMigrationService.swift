//
//  DataMigrationService.swift
//  tasks
//
//  Handles one-time migration from UserDefaults to SwiftData
//

import Foundation
import SwiftData

final class DataMigrationService {
    private static let migrationKey = "hasCompletedSwiftDataMigration"

    // MARK: - Old Todo Structure (for decoding UserDefaults data)

    private struct OldTodo: Codable {
        let id: UUID
        var title: String
        var isCompleted: Bool
        let createdAt: Date
        var dueDate: Date?
        var priority: String
        var category: String
        var notes: String
    }

    // MARK: - Migration

    static func migrateFromUserDefaultsIfNeeded(modelContext: ModelContext) {
        // Check if migration already completed
        guard !UserDefaults.standard.bool(forKey: migrationKey) else {
            print("Migration already completed, skipping...")
            return
        }

        print("Starting migration from UserDefaults to SwiftData...")

        // Try to read old data from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "todos_storage"),
              let oldTodos = try? JSONDecoder().decode([OldTodo].self, from: data) else {
            print("No existing data to migrate, marking migration as complete")
            UserDefaults.standard.set(true, forKey: migrationKey)
            return
        }

        print("Found \(oldTodos.count) todos to migrate")

        // Convert old todos to new SwiftData format
        for (index, oldTodo) in oldTodos.enumerated() {
            let newTodo = Todo(
                id: oldTodo.id,
                title: oldTodo.title,
                isCompleted: oldTodo.isCompleted,
                createdAt: oldTodo.createdAt,
                dueDate: oldTodo.dueDate,
                priority: TodoPriority(rawValue: oldTodo.priority) ?? .medium,
                category: TodoCategory(rawValue: oldTodo.category) ?? .other,
                notes: oldTodo.notes,
                sortOrder: index,
                notificationIdentifier: nil,
                lastModified: oldTodo.createdAt,
                isSyncing: false
            )

            modelContext.insert(newTodo)
        }

        // Save the context
        do {
            try modelContext.save()
            print("Successfully migrated \(oldTodos.count) todos to SwiftData")

            // Mark migration as complete
            UserDefaults.standard.set(true, forKey: migrationKey)

            // Optional: Keep a backup of old data for safety
            UserDefaults.standard.set(data, forKey: "todos_storage_backup")
            print("Created backup of old data at 'todos_storage_backup'")

        } catch {
            print("Error saving migrated data: \(error)")
            // Don't mark migration as complete so it can be retried
        }
    }

    // MARK: - Reset (for testing)

    static func resetMigrationFlag() {
        UserDefaults.standard.removeObject(forKey: migrationKey)
        print("Migration flag reset")
    }
}
