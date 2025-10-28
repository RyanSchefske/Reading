//
//  AppError.swift
//  Reader
//
//  Created by Claude Code Assistant on 10/27/24.
//  Copyright © 2024 Ryan Schefske. All rights reserved.
//

import Foundation

/// Application-specific errors with localized descriptions
///
/// This enum provides user-friendly error messages for common failure scenarios
/// throughout the application.
enum AppError: LocalizedError {

    // MARK: - Text Recognition Errors

    case textRecognitionFailed
    case imageProcessingFailed
    case noTextFound
    case invalidImage

    // MARK: - Speech Errors

    case speechRecognitionFailed
    case speechRecognitionNotAvailable
    case microphoneAccessDenied
    case speechSynthesisFailed

    // MARK: - Camera/Photo Errors

    case cameraAccessDenied
    case photoLibraryAccessDenied
    case cameraNotAvailable

    // MARK: - General Errors

    case invalidInput
    case unknown(Error)

    // MARK: - LocalizedError Conformance

    var errorDescription: String? {
        switch self {
        // Text Recognition
        case .textRecognitionFailed:
            return "Unable to recognize text in the image. Please try again with a clearer image."
        case .imageProcessingFailed:
            return "Unable to process the image. Please try again."
        case .noTextFound:
            return "No text was found in the image. Please try a different image."
        case .invalidImage:
            return "The selected image is invalid or corrupted. Please choose another image."

        // Speech
        case .speechRecognitionFailed:
            return "Unable to recognize speech. Please try again."
        case .speechRecognitionNotAvailable:
            return "Speech recognition is not available on this device."
        case .microphoneAccessDenied:
            return "Microphone access is required for speech recognition. Please enable it in Settings."
        case .speechSynthesisFailed:
            return "Unable to start text-to-speech. Please try again."

        // Camera/Photo
        case .cameraAccessDenied:
            return "Camera access is required for scanning. Please enable it in Settings."
        case .photoLibraryAccessDenied:
            return "Photo library access is required. Please enable it in Settings."
        case .cameraNotAvailable:
            return "Camera is not available on this device."

        // General
        case .invalidInput:
            return "Invalid input. Please check your input and try again."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    var failureReason: String? {
        switch self {
        case .textRecognitionFailed, .imageProcessingFailed:
            return "The image may be too blurry, too small, or the text may not be clear enough."
        case .noTextFound:
            return "The Vision framework did not detect any text in the provided image."
        case .speechRecognitionFailed:
            return "The speech could not be recognized. Background noise or unclear speech may be the cause."
        case .microphoneAccessDenied, .cameraAccessDenied, .photoLibraryAccessDenied:
            return "Permission was denied in system settings."
        default:
            return nil
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .textRecognitionFailed, .imageProcessingFailed, .noTextFound:
            return "Try taking a new photo with better lighting and a clear view of the text."
        case .invalidImage:
            return "Select a different image from your photo library or take a new photo."
        case .speechRecognitionFailed:
            return "Move to a quieter location and speak clearly into the microphone."
        case .speechRecognitionNotAvailable:
            return "This feature requires iOS 10 or later."
        case .microphoneAccessDenied:
            return "Go to Settings > Privacy > Microphone and enable access for this app."
        case .cameraAccessDenied:
            return "Go to Settings > Privacy > Camera and enable access for this app."
        case .photoLibraryAccessDenied:
            return "Go to Settings > Privacy > Photos and enable access for this app."
        case .cameraNotAvailable:
            return "Try using the photo library to select an existing image instead."
        default:
            return "Please try again. If the problem persists, restart the app."
        }
    }
}

// MARK: - UIViewController Extension for Error Display

extension UIViewController {

    /// Shows an error alert with proper messaging
    ///
    /// - Parameters:
    ///   - error: The error to display
    ///   - completion: Optional completion handler called when alert is dismissed
    func showError(_ error: Error, completion: (() -> Void)? = nil) {
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let title: String
            let message: String

            if let appError = error as? AppError {
                title = "Error"
                message = appError.errorDescription ?? "An unknown error occurred."
            } else {
                title = "Error"
                message = error.localizedDescription
            }

            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })

            self.present(alert, animated: true)
        }
    }

    /// Shows an error alert with custom title and message
    ///
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert message
    ///   - completion: Optional completion handler called when alert is dismissed
    func showErrorAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })

            self.present(alert, animated: true)
        }
    }
}
