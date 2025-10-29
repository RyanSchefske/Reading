//
//  ReadingChoicesView.swift
//  Reader
//
//  Created by GPT Coding Assistant on 11/3/25.
//

import SwiftUI

struct ReadingChoicesView: View {

    @StateObject private var viewModel: ReadingChoicesViewModel

    init(readingText: String) {
        _viewModel = StateObject(
            wrappedValue: ReadingChoicesViewModel(readingText: readingText)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                // AI Summary Button (if available) or Upgrade prompt
                if viewModel.isAISummaryAvailable {
                    aiSummaryButton
                } else if viewModel.shouldShowAISummaryUpgrade {
                    aiSummaryUpgradeButton
                }

                choiceCards
                AdBannerView()
                    .frame(height: 50)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color.readerBackground)
        .navigationTitle("Choices")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onAppear()

            // Save to reading history
            let historyItem = ReadingHistoryItem(text: viewModel.readingText)
            ReadingHistoryRepository.shared.save(historyItem)
        }
        .alert(
            "Error",
            isPresented: $viewModel.showError,
            actions: {
                Button("OK", role: .cancel) {
                    viewModel.showError = false
                    viewModel.errorMessage = nil
                }
            },
            message: {
                if let description = viewModel.errorMessage {
                    Text(description)
                }
            }
        )
        .navigationDestination(item: $viewModel.navigationDestination) { destination in
            switch destination {
            case .speak:
                SpeechReadingView(readingText: viewModel.readingText)
            case .speed:
                SpeedReadingView(readingText: viewModel.readingText)
            case .scroll:
                ScrollReadingView(readingText: viewModel.readingText)
            }
        }
        .modifier(SummarySheetModifier(isPresented: $viewModel.showSummary, text: viewModel.readingText))
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text("How would you like to consume this text?")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text("Pick a mode below to start reading or listening.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 16,
                    x: 0,
                    y: 12
                )
        )
    }

    private var aiSummaryButton: some View {
        Button {
            viewModel.openAISummary()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.title2)
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Summary")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Get key points and a summary using Apple Intelligence")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.readerAccent, Color.readerAccent.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(18)
            .shadow(
                color: Color.readerAccent.opacity(0.3),
                radius: 12,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var aiSummaryUpgradeButton: some View {
        Button {
            HapticManager.shared.light()
            SubscriptionManager.shared.showPaywall = true
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.title2)
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("AI Summary")
                            .font(.headline)
                            .foregroundColor(.white)

                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    Text("Upgrade to Pro to unlock AI-powered summaries")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()

                Image(systemName: "lock.fill")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.purple.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(18)
            .shadow(
                color: Color.purple.opacity(0.3),
                radius: 12,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var choiceCards: some View {
        VStack(spacing: 18) {
            ForEach(ReadingChoicesViewModel.Destination.allCases, id: \.self) { destination in
                ReadingChoiceCard(destination: destination) {
                    viewModel.select(destination)
                }
            }
        }
    }
}

private struct ReadingChoiceCard: View {

    let destination: ReadingChoicesViewModel.Destination
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: destination.systemImageName)
                    .font(.largeTitle)
                    .foregroundColor(.readerAccent)
                VStack(alignment: .leading, spacing: 6) {
                    Text(destination.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(destination.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(uiColor: .tertiarySystemBackground))
            )
        }
        .buttonStyle(ReaderCardButtonStyle())
    }
}

private struct ReaderCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.05 : 0.15),
                radius: 12,
                x: 0,
                y: 10
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Summary Sheet Modifier

private struct SummarySheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let text: String

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.sheet(isPresented: $isPresented) {
                SummaryView(text: text)
            }
        } else {
            content
        }
    }
}

// MARK: - Previews

struct ReadingChoicesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReadingChoicesView(readingText: "Sample text to demonstrate reading options.")
        }
    }
}
