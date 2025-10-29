//
//  InputTextViewModel.swift
//  Reader
//
//  Created by GPT Coding Assistant on 11/3/25.
//

import Foundation
import SwiftUI
import UIKit
import Vision

@MainActor
final class InputTextViewModel: ObservableObject {

    // MARK: - Published State

    @Published var text: String = ""
    @Published var isRecognizingText: Bool = false
    @Published var activeError: String?
    @Published var isShowingError: Bool = false

    // MARK: - Constants

    let placeholderText = "Add text to read with speed reading, text-to-speech, or scrolling modes"

    // MARK: - Derived State

    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasUserContent: Bool {
        !trimmedText.isEmpty
    }

    // MARK: - Text Recognition

    func processPickedImage(_ image: UIImage) {
        isRecognizingText = true

        Task {
            do {
                let recognized = try await recognizeText(in: image)
                applyRecognizedText(recognized)
                HapticManager.shared.success()
            } catch {
                HapticManager.shared.error()
                present(error: error)
            }

            isRecognizingText = false
        }
    }

    // MARK: - Helpers

    func applyRecognizedText(_ recognizedText: String) {
        let cleaned = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else {
            present(error: AppError.noTextFound)
            return
        }

        if hasUserContent {
            text.append("\n\(cleaned)")
        } else {
            text = cleaned
        }
    }

    func prepareReadingText() -> String? {
        hasUserContent ? trimmedText : nil
    }

    func resetError() {
        activeError = nil
        isShowingError = false
    }

    private func recognizeText(in image: UIImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(throwing: AppError.invalidImage)
                return
            }

            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard
                    let observations = request.results as? [VNRecognizedTextObservation],
                    !observations.isEmpty
                else {
                    continuation.resume(throwing: AppError.noTextFound)
                    return
                }

                let recognized = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                if recognized.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continuation.resume(throwing: AppError.noTextFound)
                } else {
                    continuation.resume(returning: recognized)
                }
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func present(error: Error) {
        if let appError = error as? AppError {
            activeError = appError.errorDescription ?? "An unknown error occurred."
        } else {
            activeError = error.localizedDescription
        }
        isShowingError = true
    }
}
