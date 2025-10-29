//
//  SpeechRecognizerView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

struct SpeechRecognizerView: View {

    @StateObject private var viewModel = SpeechRecognizerViewModel()
    @Environment(\.dismiss) private var dismiss

    let onTextRecognized: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                textDisplaySection
                controlButtons
                AdBannerView()
                    .frame(height: 50)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color.readerBackground.ignoresSafeArea())
        .navigationTitle("Speech Recognizer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    handleDone()
                }
                .foregroundColor(.readerAccent)
            }
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
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        )
    }

    // MARK: - Subviews

    private var textDisplaySection: some View {
        ScrollView {
            Text(viewModel.recognizedText)
                .font(.body)
                .foregroundColor(viewModel.isRecording ? .primary : .secondary)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 300)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 12)
        )
    }

    private var controlButtons: some View {
        VStack(spacing: 16) {
            startStopButton
        }
    }

    private var startStopButton: some View {
        Button {
            viewModel.startStopButtonTapped()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.fill")
                    .font(.title2)
                Text(viewModel.startStopButtonTitle)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .background(viewModel.isRecording ? Color.red : Color.readerAccent)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(
            color: Color.black.opacity(0.18),
            radius: 10,
            x: 0,
            y: 8
        )
        .disabled(!viewModel.canRecord && !viewModel.isRecording)
        .opacity(viewModel.canRecord || viewModel.isRecording ? 1.0 : 0.5)
    }

    // MARK: - Helper Methods

    private func handleDone() {
        let trimmedText = viewModel.recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
        let isDefaultMessage = viewModel.recognizedText == "Tap start to begin speech recognition!" ||
                              viewModel.recognizedText == "Say something, I'm listening!"

        if !isDefaultMessage && !trimmedText.isEmpty {
            onTextRecognized(viewModel.recognizedText)
        }

        dismiss()
    }
}

// MARK: - Previews

struct SpeechRecognizerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpeechRecognizerView { text in
                print("Recognized: \(text)")
            }
        }
    }
}
