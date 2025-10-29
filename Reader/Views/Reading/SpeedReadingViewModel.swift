//
//  SpeedReadingViewModel.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import Foundation
import SwiftUI

@MainActor
final class SpeedReadingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var readingText: String
    @Published var words: [String] = []
    @Published var currentWordIndex: Int = 0
    @Published var displayedWord: AttributedString = AttributedString("")
    @Published var playbackState: PlaybackState = .stopped
    @Published var wordsPerMinute: Double = 100
    @Published var isSliderEnabled: Bool = true

    // MARK: - Private Properties

    private var timer: Task<Void, Never>?
    private var sessionStartTime: Date?

    // MARK: - Playback State

    enum PlaybackState: Equatable {
        case stopped
        case playing
        case paused
    }

    // MARK: - Constants

    let minWPM: Double = 50
    let maxWPM: Double = 800
    let wpmStep: Double = 5

    // MARK: - Computed Properties

    var currentWordDisplay: String {
        guard currentWordIndex < words.count else { return "" }
        return words[currentWordIndex]
    }

    var playPauseImageName: String {
        playbackState == .playing ? "pause.fill" : "play.fill"
    }

    // MARK: - Initialization

    init(readingText: String) {
        self.readingText = readingText.replacingOccurrences(of: "\n", with: " ")
        self.words = self.readingText.components(separatedBy: " ").filter { !$0.isEmpty }
        updateDisplayedWord()
    }

    // MARK: - Public Methods

    func playPause() {
        switch playbackState {
        case .stopped:
            startReading()
        case .playing:
            pauseReading()
        case .paused:
            resumeReading()
        }
    }

    func reset() {
        stopReading()
        currentWordIndex = 0
        updateDisplayedWord()
    }

    func skipForward() {
        guard currentWordIndex + 10 < words.count else { return }
        currentWordIndex += 10
        updateDisplayedWord()
    }

    func skipBackward() {
        guard currentWordIndex >= 10 else {
            currentWordIndex = 0
            updateDisplayedWord()
            return
        }
        currentWordIndex -= 10
        updateDisplayedWord()
    }

    func onDisappear() {
        stopReading()
    }

    func sliderChanged(_ newValue: Double) {
        // Round to nearest step
        let roundedValue = round(newValue / wpmStep) * wpmStep
        wordsPerMinute = roundedValue
    }

    // MARK: - Private Methods

    private func startReading() {
        playbackState = .playing
        isSliderEnabled = false

        // Track session start time
        if sessionStartTime == nil {
            sessionStartTime = Date()
        }

        scheduleNextWord()
    }

    private func pauseReading() {
        playbackState = .paused
        isSliderEnabled = true
        timer?.cancel()
        timer = nil
    }

    private func resumeReading() {
        playbackState = .playing
        isSliderEnabled = false
        scheduleNextWord()
    }

    private func stopReading() {
        playbackState = .stopped
        isSliderEnabled = true
        timer?.cancel()
        timer = nil
    }

    private func scheduleNextWord() {
        let interval = 60.0 / wordsPerMinute

        timer?.cancel()
        timer = Task { @MainActor in
            while !Task.isCancelled && playbackState == .playing {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

                guard !Task.isCancelled else { break }

                if currentWordIndex < words.count {
                    updateDisplayedWord()
                    currentWordIndex += 1
                } else {
                    // Reached end - record stats
                    if let startTime = sessionStartTime {
                        let duration = Date().timeIntervalSince(startTime)
                        StatsRepository.shared.recordSession(wordCount: words.count, duration: duration)
                        sessionStartTime = nil
                    }

                    stopReading()
                    reset()

                    // Check for milestone paywall or rating prompt
                    let shouldShowPaywall = RatingManager.shared.incrementSessionCount()
                    if shouldShowPaywall {
                        SubscriptionManager.shared.showPaywall = true
                        RatingManager.shared.markMilestonePaywallShown()
                    }

                    break
                }
            }
        }
    }

    private func updateDisplayedWord() {
        guard currentWordIndex < words.count else {
            displayedWord = AttributedString("")
            return
        }

        let word = words[currentWordIndex]
        var attributed = AttributedString(word)

        // Highlight the third character (focal point for speed reading)
        if word.count > 2 {
            let index = word.index(word.startIndex, offsetBy: 2)
            let range = index...index

            if let attributedRange = Range(range, in: attributed) {
                attributed[attributedRange].foregroundColor = .readerAccent
                attributed[attributedRange].font = .system(size: 30, weight: .bold)
            }
        }

        displayedWord = attributed
    }
}
