//
//  tasksApp.swift
//  tasks
//
//  Created by Abdelmadjid Belilet on 06/01/2026.
//

import SwiftUI
import SwiftData

@main
struct tasksApp: App {
    // MARK: - SwiftData Container

    let modelContainer: ModelContainer

    init() {
        do {
            // Configure SwiftData with iCloud support ready (but disabled for now)
            let schema = Schema([Todo.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none // Change to .automatic to enable iCloud sync
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // Perform one-time migration from UserDefaults
            let context = ModelContext(modelContainer)
            DataMigrationService.migrateFromUserDefaultsIfNeeded(modelContext: context)

            // Request notification authorization on app launch
            Task {
                await NotificationService.shared.requestAuthorization()
            }

        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
