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
    @State private var readingTextForNavigation: String?
    @State private var showValidationMessage = false

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
            LegacySpeechRecognizerView { text in
                viewModel.applyRecognizedText(text)
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
    }

    // MARK: - Subviews

    private var textEditorSection: some View {
        ZStack(alignment: .topLeading) {
            editorView

            if viewModel.text.isEmpty {
                Text(viewModel.placeholderText)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 22)
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
        }
        .frame(minHeight: 260, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
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
                isShowingScan = true
            }

            ReaderActionButton(title: "Upload", systemImage: "photo.on.rectangle") {
                isShowingImagePicker = true
            }

            ReaderActionButton(title: "Speak", systemImage: "waveform") {
                isShowingSpeechRecognizer = true
            }
        }
    }

    private var nextButton: some View {
        Button {
            if let readingText = viewModel.prepareReadingText() {
                readingTextForNavigation = readingText
            } else {
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
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color.red.opacity(0.9), in: Capsule())
            .padding(.top, 16)
    }

    // MARK: - Helpers

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
            HStack(spacing: 16) {
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
            .background(Color.white)
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

struct InputTextView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InputTextView()
        }
    }
}
