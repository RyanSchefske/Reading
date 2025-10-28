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
                choiceCards
                AdBannerView()
                    .frame(height: 50)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color.readerBackground.ignoresSafeArea())
        .navigationTitle("Choices")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onAppear()
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
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 16,
                    x: 0,
                    y: 12
                )
        )
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
                    .fill(Color.white)
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

// MARK: - Previews

struct ReadingChoicesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReadingChoicesView(readingText: "Sample text to demonstrate reading options.")
        }
    }
}
