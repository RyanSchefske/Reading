//
//  RatingManager.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//  Copyright © 2025 Ryan Schefske. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

/// Manages App Store rating prompts
@MainActor
final class RatingManager {

    // MARK: - Singleton

    static let shared = RatingManager()

    // MARK: - Properties

    private let sessionsKey = "completedReadingSessions"
    private let lastPromptKey = "lastRatingPromptDate"
    private let hasDeclinedKey = "hasDeclinedRating"
    private let lastPromptedVersionKey = "lastRatingPromptVersion"
    private let hasShownMilestonePaywallKey = "hasShownMilestonePaywall"

    private let minimumSessions = 3
    private let daysBetweenPrompts = 30
    private let milestoneSessionCount = 3

    /// Current app version from bundle
    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    // MARK: - Initialization

    private init() { }

    // MARK: - Public Methods

    /// Call after a successful reading session
    /// Returns true if milestone paywall should be shown
    func incrementSessionCount() -> Bool {
        let count = sessionCount
        UserDefaults.standard.set(count + 1, forKey: sessionsKey)

        // Check if we should show milestone paywall (only for free users)
        let shouldShowMilestone = shouldShowMilestonePaywall()

        // Check if we should prompt for rating (only if not showing paywall)
        if !shouldShowMilestone && shouldPromptForRating() {
            requestReview()
        }

        return shouldShowMilestone
    }

    /// Mark milestone paywall as shown
    func markMilestonePaywallShown() {
        UserDefaults.standard.set(true, forKey: hasShownMilestonePaywallKey)
    }

    /// Request review from user
    func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        // Record that we prompted with current version
        UserDefaults.standard.set(Date(), forKey: lastPromptKey)
        UserDefaults.standard.set(currentAppVersion, forKey: lastPromptedVersionKey)

        // Request review
        SKStoreReviewController.requestReview(in: scene)
    }

    /// Reset counters (for testing)
    func reset() {
        UserDefaults.standard.removeObject(forKey: sessionsKey)
        UserDefaults.standard.removeObject(forKey: lastPromptKey)
        UserDefaults.standard.removeObject(forKey: hasDeclinedKey)
        UserDefaults.standard.removeObject(forKey: lastPromptedVersionKey)
    }

    // MARK: - Private Methods

    private var sessionCount: Int {
        UserDefaults.standard.integer(forKey: sessionsKey)
    }

    private var lastPromptDate: Date? {
        UserDefaults.standard.object(forKey: lastPromptKey) as? Date
    }

    private var hasDeclined: Bool {
        UserDefaults.standard.bool(forKey: hasDeclinedKey)
    }

    private var lastPromptedVersion: String? {
        UserDefaults.standard.string(forKey: lastPromptedVersionKey)
    }

    private var hasShownMilestonePaywall: Bool {
        UserDefaults.standard.bool(forKey: hasShownMilestonePaywallKey)
    }

    private func shouldShowMilestonePaywall() -> Bool {
        // Don't show if already shown
        guard !hasShownMilestonePaywall else { return false }

        // Don't show if already Pro
        guard !SubscriptionManager.shared.isPro else { return false }

        // Show after exactly 3 sessions
        return sessionCount == milestoneSessionCount
    }

    private func shouldPromptForRating() -> Bool {
        // Don't prompt if user has declined
        if hasDeclined {
            return false
        }

        // Check if we've already prompted for this version
        if let lastVersion = lastPromptedVersion, lastVersion == currentAppVersion {
            return false
        }

        // Must have completed minimum sessions
        guard sessionCount >= minimumSessions else {
            return false
        }

        // If this is a new version, we can prompt immediately (after minimum sessions)
        if let lastVersion = lastPromptedVersion, lastVersion != currentAppVersion {
            return true
        }

        // Check if enough time has passed since last prompt (same version scenario)
        if let lastPrompt = lastPromptDate {
            let daysSincePrompt = Calendar.current.dateComponents(
                [.day],
                from: lastPrompt,
                to: Date()
            ).day ?? 0

            return daysSincePrompt >= daysBetweenPrompts
        }

        // Never prompted before - OK to prompt
        return true
    }
}
