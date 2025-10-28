//
//  SpeechSettingsView.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import SwiftUI

struct SpeechSettingsView: View {

    @StateObject private var viewModel = SpeechSettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            voiceSection
            speedSection
        }
        .navigationTitle("Speech Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.readerAccent)
            }
        }
    }

    // MARK: - Sections

    private var voiceSection: some View {
        Section {
            ForEach(viewModel.availableVoices) { voice in
                Button {
                    viewModel.selectVoice(voice.name)
                } label: {
                    HStack {
                        Text(voice.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if voice.name == viewModel.selectedVoice {
                            Image(systemName: "checkmark")
                                .foregroundColor(.readerAccent)
                        }
                    }
                }
            }
        } header: {
            Text("Voice")
        }
    }

    private var speedSection: some View {
        Section {
            ForEach(viewModel.availableSpeeds, id: \.self) { speed in
                Button {
                    viewModel.selectSpeed(speed)
                } label: {
                    HStack {
                        Text(speed)
                            .foregroundColor(.primary)
                        Spacer()
                        if speed == viewModel.selectedSpeed {
                            Image(systemName: "checkmark")
                                .foregroundColor(.readerAccent)
                        }
                    }
                }
            }
        } header: {
            Text("Speed")
        }
    }
}

// MARK: - Previews

struct SpeechSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpeechSettingsView()
        }
    }
}
