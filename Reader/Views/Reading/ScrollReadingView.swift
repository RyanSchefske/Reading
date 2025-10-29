//
//  ScrollReadingView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

struct ScrollReadingView: View {

    @StateObject private var viewModel: ScrollReadingViewModel

    init(readingText: String) {
        _viewModel = StateObject(
            wrappedValue: ScrollReadingViewModel(readingText: readingText)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            speedControlSection
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

            textScrollSection

            controlsSection
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

            AdBannerView()
                .frame(height: 50)
                .accessibilityHidden(true)
        }
        .background(Color.readerBackground.ignoresSafeArea())
        .navigationTitle("Scroll")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    // MARK: - Subviews

    private var speedControlSection: some View {
        VStack(spacing: 12) {
            Text(viewModel.scrollSpeedText)
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary)

            Slider(
                value: Binding(
                    get: { viewModel.scrollSpeed },
                    set: { viewModel.sliderChanged($0) }
                ),
                in: viewModel.minSpeed...viewModel.maxSpeed,
                step: viewModel.speedStep
            )
            .tint(.readerAccent)
            .disabled(!viewModel.isSliderEnabled)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 12)
        )
    }

    private var textScrollSection: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Top spacer for initial position
                        Color.clear
                            .frame(height: geometry.size.height / 2)
                            .id("top")

                        Text(viewModel.readingText)
                            .font(.body)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Bottom spacer
                        Color.clear
                            .frame(height: geometry.size.height / 2)
                            .id("bottom")
                    }
                }
                .onChange(of: viewModel.scrollOffset) { offset in
                    withAnimation(.linear(duration: 0.016)) { // 60 FPS
                        scrollProxy.scrollTo("top", anchor: .top)
                    }
                }
                .onAppear {
                    scrollProxy.scrollTo("top", anchor: .top)
                }
            }
        }
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
                Image(systemName: viewModel.playPauseImageName)
                    .font(.title2)
                Text(viewModel.playbackState == .playing ? "Pause" : "Play")
                    .font(.headline)
            }
            .foregroundColor(.white)
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
                    .foregroundStyle(Color.readerAccent)
            }
            .foregroundColor(.readerAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
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

struct ScrollReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScrollReadingView(
                readingText: """
                The quick brown fox jumps over the lazy dog. This is a sample text for demonstrating the scroll reading functionality of the app.

                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

                Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

                Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
                """
            )
        }
    }
}
