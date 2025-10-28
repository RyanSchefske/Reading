//
//  AdManager.swift
//  Reader
//
//  Created by Claude Code Assistant on 10/27/24.
//  Copyright © 2024 Ryan Schefske. All rights reserved.
//

import GoogleMobileAds
import UIKit

/// Centralized manager for Google AdMob integration
///
/// This singleton manager handles all AdMob banner and interstitial ad operations,
/// replacing the previous UIView extension pattern with a cleaner, more maintainable approach.
///
/// Example usage:
/// ```swift
/// // Add banner to view
/// AdManager.shared.addBannerToView(view, viewController: self)
///
/// // Load and show interstitial
/// AdManager.shared.loadInterstitial()
/// AdManager.shared.showInterstitial(from: self)
/// ```
final class AdManager: NSObject {

    // MARK: - Singleton

    static let shared = AdManager()

    // MARK: - Properties

    /// Ad Unit IDs from Firebase Console
    private struct AdUnitIDs {
        static let banner = "ca-app-pub-2392719817363402~9276402219"
        static let interstitial = "ca-app-pub-2392719817363402~6341211139"

        // Test ad unit IDs (used in DEBUG mode)
        static let testBanner = "ca-app-pub-3940256099942544/2934735716"
        static let testInterstitial = "ca-app-pub-3940256099942544/4411468910"
    }

    #if DEBUG
    /// Use test ads in debug mode to avoid policy violations
    private let testMode = true
    #else
    private let testMode = false
    #endif

    /// Currently loaded interstitial ad
    private var interstitialAd: InterstitialAd?

    /// Track if interstitial is loading to prevent duplicate requests
    private var isLoadingInterstitial = false

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    // MARK: - Banner Ads

    /// Creates and configures a banner ad view
    ///
    /// - Parameters:
    ///   - viewController: The view controller that will present the ad
    ///   - delegate: Optional custom delegate for banner events
    /// - Returns: Configured BannerView ready to be added to view hierarchy
    func createBannerView(
        for viewController: UIViewController,
        delegate: BannerViewDelegate? = nil
    ) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = testMode ? AdUnitIDs.testBanner : AdUnitIDs.banner
        bannerView.rootViewController = viewController
        bannerView.delegate = delegate ?? self
        return bannerView
    }

    /// Adds a banner ad to the bottom of a view with proper constraints
    ///
    /// - Parameters:
    ///   - view: The parent view to add the banner to
    ///   - viewController: The view controller presenting the ad
    ///   - delegate: Optional custom delegate for banner events
    func addBannerToView(
        _ view: UIView,
        viewController: UIViewController,
        delegate: BannerViewDelegate? = nil
    ) {
        let bannerView = createBannerView(for: viewController, delegate: delegate)

        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Load ad
        bannerView.load(Request())
    }

    // MARK: - Interstitial Ads

    /// Loads an interstitial ad for later display
    ///
    /// - Parameter completion: Optional completion handler with success status
    func loadInterstitial(completion: ((Bool) -> Void)? = nil) {
        guard !isLoadingInterstitial else {
            print("⚠️ Interstitial ad already loading")
            completion?(false)
            return
        }

        isLoadingInterstitial = true

        let adUnitID = testMode ? AdUnitIDs.testInterstitial : AdUnitIDs.interstitial

        InterstitialAd.load(
            with: adUnitID,
            request: Request()
        ) { [weak self] ad, error in
            guard let self = self else { return }

            self.isLoadingInterstitial = false

            if let error = error {
                print("❌ Failed to load interstitial ad: \(error.localizedDescription)")
                completion?(false)
                return
            }

            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            print("✅ Interstitial ad loaded successfully")
            completion?(true)
        }
    }

    /// Shows the loaded interstitial ad
    ///
    /// - Parameter viewController: The view controller to present the ad from
    /// - Returns: True if ad was shown, false if not loaded
    @discardableResult
    func showInterstitial(from viewController: UIViewController) -> Bool {
        guard let interstitialAd = interstitialAd else {
            print("⚠️ Interstitial ad not loaded, loading now for next time")
            // Preload for next time
            loadInterstitial()
            return false
        }

        interstitialAd.present(from: viewController)
        return true
    }
}

// MARK: - BannerViewDelegate

extension AdManager: BannerViewDelegate {

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("✅ Banner ad loaded successfully")
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("❌ Banner ad failed to load: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        print("📊 Banner ad impression recorded")
    }

    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        print("📱 Banner ad will present screen")
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        print("📱 Banner ad will dismiss screen")
    }

    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        print("📱 Banner ad dismissed screen")
    }
}

// MARK: - FullScreenContentDelegate

extension AdManager: FullScreenContentDelegate {

    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("📊 Interstitial ad impression recorded")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("👆 Interstitial ad clicked")
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Interstitial ad failed to present: \(error.localizedDescription)")
        // Load a new ad for next time
        loadInterstitial()
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📱 Interstitial ad will present")
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📱 Interstitial ad will dismiss")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📱 Interstitial ad dismissed")
        // Clear the ad and load a new one for next time
        interstitialAd = nil
        loadInterstitial()
    }
}
