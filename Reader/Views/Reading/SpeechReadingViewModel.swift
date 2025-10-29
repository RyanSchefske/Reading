//
//  SpeechReadingViewModel.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import AVFoundation
import Foundation
import SwiftUI

@MainActor
final class SpeechReadingViewModel: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var readingText: String
    @Published var attributedText: AttributedString
    @Published var playbackState: PlaybackState = .stopped
    @Published var showSettings = false

    // MARK: - Private Properties

    private let synthesizer = AVSpeechSynthesizer()
    private let settingsRepository: SettingsRepositoryProtocol
    private var currentUtterance: AVSpeechUtterance?

    private var speechIdentifier: String = ""
    private var speechRate: Float = 0.5

    // MARK: - Playback State

    enum PlaybackState: Equatable {
        case stopped
        case playing
        case paused
    }

    // MARK: - Initialization

    init(readingText: String, settingsRepository: SettingsRepositoryProtocol = SettingsRepository()) {
        self.readingText = readingText
        self.attributedText = AttributedString(readingText)
        self.settingsRepository = settingsRepository

        super.init()

        synthesizer.delegate = self
        loadSettings()
    }

    // MARK: - Public Methods

    func playPause() {
        switch playbackState {
        case .stopped:
            startSpeaking()
        case .playing:
            pauseSpeaking()
        case .paused:
            resumeSpeaking()
        }
    }

    func reset() {
        stopSpeaking()
        attributedText = AttributedString(readingText)
    }

    func onAppear() {
        loadSettings()
    }

    func onDisappear() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
        }
    }

    // MARK: - Private Methods

    private func loadSettings() {
        // Get saved voice and find its identifier
        let savedVoice = settingsRepository.speechVoice
        let speechVoices = AVSpeechSynthesisVoice.speechVoices()

        if let voice = speechVoices.first(where: { $0.name == savedVoice }) {
            speechIdentifier = voice.identifier
        } else {
            // Fallback to Daniel if saved voice not found
            speechIdentifier = "com.apple.ttsbundle.Daniel-compact"
        }

        // Convert speed string to rate value
        let savedSpeed = settingsRepository.speechSpeed
        switch savedSpeed {
        case "Very Slow":
            speechRate = 0.2
        case "Slow":
            speechRate = 0.35
        case "Normal":
            speechRate = 0.5
        case "Fast":
            speechRate = 0.65
        case "Very Fast":
            speechRate = 0.75
        default:
            speechRate = 0.5
        }
    }

    private func startSpeaking() {
        let utterance = AVSpeechUtterance(string: readingText)
        utterance.voice = AVSpeechSynthesisVoice(identifier: speechIdentifier)
        utterance.rate = speechRate

        currentUtterance = utterance
        synthesizer.speak(utterance)
        playbackState = .playing
    }

    private func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .immediate)
        playbackState = .paused
    }

    private func resumeSpeaking() {
        synthesizer.continueSpeaking()
        playbackState = .playing
    }

    private func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        playbackState = .stopped
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechReadingViewModel: AVSpeechSynthesizerDelegate {

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            highlightText(in: characterRange)
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            attributedText = AttributedString(readingText)
            playbackState = .stopped

            // Increment session count for rating prompt
            RatingManager.shared.incrementSessionCount()
        }
    }

    private func highlightText(in range: NSRange) {
        var attributed = AttributedString(readingText)

        // Convert NSRange to AttributedString range
        if let stringRange = Range(range, in: readingText),
           let attributedRange = Range(stringRange, in: attributed) {
            attributed[attributedRange].backgroundColor = .yellow
        }

        attributedText = attributed
    }
}
