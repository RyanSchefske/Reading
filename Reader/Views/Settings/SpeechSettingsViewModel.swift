//
//  SpeechSettingsViewModel.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import AVFoundation
import Foundation

@MainActor
final class SpeechSettingsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var availableVoices: [VoiceOption] = []
    @Published var selectedVoice: String
    @Published var selectedSpeed: String

    // MARK: - Constants

    let availableSpeeds = ["Very Slow", "Slow", "Normal", "Fast", "Very Fast"]

    // MARK: - Private Properties

    private var settingsRepository: SettingsRepositoryProtocol

    // MARK: - Voice Option

    struct VoiceOption: Identifiable, Hashable {
        let id: String
        let name: String
        let identifier: String

        init(voice: AVSpeechSynthesisVoice) {
            self.id = voice.identifier
            self.name = voice.name
            self.identifier = voice.identifier
        }
    }

    // MARK: - Initialization

    init(settingsRepository: SettingsRepositoryProtocol = SettingsRepository()) {
        self.settingsRepository = settingsRepository
        self.selectedVoice = settingsRepository.speechVoice
        self.selectedSpeed = settingsRepository.speechSpeed

        loadVoices()
    }

    // MARK: - Public Methods

    func selectVoice(_ voiceName: String) {
        selectedVoice = voiceName
        settingsRepository.speechVoice = voiceName
    }

    func selectSpeed(_ speed: String) {
        selectedSpeed = speed
        settingsRepository.speechSpeed = speed
    }

    // MARK: - Private Methods

    private func loadVoices() {
        let speechVoices = AVSpeechSynthesisVoice.speechVoices()
        availableVoices = speechVoices
            .filter { $0.language.contains("en") }
            .map { VoiceOption(voice: $0) }
            .sorted { $0.name < $1.name }
    }
}
