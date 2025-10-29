//
//  SubscriptionTier.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import Foundation

/// Subscription tiers available in the app
enum SubscriptionTier: String, CaseIterable {
    case free
    case pro

    // MARK: - Display Properties

    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .pro:
            return "Scholarly Pro"
        }
    }

    var features: [SubscriptionFeature] {
        switch self {
        case .free:
            return [
                SubscriptionFeature(
                    icon: "book.fill",
                    title: "All 3 Reading Modes",
                    description: "Speed reading, text-to-speech, and auto-scroll"
                ),
                SubscriptionFeature(
                    icon: "doc.text.viewfinder",
                    title: "OCR Document Scanning",
                    description: "Scan and read from physical documents"
                ),
                SubscriptionFeature(
                    icon: "clock",
                    title: "Limited History",
                    description: "Last 10 reading sessions"
                ),
                SubscriptionFeature(
                    icon: "chart.bar",
                    title: "Basic Statistics",
                    description: "Last 7 days only"
                )
            ]
        case .pro:
            return [
                SubscriptionFeature(
                    icon: "sparkles",
                    title: "AI-Powered Summaries",
                    description: "Get key points and summaries instantly",
                    isPremium: true
                ),
                SubscriptionFeature(
                    icon: "nosign",
                    title: "Ad-Free Experience",
                    description: "No interruptions, pure focus",
                    isPremium: true
                ),
                SubscriptionFeature(
                    icon: "clock.arrow.circlepath",
                    title: "Unlimited History",
                    description: "Access all past reading sessions",
                    isPremium: true
                ),
                SubscriptionFeature(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Advanced Statistics",
                    description: "Streaks, all-time stats, and insights",
                    isPremium: true
                ),
                SubscriptionFeature(
                    icon: "folder.fill",
                    title: "Save Unlimited Texts",
                    description: "Build your personal reading library",
                    isPremium: true
                ),
                SubscriptionFeature(
                    icon: "square.and.arrow.up",
                    title: "Export & Share",
                    description: "Export texts and share stats",
                    isPremium: true
                ),
                SubscriptionFeature(
                    icon: "paintbrush.fill",
                    title: "Custom Themes",
                    description: "Personalize your reading experience",
                    isPremium: true
                ),
                SubscriptionFeature(
                    icon: "icloud.fill",
                    title: "iCloud Sync",
                    description: "Access your library across all devices",
                    isPremium: true,
                    isComingSoon: true
                )
            ]
        }
    }
}

// MARK: - Subscription Feature

struct SubscriptionFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let isPremium: Bool
    let isComingSoon: Bool

    init(icon: String, title: String, description: String, isPremium: Bool = false, isComingSoon: Bool = false) {
        self.icon = icon
        self.title = title
        self.description = description
        self.isPremium = isPremium
        self.isComingSoon = isComingSoon
    }
}
