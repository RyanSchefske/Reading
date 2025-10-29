//
//  SummaryView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

@available(iOS 26.0, *)
struct SummaryView: View {

    // MARK: - Properties

    let text: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SummaryViewModel

    // MARK: - Initialization

    init(text: String) {
        self.text = text
        self._viewModel = StateObject(wrappedValue: SummaryViewModel(text: text))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.readerBackground.ignoresSafeArea()

                contentView
            }
            .navigationTitle("AI Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.light()
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .task {
            await viewModel.generateSummary()
        }
    }

    // MARK: - Content Views

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .success(let summary):
            summaryContent(summary)
        case .error(let error):
            errorView(error)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Generating AI Summary...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func summaryContent(_ summary: TextSummary) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Key Points Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.readerAccent)
                        Text("Key Points")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(summary.keyPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(.title3)
                                    .foregroundColor(.readerAccent)
                                Text(point)
                                    .font(.body)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)

                // Summary Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.readerAccent)
                        Text("Summary")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Text(summary.summary)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
            .padding()
        }
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Unable to Generate Summary")
                .font(.title3)
                .fontWeight(.semibold)

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                HapticManager.shared.light()
                Task {
                    await viewModel.generateSummary()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.readerAccent)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

// MARK: - View Model

@available(iOS 26.0, *)
@MainActor
final class SummaryViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var state: ViewState = .loading

    // MARK: - Private Properties

    private let text: String
    private let summaryService = TextSummaryService.shared

    // MARK: - View State

    enum ViewState {
        case loading
        case success(TextSummary)
        case error(Error)
    }

    // MARK: - Initialization

    init(text: String) {
        self.text = text
    }

    // MARK: - Public Methods

    func generateSummary() async {
        state = .loading

        do {
            let summary = try await summaryService.generateSummary(for: text)
            state = .success(summary)
            HapticManager.shared.success()
        } catch {
            state = .error(error)
            HapticManager.shared.error()
        }
    }
}
