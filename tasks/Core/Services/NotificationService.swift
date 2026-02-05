//
//  NotificationService.swift
//  tasks
//
//  Manages local notifications for task reminders
//

import Foundation
import UserNotifications
import SwiftUI
import Combine

final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let notificationCenter = UNUserNotificationCenter.current()

    override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                authorizationStatus = granted ? .authorized : .denied
            }
        } catch {
            print("Error requesting notification authorization: \(error)")
        }
    }

    func checkAuthorizationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                authorizationStatus = settings.authorizationStatus
            }
        }
    }

    // MARK: - Schedule & Cancel

    func scheduleNotification(for todo: Todo) async {
        guard authorizationStatus == .authorized,
              let dueDate = todo.dueDate,
              !todo.isCompleted,
              dueDate > Date() else {
            return
        }

        // Schedule notification 1 hour before due date
        let reminderDate = dueDate.addingTimeInterval(-3600)

        // Only schedule if reminder is in the future
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = todo.title
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["todoId": todo.id.uuidString]

        // Add priority info
        let priorityEmoji = switch todo.priority {
        case .high: "🔴"
        case .medium: "🟡"
        case .low: "🟢"
        }
        content.subtitle = "\(priorityEmoji) \(todo.priority.rawValue.capitalized) Priority"

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let identifier = "todo_\(todo.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
            print("Scheduled notification for todo: \(todo.title) at \(reminderDate)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }

    func cancelNotification(for todo: Todo) {
        let identifier = "todo_\(todo.id.uuidString)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled notification for todo: \(todo.title)")
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let todoIdString = userInfo["todoId"] as? String,
           let todoId = UUID(uuidString: todoIdString) {
            // Post notification for navigation
            NotificationCenter.default.post(name: .navigateToTodo, object: todoId)
        }

        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToTodo = Notification.Name("navigateToTodo")
}
