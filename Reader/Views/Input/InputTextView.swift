//
//  InputTextView.swift
//  Reader
//
//  Created by GPT Coding Assistant on 11/3/25.
//

import SwiftUI

struct InputTextView: View {

    @StateObject private var viewModel = InputTextViewModel()
    @FocusState private var isTextEditorFocused: Bool

    @State private var isShowingImagePicker = false
    @State private var isShowingScan = false
    @State private var isShowingSpeechRecognizer = false
    @State private var isShowingHistory = false
    @State private var readingTextForNavigation: String?
    @State private var showValidationMessage = false
    @State private var showClearConfirmation = false
    @State private var showOnboarding = false

    private let hasSeenOnboardingKey = "hasSeenOnboarding"

    private var navigationBinding: Binding<Bool> {
        Binding(
            get: { readingTextForNavigation != nil },
            set: { isActive in
                if !isActive {
                    readingTextForNavigation = nil
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                textEditorSection
                actionButtons
                nextButton
                Spacer(minLength: 8)
                AdBannerView()
                    .frame(height: 50)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color.readerBackground.ignoresSafeArea())
        .navigationTitle("Scholarly")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTextEditorFocused = false
                }
            }
        }
        .overlay(alignment: .top) {
            if showValidationMessage {
                validationBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .alert(
            viewModel.activeError ?? "Error",
            isPresented: $viewModel.isShowingError,
            actions: {
                Button("OK", role: .cancel) {
                    viewModel.resetError()
                }
            },
            message: {
                if let message = viewModel.activeError {
                    Text(message)
                }
            }
        )
        .alert(
            "Clear All Text?",
            isPresented: $showClearConfirmation,
            actions: {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    HapticManager.shared.success()
                    viewModel.text = ""
                    isTextEditorFocused = false
                }
            },
            message: {
                Text("This will delete all text in the editor.")
            }
        )
        .sheet(isPresented: $isShowingImagePicker) {
            LegacyImagePicker(
                sourceType: .photoLibrary,
                onImagePicked: { image in
                    viewModel.processPickedImage(image)
                },
                onCancel: {}
            )
        }
        .sheet(isPresented: $isShowingScan) {
            LegacyScanView { image in
                viewModel.processPickedImage(image)
            }
        }
        .sheet(isPresented: $isShowingSpeechRecognizer) {
            NavigationStack {
                SpeechRecognizerView { text in
                    viewModel.applyRecognizedText(text)
                }
            }
        }
        .sheet(isPresented: $isShowingHistory) {
            ReadingHistoryView { selectedText in
                viewModel.text = selectedText
            }
        }
        .background(
            NavigationLink(
                destination: ReadingChoicesView(
                    readingText: readingTextForNavigation ?? ""
                ),
                isActive: navigationBinding
            ) { EmptyView() }
                .hidden()
        )
        .animation(.easeInOut, value: showValidationMessage)
        .overlay {
            if showOnboarding {
                onboardingOverlay
            }
        }
        .onAppear {
            checkFirstLaunch()
        }
    }

    // MARK: - Subviews

    private var textEditorSection: some View {
        ZStack(alignment: .topLeading) {
            editorView

            if viewModel.text.isEmpty {
                Text(viewModel.placeholderText)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
            }

            if viewModel.isRecognizingText {
                VStack {
                    ProgressView("Recognizing text…")
                        .progressViewStyle(CircularProgressViewStyle(tint: .readerAccent))
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Clear button - top right
            if !viewModel.text.isEmpty {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            HapticManager.shared.light()
                            showClearConfirmation = true
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary, Color(uiColor: .tertiarySystemBackground))
                                .symbolRenderingMode(.palette)
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            }
        }
        .frame(minHeight: 260, maxHeight: 450, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 12)
        )
    }

    @ViewBuilder
    private var editorView: some View {
        if #available(iOS 16.0, *) {
            TextEditor(text: $viewModel.text)
                .scrollContentBackground(.hidden)
                .focused($isTextEditorFocused)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
        } else {
            TextEditor(text: $viewModel.text)
                .focused($isTextEditorFocused)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            ReaderActionButton(title: "Scan", systemImage: "doc.viewfinder") {
                HapticManager.shared.medium()
                isShowingScan = true
            }

            ReaderActionButton(title: "Upload", systemImage: "photo.on.rectangle") {
                HapticManager.shared.medium()
                isShowingImagePicker = true
            }

            ReaderActionButton(title: "Speak", systemImage: "waveform") {
                HapticManager.shared.medium()
                isShowingSpeechRecognizer = true
            }
        }
    }

    private var nextButton: some View {
        Button {
            if let readingText = viewModel.prepareReadingText() {
                HapticManager.shared.light()
                readingTextForNavigation = readingText
            } else {
                HapticManager.shared.warning()
                showValidationBanner()
            }
        } label: {
            Text("Next")
                .font(.headline)
        }
        .buttonStyle(ReaderSecondaryButtonStyle())
    }

    private var validationBanner: some View {
        Text("Add some text before continuing.")
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color.red.opacity(0.9), in: Capsule())
            .padding(.top, 16)
    }

    private var onboardingOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissOnboarding()
                }

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Welcome to Scholarly!")
                        .font(.title.bold())

                    Text("Add any text and choose how you want to read it:")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                VStack(spacing: 20) {
                    OnboardingModeRow(
                        icon: "gauge.with.dots.needle.50percent",
                        title: "Speed Reading",
                        description: "Read faster with RSVP technique"
                    )

                    OnboardingModeRow(
                        icon: "speaker.wave.2",
                        title: "Text-to-Speech",
                        description: "Listen while text highlights"
                    )

                    OnboardingModeRow(
                        icon: "scroll",
                        title: "Scroll Reading",
                        description: "Auto-scroll at your own pace"
                    )
                }
                .padding(.horizontal, 24)

                Button {
                    dismissOnboarding()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.readerAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }
            .padding(.vertical, 40)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            )
            .padding(.horizontal, 24)
            .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 10)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Helpers

    private func checkFirstLaunch() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
        if !hasSeenOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showOnboarding = true
                }
            }
        }
    }

    private func dismissOnboarding() {
        HapticManager.shared.success()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showOnboarding = false
        }
        UserDefaults.standard.set(true, forKey: hasSeenOnboardingKey)
    }

    private func showValidationBanner() {
        showValidationMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showValidationMessage = false
        }
    }
}

// MARK: - Button Styles

private struct ReaderActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundColor(.white)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .buttonStyle(ReaderPrimaryButtonStyle())
    }
}

private struct ReaderPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.readerAccent)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.08 : 0.18),
                radius: 10,
                x: 0,
                y: 8
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct ReaderSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .foregroundColor(.readerAccent)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.readerAccent, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.05 : 0.18),
                radius: 10,
                x: 0,
                y: 8
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Onboarding Components

private struct OnboardingModeRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.readerAccent)
                .frame(width: 44, height: 44)
                .background(Color.readerAccent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct InputTextView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InputTextView()
        }
    }
}
