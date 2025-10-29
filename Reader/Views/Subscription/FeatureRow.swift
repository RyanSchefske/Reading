//
//  FeatureRow.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

/// Displays a single feature in the paywall list
struct FeatureRow: View {

    // MARK: - Properties

    let feature: SubscriptionFeature

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.readerAccent, Color.readerAccent.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            // Text
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(feature.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if feature.isComingSoon {
                        Text("Soon")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.orange)
                            )
                    }
                }

                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.green)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Previews

struct FeatureRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FeatureRow(
                feature: SubscriptionFeature(
                    icon: "sparkles",
                    title: "AI-Powered Summaries",
                    description: "Get key points and summaries instantly",
                    isPremium: true
                )
            )

            FeatureRow(
                feature: SubscriptionFeature(
                    icon: "icloud.fill",
                    title: "iCloud Sync",
                    description: "Access your library across all devices",
                    isPremium: true,
                    isComingSoon: true
                )
            )
        }
        .padding()
    }
}
