//
//  ShareManager.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//  Copyright © 2025 Ryan Schefske. All rights reserved.
//

import UIKit
import SwiftUI

/// Centralized manager for sharing functionality
final class ShareManager {

    // MARK: - Singleton

    static let shared = ShareManager()

    // MARK: - Initialization

    private init() { }

    // MARK: - Public Methods

    /// Share text content
    func shareText(_ text: String, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        // For iPad - set popover source
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        viewController.present(activityVC, animated: true)
    }

    /// Share reading stats with promotional message
    func shareReadingStats(wordCount: Int, duration: TimeInterval, from viewController: UIViewController) {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))

        let timeString = minutes > 0 ? "\(minutes) minutes" : "\(seconds) seconds"
        let message = "I just read \(wordCount) words in \(timeString) using Scholarly! 📚✨"

        // TODO: Replace with actual App Store link when published
        let appURL = "https://apps.apple.com/app/scholarly"

        let activityVC = UIActivityViewController(
            activityItems: [message, appURL],
            applicationActivities: nil
        )

        // For iPad - set popover source
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        viewController.present(activityVC, animated: true)
    }
}

// MARK: - SwiftUI Helpers

struct ShareLink: UIViewControllerRepresentable {
    let items: [Any]
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = uiViewController.view
            popover.sourceRect = CGRect(
                x: uiViewController.view.bounds.midX,
                y: uiViewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        activityVC.completionWithItemsHandler = { _, _, _, _ in
            dismiss()
        }

        uiViewController.present(activityVC, animated: true)
    }
}
