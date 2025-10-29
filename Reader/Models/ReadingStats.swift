//
//  ReadingStats.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import Foundation

/// Tracks user's reading statistics and progress
struct ReadingStats: Codable {

    // MARK: - Properties

    var totalWordsRead: Int = 0
    var totalTimeSpent: TimeInterval = 0
    var sessionsCompleted: Int = 0
    var streakDays: Int = 0
    var longestStreak: Int = 0
    var lastReadDate: Date?

    // MARK: - Computed Properties

    /// Average words per minute across all sessions
    var averageWPM: Int {
        guard totalTimeSpent > 0 else { return 0 }
        let minutes = totalTimeSpent / 60.0
        return Int(Double(totalWordsRead) / minutes)
    }

    /// Total time formatted as hours and minutes
    var formattedTotalTime: String {
        let hours = Int(totalTimeSpent) / 3600
        let minutes = (Int(totalTimeSpent) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// Current streak display text
    var streakText: String {
        if streakDays == 0 {
            return "Start reading to build a streak!"
        } else if streakDays == 1 {
            return "1 day 🔥"
        } else {
            return "\(streakDays) days 🔥"
        }
    }

    /// Longest streak display text
    var longestStreakText: String {
        if longestStreak == 0 {
            return "No streak yet"
        } else if longestStreak == 1 {
            return "1 day"
        } else {
            return "\(longestStreak) days"
        }
    }
}
