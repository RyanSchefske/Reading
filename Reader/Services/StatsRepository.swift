//
//  StatsRepository.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import Foundation

/// Manages reading statistics persistence and updates
@MainActor
final class StatsRepository: ObservableObject {

    // MARK: - Singleton

    static let shared = StatsRepository()

    // MARK: - Published Properties

    @Published private(set) var stats: ReadingStats

    // MARK: - Private Properties

    private let key = "readingStats"

    // MARK: - Initialization

    private init() {
        self.stats = Self.loadStatsFromStorage()
    }

    // MARK: - Public Methods

    /// Record a completed reading session
    func recordSession(wordCount: Int, duration: TimeInterval) {
        stats.totalWordsRead += wordCount
        stats.totalTimeSpent += duration
        stats.sessionsCompleted += 1

        updateStreak()
        persist()
    }

    /// Reset all statistics (for testing/debugging)
    func resetStats() {
        stats = ReadingStats()
        persist()
    }

    // MARK: - Private Methods

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = stats.lastReadDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDiff == 0 {
                // Same day - no streak change, just update timestamp
                stats.lastReadDate = Date()
            } else if daysDiff == 1 {
                // Next day - continue streak
                stats.streakDays += 1
                stats.lastReadDate = Date()

                // Update longest streak if needed
                if stats.streakDays > stats.longestStreak {
                    stats.longestStreak = stats.streakDays
                }
            } else {
                // Streak broken - start new streak
                stats.streakDays = 1
                stats.lastReadDate = Date()
            }
        } else {
            // First ever session
            stats.streakDays = 1
            stats.longestStreak = 1
            stats.lastReadDate = Date()
        }
    }

    private func persist() {
        do {
            let encoded = try JSONEncoder().encode(stats)
            UserDefaults.standard.set(encoded, forKey: key)
        } catch {
            print("Failed to encode reading stats: \(error)")
        }
    }

    private static func loadStatsFromStorage() -> ReadingStats {
        guard let data = UserDefaults.standard.data(forKey: "readingStats"),
              let decoded = try? JSONDecoder().decode(ReadingStats.self, from: data) else {
            return ReadingStats()
        }
        return decoded
    }
}
