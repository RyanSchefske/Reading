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

    // MARK: - Computed Properties

    /// Returns stats limited by subscription tier
    var displayStats: ReadingStats {
        if SubscriptionManager.shared.isPro {
            return stats
        } else {
            return filteredStatsForFreeUser()
        }
    }

    var isShowingLimitedStats: Bool {
        !SubscriptionManager.shared.isPro && !stats.dailyStats.isEmpty
    }

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

        updateDailyStats(wordCount: wordCount, duration: duration)
        updateStreak()
        persist()
    }

    /// Reset all statistics (for testing/debugging)
    func resetStats() {
        stats = ReadingStats()
        persist()
    }

    // MARK: - Private Methods

    private func updateDailyStats(wordCount: Int, duration: TimeInterval) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find or create today's daily stats
        if let index = stats.dailyStats.firstIndex(where: {
            calendar.isDate($0.date, inSameDayAs: today)
        }) {
            // Update existing daily stats
            stats.dailyStats[index].wordsRead += wordCount
            stats.dailyStats[index].timeSpent += duration
            stats.dailyStats[index].sessionsCompleted += 1
        } else {
            // Create new daily stats
            let newDailyStats = DailyStats(
                date: today,
                wordsRead: wordCount,
                timeSpent: duration,
                sessionsCompleted: 1
            )
            stats.dailyStats.append(newDailyStats)
        }

        // Keep only last 90 days of daily stats (for Pro users)
        stats.dailyStats = stats.dailyStats.sorted { $0.date > $1.date }
        if stats.dailyStats.count > 90 {
            stats.dailyStats = Array(stats.dailyStats.prefix(90))
        }
    }

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

    private func filteredStatsForFreeUser() -> ReadingStats {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today

        // Filter daily stats to last 7 days
        let recentDailyStats = stats.dailyStats.filter { $0.date >= sevenDaysAgo }

        // Calculate totals from recent stats only
        let recentWordsRead = recentDailyStats.reduce(0) { $0 + $1.wordsRead }
        let recentTimeSpent = recentDailyStats.reduce(0.0) { $0 + $1.timeSpent }
        let recentSessions = recentDailyStats.reduce(0) { $0 + $1.sessionsCompleted }

        var filteredStats = stats
        filteredStats.totalWordsRead = recentWordsRead
        filteredStats.totalTimeSpent = recentTimeSpent
        filteredStats.sessionsCompleted = recentSessions
        filteredStats.dailyStats = recentDailyStats
        // Keep streak info unchanged (still motivational even for free users)

        return filteredStats
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
