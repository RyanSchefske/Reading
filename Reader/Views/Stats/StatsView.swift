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
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Upgrade banner for free users
                    if repository.isShowingLimitedStats {
                        upgradeBanner
                    }

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

    private var upgradeBanner: some View {
        Button {
            HapticManager.shared.light()
            subscriptionManager.showPaywall = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.readerAccent, Color.readerAccent.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: "crown.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Showing Last 7 Days Only")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Upgrade to Pro for all-time statistics")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.readerAccent)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
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
                value: formatNumber(repository.displayStats.totalWordsRead)
            )

            StatCard(
                icon: "clock.fill",
                title: "Time Spent",
                value: repository.displayStats.formattedTotalTime
            )

            StatCard(
                icon: "checkmark.circle.fill",
                title: "Sessions",
                value: "\(repository.displayStats.sessionsCompleted)",
                color: .green
            )

            StatCard(
                icon: "gauge.high",
                title: "Avg WPM",
                value: "\(repository.displayStats.averageWPM)",
                color: .purple
            )

            StatCard(
                icon: "flame.fill",
                title: "Current Streak",
                value: repository.displayStats.streakText,
                color: .orange
            )

            StatCard(
                icon: "trophy.fill",
                title: "Longest Streak",
                value: repository.displayStats.longestStreakText,
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
