//
//  StatCard.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

/// Reusable card component for displaying a single statistic
struct StatCard: View {

    // MARK: - Properties

    let icon: String
    let title: String
    let value: String
    let color: Color

    // MARK: - Initialization

    init(icon: String, title: String, value: String, color: Color = .readerAccent) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Previews

struct StatCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            StatCard(
                icon: "book.fill",
                title: "Words Read",
                value: "12,345"
            )

            StatCard(
                icon: "flame.fill",
                title: "Current Streak",
                value: "7 days 🔥",
                color: .orange
            )
        }
        .padding()
        .background(Color.readerBackground)
    }
}
