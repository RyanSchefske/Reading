//
//  ReadingHistoryItem.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//  Copyright © 2025 Ryan Schefske. All rights reserved.
//

import Foundation

struct ReadingHistoryItem: Identifiable, Codable {
    let id: UUID
    let text: String
    let date: Date
    let wordCount: Int

    var title: String {
        // First 50 characters as title
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 50 {
            return trimmed
        }
        let index = trimmed.index(trimmed.startIndex, offsetBy: 50)
        return String(trimmed[..<index]) + "..."
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    init(id: UUID = UUID(), text: String, date: Date = Date()) {
        self.id = id
        self.text = text
        self.date = date
        self.wordCount = text.split(separator: " ").count
    }
}
