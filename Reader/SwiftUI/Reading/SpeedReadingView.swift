//
//  SpeedReadingView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

struct SpeedReadingView: View {

    @StateObject private var viewModel: SpeedReadingViewModel

    init(readingText: String) {
        _viewModel = StateObject(
            wrappedValue: SpeedReadingViewModel(readingText: readingText)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                speedControlSection
                wordDisplaySection
                controlsSection
                AdBannerView()
                    .frame(height: 50)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color.readerBackground.ignoresSafeArea())
        .navigationTitle("Speed Read")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    // MARK: - Subviews

    private var speedControlSection: some View {
        VStack(spacing: 12) {
            Text("\(Int(viewModel.wordsPerMinute)) WPM")
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary)

            Slider(
                value: Binding(
                    get: { viewModel.wordsPerMinute },
                    set: { viewModel.sliderChanged($0) }
                ),
                in: viewModel.minWPM...viewModel.maxWPM,
                step: viewModel.wpmStep
            )
            .tint(.readerAccent)
            .disabled(!viewModel.isSliderEnabled)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 12)
        )
    }

    private var wordDisplaySection: some View {
        Text(viewModel.displayedWord)
            .font(.system(size: 30))
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 12)
            )
    }

    private var controlsSection: some View {
        VStack(spacing: 16) {
            playbackControls
            resetButton
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.skipBackward()
            } label: {
                Image(systemName: "gobackward.10")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
            }
            .background(Color.readerAccent)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 8)

            Button {
                viewModel.playPause()
            } label: {
                Image(systemName: viewModel.playPauseImageName)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
            }
            .background(Color.readerAccent)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 8)

            Button {
                viewModel.skipForward()
            } label: {
                Image(systemName: "goforward.10")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
            }
            .background(Color.readerAccent)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 8)
        }
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
        .background(Color.white)
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
}

// MARK: - Previews

struct SpeedReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpeedReadingView(
                readingText: "The quick brown fox jumps over the lazy dog. This is a sample text for demonstrating the speed reading functionality of the app."
            )
        }
    }
}
