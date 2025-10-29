//
//  ScrollReadingViewModel.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import Foundation
import SwiftUI

@MainActor
final class ScrollReadingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var readingText: String
    @Published var scrollOffset: CGFloat = 0
    @Published var playbackState: PlaybackState = .stopped
    @Published var scrollSpeed: Double = 100
    @Published var isSliderEnabled: Bool = true

    // MARK: - Private Properties

    private var scrollTask: Task<Void, Never>?
    private let maxScrollOffset: CGFloat = 10000 // Will be adjusted based on content

    // MARK: - Playback State

    enum PlaybackState: Equatable {
        case stopped
        case playing
        case paused
    }

    // MARK: - Constants

    let minSpeed: Double = 20
    let maxSpeed: Double = 200
    let speedStep: Double = 5

    // MARK: - Computed Properties

    var playPauseImageName: String {
        playbackState == .playing ? "pause.fill" : "play.fill"
    }

    var scrollSpeedText: String {
        "\(Int(scrollSpeed)) px/s"
    }

    // MARK: - Initialization

    init(readingText: String) {
        self.readingText = readingText.replacingOccurrences(of: "\n", with: "\n\n")
    }

    // MARK: - Public Methods

    func playPause() {
        switch playbackState {
        case .stopped, .paused:
            startScrolling()
        case .playing:
            pauseScrolling()
        }
    }

    func reset() {
        stopScrolling()
        scrollOffset = 0
    }

    func onDisappear() {
        stopScrolling()
    }

    func sliderChanged(_ newValue: Double) {
        let roundedValue = round(newValue / speedStep) * speedStep
        scrollSpeed = roundedValue
    }

    // MARK: - Private Methods

    private func startScrolling() {
        playbackState = .playing
        isSliderEnabled = false

        scrollTask?.cancel()
        scrollTask = Task { @MainActor in
            // 60 FPS update rate
            let updateInterval: Double = 1.0 / 60.0
            let pixelsPerFrame = scrollSpeed / 60.0

            while !Task.isCancelled && playbackState == .playing {
                try? await Task.sleep(nanoseconds: UInt64(updateInterval * 1_000_000_000))

                guard !Task.isCancelled else { break }

                scrollOffset += pixelsPerFrame

                // Check if we've reached the end (simplified - actual end depends on content height)
                if scrollOffset >= maxScrollOffset {
                    stopScrolling()
                    reset()

                    // Increment session count for rating prompt
                    RatingManager.shared.incrementSessionCount()

                    break
                }
            }
        }
    }

    private func pauseScrolling() {
        playbackState = .paused
        isSliderEnabled = true
        scrollTask?.cancel()
        scrollTask = nil
    }

    private func stopScrolling() {
        playbackState = .stopped
        isSliderEnabled = true
        scrollTask?.cancel()
        scrollTask = nil
    }
}
