//
//  HapticManager.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//  Copyright © 2025 Ryan Schefske. All rights reserved.
//

import UIKit

/// Centralized manager for haptic feedback throughout the app
final class HapticManager {

    // MARK: - Singleton

    static let shared = HapticManager()

    // MARK: - Generators

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    // MARK: - Initialization

    private init() {
        // Prepare generators for faster response
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }

    // MARK: - Public Methods

    /// Light tap feedback - for subtle interactions
    func light() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }

    /// Medium tap feedback - for standard button taps
    func medium() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    /// Heavy tap feedback - for important actions
    func heavy() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    /// Success feedback - for successful completions
    func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    /// Warning feedback - for warnings or validation issues
    func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }

    /// Error feedback - for errors or failures
    func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }

    /// Selection feedback - for picker/segmented control changes
    func selection() {
        selection.selectionChanged()
        selection.prepare()
    }
}
