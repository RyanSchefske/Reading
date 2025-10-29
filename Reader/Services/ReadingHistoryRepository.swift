//
//  ReadingHistoryRepository.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//  Copyright © 2025 Ryan Schefske. All rights reserved.
//

import Foundation

@MainActor
final class ReadingHistoryRepository: ObservableObject {

    // MARK: - Singleton

    static let shared = ReadingHistoryRepository()

    // MARK: - Properties

    @Published private(set) var history: [ReadingHistoryItem] = []

    private let key = "readingHistory"
    private let maxItems = 50
    private let freeUserLimit = 10

    // MARK: - Computed Properties

    /// Returns history limited by subscription tier
    var displayHistory: [ReadingHistoryItem] {
        if SubscriptionManager.shared.isPro {
            return history
        } else {
            return Array(history.prefix(freeUserLimit))
        }
    }

    var isAtFreeLimit: Bool {
        !SubscriptionManager.shared.isPro && history.count >= freeUserLimit
    }

    // MARK: - Initialization

    private init() {
        loadHistory()
    }

    // MARK: - Public Methods

    func save(_ item: ReadingHistoryItem) {
        // Insert at beginning (most recent first)
        history.insert(item, at: 0)

        // Keep only the last maxItems
        if history.count > maxItems {
            history = Array(history.prefix(maxItems))
        }

        persist()
    }

    func delete(_ id: UUID) {
        history.removeAll { $0.id == id }
        persist()
    }

    func deleteAll() {
        history.removeAll()
        persist()
    }

    func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            history = []
            return
        }

        do {
            history = try JSONDecoder().decode([ReadingHistoryItem].self, from: data)
        } catch {
            print("Failed to decode reading history: \(error)")
            history = []
        }
    }

    // MARK: - Private Methods

    private func persist() {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to encode reading history: \(error)")
        }
    }
}
