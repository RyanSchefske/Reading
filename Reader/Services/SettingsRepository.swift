//
//  SettingsRepository.swift
//  Reader
//
//  Created by Claude Code on 10/27/25.
//

import Foundation

/// Protocol defining the settings repository interface
/// Enables dependency injection and testing
protocol SettingsRepositoryProtocol {
    var speechVoice: String { get set }
    var speechSpeed: String { get set }
    var clicks: Int { get set }
}

/// Type-safe repository for managing user settings
/// Abstracts UserDefaults access for better testability and maintainability
final class SettingsRepository: SettingsRepositoryProtocol {

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Keys

    private enum Keys {
        static let speechVoice = "SpeechVoice"
        static let speechSpeed = "SpeechSpeed"
        static let clicks = "clicks"
    }

    // MARK: - Default Values

    private enum Defaults {
        static let speechVoice = "Daniel"
        static let speechSpeed = "Normal"
        static let clicks = 0
    }

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Settings

    var speechVoice: String {
        get {
            userDefaults.string(forKey: Keys.speechVoice) ?? Defaults.speechVoice
        }
        set {
            userDefaults.set(newValue, forKey: Keys.speechVoice)
        }
    }

    var speechSpeed: String {
        get {
            userDefaults.string(forKey: Keys.speechSpeed) ?? Defaults.speechSpeed
        }
        set {
            userDefaults.set(newValue, forKey: Keys.speechSpeed)
        }
    }

    var clicks: Int {
        get {
            userDefaults.integer(forKey: Keys.clicks)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.clicks)
        }
    }
}
