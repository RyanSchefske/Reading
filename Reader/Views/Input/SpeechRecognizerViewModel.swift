//
//  SpeechRecognizerViewModel.swift
//  Reader
//
//  Created by Claude Code on 10/28/25.
//

import AVFoundation
import Foundation
import Speech

@MainActor
final class SpeechRecognizerViewModel: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var recognizedText: String = "Click start to begin speech recognition!"
    @Published var isRecording: Bool = false
    @Published var isAuthorized: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Private Properties

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()

    // MARK: - Computed Properties

    var startStopButtonTitle: String {
        isRecording ? "Stop" : "Start"
    }

    var canRecord: Bool {
        isAuthorized && !isRecording
    }

    // MARK: - Initialization

    override init() {
        super.init()
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        requestAuthorization()
    }

    // MARK: - Public Methods

    func startStopButtonTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func reset() {
        recognizedText = "Click start to begin speech recognition!"
    }

    // MARK: - Private Methods

    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch authStatus {
                case .authorized:
                    self.isAuthorized = true
                case .denied:
                    self.isAuthorized = false
                    self.errorMessage = "Speech recognition access denied"
                    self.showError = true
                case .restricted:
                    self.isAuthorized = false
                    self.errorMessage = "Speech recognition restricted on this device"
                    self.showError = true
                case .notDetermined:
                    self.isAuthorized = false
                @unknown default:
                    self.isAuthorized = false
                }
            }
        }
    }

    private func startRecording() {
        // Cancel any ongoing task
        if let task = recognitionTask {
            task.cancel()
            recognitionTask = nil
        }

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to setup audio session: \(error.localizedDescription)"
            showError = true
            return
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create recognition request"
            showError = true
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode

        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            Task { @MainActor in
                var isFinal = false

                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                }

                if error != nil || isFinal {
                    self.stopRecording()
                }
            }
        }

        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isRecording = true
            recognizedText = "Say something, I'm listening!"
        } catch {
            errorMessage = "Audio engine couldn't start: \(error.localizedDescription)"
            showError = true
        }
    }

    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        isRecording = false
    }
}
