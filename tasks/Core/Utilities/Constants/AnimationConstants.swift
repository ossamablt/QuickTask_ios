//
//  AnimationConstants.swift
//  tasks
//
//  Centralized animation definitions for consistent app-wide animations
//

import SwiftUI

enum AnimationConstants {
    // MARK: - Core Animations
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let snappySpring = Animation.spring(response: 0.25, dampingFraction: 0.65)
    static let smoothSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)

    // MARK: - Specific Use Cases
    static let checkboxToggle = Animation.spring(response: 0.3, dampingFraction: 0.6)
    static let listInsert = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let listDelete = Animation.easeOut(duration: 0.25)
    static let cardPress = Animation.spring(response: 0.2, dampingFraction: 0.5)

    // MARK: - Timing Values
    static let quickDuration: CGFloat = 0.2
    static let standardDuration: CGFloat = 0.3
    static let slowDuration: CGFloat = 0.4

    // MARK: - Scale Values
    static let pressedScale: CGFloat = 0.98
    static let completedScale: CGFloat = 1.1
    static let deletedScale: CGFloat = 0.9
}
