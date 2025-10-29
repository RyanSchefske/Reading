//
//  SpeechReadingView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

struct SpeechReadingView: View {

    @StateObject private var viewModel: SpeechReadingViewModel

    init(readingText: String) {
        _viewModel = StateObject(
            wrappedValue: SpeechReadingViewModel(readingText: readingText)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                textDisplaySection
                controlsSection
                AdBannerView()
                    .frame(height: 50)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color.readerBackground.ignoresSafeArea())
        .navigationTitle("Speak")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.readerAccent)
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .sheet(isPresented: $viewModel.showSettings) {
            NavigationStack {
                SpeechSettingsView()
            }
        }
    }

    // MARK: - Subviews

    private var textDisplaySection: some View {
        ScrollView {
            Text(viewModel.attributedText)
                .font(.body)
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

    private var controlsSection: some View {
        VStack(spacing: 16) {
            playPauseButton
            resetButton
        }
    }

    private var playPauseButton: some View {
        Button {
            viewModel.playPause()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: playPauseImageName)
                    .font(.title2)
                Text(playPauseTitle)
                    .font(.headline)
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .background(Color.readerAccent)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(
            color: Color.black.opacity(0.18),
            radius: 10,
            x: 0,
            y: 8
        )
    }

    private var resetButton: some View {
        Button {
            viewModel.reset()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
                Text("Reset")
                    .font(.headline)
            }
            .foregroundColor(.readerAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.readerAccent, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 10,
            x: 0,
            y: 8
        )
    }

    // MARK: - Computed Properties

    private var playPauseImageName: String {
        switch viewModel.playbackState {
        case .stopped:
            return "play.fill"
        case .playing:
            return "pause.fill"
        case .paused:
            return "play.fill"
        }
    }

    private var playPauseTitle: String {
        switch viewModel.playbackState {
        case .stopped:
            return "Start"
        case .playing:
            return "Pause"
        case .paused:
            return "Resume"
        }
    }
}

// MARK: - Previews

struct SpeechReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpeechReadingView(
                readingText: "The quick brown fox jumps over the lazy dog. This is a sample text for demonstrating the speech reading functionality of the app."
            )
        }
    }
}
