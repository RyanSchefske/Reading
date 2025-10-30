//
//  SpeechSettingsView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

struct SpeechSettingsView: View {

    @StateObject private var viewModel = SpeechSettingsViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            if !subscriptionManager.isPro {
                upgradeSection
            }
            voiceSection
            speedSection
            legalSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.readerAccent)
            }
        }
    }

    // MARK: - Sections

    private var voiceSection: some View {
        Section {
            ForEach(viewModel.availableVoices) { voice in
                Button {
                    viewModel.selectVoice(voice.name)
                } label: {
                    HStack {
                        Text(voice.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if voice.name == viewModel.selectedVoice {
                            Image(systemName: "checkmark")
                                .foregroundColor(.readerAccent)
                        }
                    }
                }
            }
        } header: {
            Text("Voice")
        }
    }

    private var upgradeSection: some View {
        Section {
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
                            .frame(width: 44, height: 44)

                        Image(systemName: "crown.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Upgrade to Scholarly Pro")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("Unlock AI summaries, unlimited history, and more")
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

    private var speedSection: some View {
        Section {
            ForEach(viewModel.availableSpeeds, id: \.self) { speed in
                Button {
                    viewModel.selectSpeed(speed)
                } label: {
                    HStack {
                        Text(speed)
                            .foregroundColor(.primary)
                        Spacer()
                        if speed == viewModel.selectedSpeed {
                            Image(systemName: "checkmark")
                                .foregroundColor(.readerAccent)
                        }
                    }
                }
            }
        } header: {
            Text("Speed")
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: "https://ryanschefske.github.io/scholarlyPrivacyPolicyindex")!) {
                HStack {
                    Text("Privacy Policy")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Link(destination: URL(string: "https://ryanschefske.github.io/scholarlyTermsAndConditionsindex")!) {
                HStack {
                    Text("Terms and Conditions")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Legal")
        }
    }
}

// MARK: - Previews

struct SpeechSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpeechSettingsView()
        }
    }
}
