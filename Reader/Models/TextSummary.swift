//
//  TextSummary.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import Foundation
import FoundationModels

/// Structured summary output from the Foundation Models framework
@available(iOS 26.0, *)
@Generable
struct TextSummary {

    /// Key points extracted from the text (3-5 bullet points)
    @Guide(description: "Extract 3-5 key points from the text as concise bullet points")
    var keyPoints: [String]

    /// Comprehensive summary of the text
    @Guide(description: "Provide a comprehensive summary that captures the main ideas and important details")
    var summary: String
}
