//
//  TextSummaryService.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import Foundation
import FoundationModels

/// Service for generating AI-powered text summaries using Apple's Foundation Models
@available(iOS 26.0, *)
final class TextSummaryService {

    // MARK: - Singleton

    static let shared = TextSummaryService()

    // MARK: - Private Properties

    private var session: LanguageModelSession?

    // MARK: - Initialization

    private init() {
        setupSession()
    }

    // MARK: - Public Methods

    /// Check if summarization is available on this device
    var isAvailable: Bool {
        if #available(iOS 26, *) {
            return SystemLanguageModel.default.availability == .available
        }
        return false
    }

    /// Generate a summary with key points for the given text
    /// - Parameter text: The text to summarize
    /// - Returns: TextSummary containing key points and summary
    /// - Throws: Error if summarization fails
    func generateSummary(for text: String) async throws -> TextSummary {
        guard isAvailable else {
            throw SummaryError.notAvailable
        }

        guard !text.isEmpty else {
            throw SummaryError.emptyText
        }

        // Ensure session is created
        if session == nil {
            setupSession()
        }

        guard let session = session else {
            throw SummaryError.sessionCreationFailed
        }

        // Generate structured summary
        let response = try await session.respond(
            to: "Analyze and summarize the following text:\n\n\(text)",
            generating: TextSummary.self
        )

        return response.content
    }

    // MARK: - Private Methods

    private func setupSession() {
        guard #available(iOS 26, *) else { return }

        session = LanguageModelSession(
            instructions: """
            You are a text analysis assistant. Your role is to:
            1. Extract the most important key points as concise bullet points
            2. Provide a comprehensive yet readable summary
            3. Focus on main ideas and important details
            4. Use clear, accessible language
            """
        )
    }

    // MARK: - Error Types

    enum SummaryError: LocalizedError {
        case notAvailable
        case emptyText
        case sessionCreationFailed

        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Apple Intelligence is not available on this device. Requires iOS 26+ and Apple Intelligence-compatible hardware."
            case .emptyText:
                return "Cannot summarize empty text."
            case .sessionCreationFailed:
                return "Failed to create summarization session."
            }
        }
    }
}
