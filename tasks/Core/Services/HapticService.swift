//
//  HapticService.swift
//  tasks
//
//  Manages haptic feedback throughout the app for a polished user experience
//

import UIKit

final class HapticService {
    static let shared = HapticService()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        // Prepare generators for faster response
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    // MARK: - Task Actions

    func taskCompleted() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    func taskUncompleted() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    func taskDeleted() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    func taskAdded() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    // MARK: - UI Interactions

    func selectionChanged() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    func buttonPressed(intensity: CGFloat = 0.7) {
        impactLight.impactOccurred(intensity: intensity)
        impactLight.prepare()
    }

    func heavyImpact() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }
}
