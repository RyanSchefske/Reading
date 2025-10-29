//
//  ReadingHistoryView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//  Copyright © 2025 Ryan Schefske. All rights reserved.
//

import SwiftUI

struct ReadingHistoryView: View {

    @StateObject private var repository = ReadingHistoryRepository.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAllConfirmation = false

    let onSelectItem: (String) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if repository.history.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .navigationTitle("Reading History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !repository.history.isEmpty {
                        Button(role: .destructive) {
                            HapticManager.shared.light()
                            showDeleteAllConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .alert(
                "Delete All History?",
                isPresented: $showDeleteAllConfirmation,
                actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete All", role: .destructive) {
                        HapticManager.shared.success()
                        repository.deleteAll()
                    }
                },
                message: {
                    Text("This will permanently delete all reading history.")
                }
            )
        }
    }

    // MARK: - Subviews

    private var historyList: some View {
        List {
            // Upgrade prompt for free users at limit
            if repository.isAtFreeLimit {
                Section {
                    Button {
                        HapticManager.shared.light()
                        subscriptionManager.showPaywall = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Upgrade for Unlimited History")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("Free users see last 10 items only")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }

            // History items
            ForEach(repository.displayHistory) { item in
                HistoryRow(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticManager.shared.medium()
                        onSelectItem(item.text)
                        dismiss()
                    }
            }
            .onDelete { indexSet in
                HapticManager.shared.light()
                indexSet.forEach { index in
                    let itemToDelete = repository.displayHistory[index]
                    repository.delete(itemToDelete.id)
                }
            }
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("No Reading History")
                    .font(.title2.bold())

                Text("Your reading history will appear here after you start reading")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - History Row

private struct HistoryRow: View {
    let item: ReadingHistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
                .lineLimit(2)

            HStack {
                Label("\(item.wordCount) words", systemImage: "text.word.spacing")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(item.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct ReadingHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingHistoryView { _ in }
    }
}
