//
//  SubscriptionManager.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import Foundation
import RevenueCat

/// Manages subscription state and purchases using RevenueCat
@MainActor
final class SubscriptionManager: ObservableObject {

    // MARK: - Singleton

    static let shared = SubscriptionManager()

    // MARK: - Published Properties

    @Published private(set) var currentTier: SubscriptionTier = .free
    @Published private(set) var isLoading = false
    @Published var showPaywall = false

    // MARK: - Properties

    /// Entitlement identifier from RevenueCat dashboard
    private let entitlementID = "pro"

    // MARK: - Computed Properties

    var isPro: Bool {
        currentTier == .pro
    }

    var hasActiveSubscription: Bool {
        isPro
    }

    // MARK: - Initialization

    private init() {
        Task {
            await checkSubscriptionStatus()
        }
    }

    // MARK: - Public Methods

    /// Configure RevenueCat SDK (call from AppDelegate)
    static func configure(apiKey: String) {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
    }

    /// Check current subscription status
    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updateSubscriptionTier(from: customerInfo)
        } catch {
            print("Failed to fetch customer info: \(error)")
            currentTier = .free
        }
    }

    /// Purchase a subscription package
    func purchase(package: Package) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            updateSubscriptionTier(from: result.customerInfo)
            HapticManager.shared.success()
        } catch {
            HapticManager.shared.error()
            throw error
        }
    }

    /// Restore previous purchases
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            updateSubscriptionTier(from: customerInfo)

            if isPro {
                HapticManager.shared.success()
            } else {
                HapticManager.shared.warning()
            }
        } catch {
            HapticManager.shared.error()
            throw error
        }
    }

    /// Check if user has access to a specific feature
    func hasAccess(to feature: PremiumFeature) -> Bool {
        switch feature {
        case .aiSummary, .advancedStats, .unlimitedHistory, .savedTexts, .exportShare, .customThemes, .icloudSync:
            return isPro
        case .adFree:
            return isPro
        }
    }

    // MARK: - Private Methods

    private func updateSubscriptionTier(from customerInfo: CustomerInfo) {
        if customerInfo.entitlements[entitlementID]?.isActive == true {
            currentTier = .pro
        } else {
            currentTier = .free
        }
    }
}

// MARK: - Premium Features

enum PremiumFeature {
    case aiSummary
    case advancedStats
    case unlimitedHistory
    case savedTexts
    case exportShare
    case customThemes
    case icloudSync
    case adFree
}
