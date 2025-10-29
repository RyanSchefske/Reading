//
//  StatsView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

struct StatsView: View {

    // MARK: - Properties

    @StateObject private var repository = StatsRepository.shared

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if repository.stats.sessionsCompleted == 0 {
                        emptyState
                    } else {
                        statsGrid
                    }
                }
                .padding()
            }
            .background(Color.readerBackground)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Components

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("No Statistics Yet")
                    .font(.title2.bold())

                Text("Complete a reading session to see your stats and track your progress.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }

    private var statsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            StatCard(
                icon: "book.fill",
                title: "Words Read",
                value: formatNumber(repository.stats.totalWordsRead)
            )

            StatCard(
                icon: "clock.fill",
                title: "Time Spent",
                value: repository.stats.formattedTotalTime
            )

            StatCard(
                icon: "checkmark.circle.fill",
                title: "Sessions",
                value: "\(repository.stats.sessionsCompleted)",
                color: .green
            )

            StatCard(
                icon: "gauge.high",
                title: "Avg WPM",
                value: "\(repository.stats.averageWPM)",
                color: .purple
            )

            StatCard(
                icon: "flame.fill",
                title: "Current Streak",
                value: repository.stats.streakText,
                color: .orange
            )

            StatCard(
                icon: "trophy.fill",
                title: "Longest Streak",
                value: repository.stats.longestStreakText,
                color: .yellow
            )
        }
    }

    // MARK: - Helper Methods

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Previews

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
