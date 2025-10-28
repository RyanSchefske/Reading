//
//  ReadingChoicesViewModel.swift
//  Reader
//
//  Created by GPT Coding Assistant on 11/3/25.
//

import Foundation
import UIKit

@MainActor
final class ReadingChoicesViewModel: ObservableObject {

    enum Destination: Hashable, Identifiable, CaseIterable {
        case speak
        case speed
        case scroll

        var id: String {
            switch self {
            case .speak:
                return "speak"
            case .speed:
                return "speed"
            case .scroll:
                return "scroll"
            }
        }

        var title: String {
            switch self {
            case .speak:
                return "Speak"
            case .speed:
                return "Speed Read"
            case .scroll:
                return "Scroll"
            }
        }

        var subtitle: String {
            switch self {
            case .speak:
                return "Play the text with adjustable voices & speed."
            case .speed:
                return "Rapidly flash words to increase reading pace."
            case .scroll:
                return "Auto-scroll the passage with custom WPM."
            }
        }

        var systemImageName: String {
            switch self {
            case .speak:
                return "waveform.circle.fill"
            case .speed:
                return "bolt.circle.fill"
            case .scroll:
                return "text.justify.left"
            }
        }
    }

    // MARK: - Published State

    @Published var navigationDestination: Destination?
    @Published var showError: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    let readingText: String
    private let settingsRepository: SettingsRepositoryProtocol

    // MARK: - Private State

    private var clicks: Int = 0

    // MARK: - Initialization

    init(
        readingText: String,
        settingsRepository: SettingsRepositoryProtocol = SettingsRepository()
    ) {
        self.readingText = readingText
        self.settingsRepository = settingsRepository
        self.clicks = settingsRepository.clicks
    }

    // MARK: - Lifecycle

    func onAppear() {
        AdManager.shared.loadInterstitial()
    }

    // MARK: - User Actions

    func select(_ destination: Destination) {
        clicks += 1
        settingsRepository.clicks = clicks

        Task { @MainActor [weak self] in
            guard let self = self else { return }

            presentInterstitialIfNeeded()
            navigationDestination = destination
        }
    }

    // MARK: - Helpers

    private func presentInterstitialIfNeeded() {
        guard clicks % 2 == 0 else { return }

        guard let presenter = UIApplication.shared.topViewController() else {
            errorMessage = "Unable to present advertisement."
            showError = true
            return
        }

        _ = AdManager.shared.showInterstitial(from: presenter)
    }
}
