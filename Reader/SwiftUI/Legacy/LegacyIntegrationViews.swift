//
//  LegacyIntegrationViews.swift
//  Reader
//
//  Created by GPT Coding Assistant on 11/3/25.
//

import SwiftUI
import UIKit

// MARK: - Speech Recognizer

struct LegacySpeechRecognizerView: UIViewControllerRepresentable {

    let onFinish: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish, onDismiss: { dismiss() })
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = SpeechRecognizerViewController()
        controller.delegate = context.coordinator
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }

    final class Coordinator: NSObject, SpeechRecognizerViewControllerDelegate {
        private let onFinish: (String) -> Void
        private let onDismiss: () -> Void

        init(onFinish: @escaping (String) -> Void, onDismiss: @escaping () -> Void) {
            self.onFinish = onFinish
            self.onDismiss = onDismiss
        }

        func speechRecognizerViewController(_ controller: SpeechRecognizerViewController, didFinishWith text: String) {
            onFinish(text)
            onDismiss()
        }
    }
}

// MARK: - Reading Modes

struct LegacySpeechView: UIViewControllerRepresentable {
    let readingText: String

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = SpeechViewController()
        controller.readingText = readingText
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        guard
            let controller = uiViewController.viewControllers.first as? SpeechViewController,
            controller.readingText != readingText
        else { return }

        controller.readingText = readingText
    }
}

struct LegacySpeedReadView: UIViewControllerRepresentable {
    let readingText: String

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = SpeedReadViewController()
        controller.readingText = readingText
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        guard
            let controller = uiViewController.viewControllers.first as? SpeedReadViewController,
            controller.readingText != readingText
        else { return }

        controller.readingText = readingText
    }
}

struct LegacyScrollReadView: UIViewControllerRepresentable {
    let readingText: String

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = ReadViewController()
        controller.readingText = readingText
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        guard
            let controller = uiViewController.viewControllers.first as? ReadViewController,
            controller.readingText != readingText
        else { return }

        controller.readingText = readingText
    }
}

// MARK: - Scan

struct LegacyScanView: UIViewControllerRepresentable {

    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured, onDismiss: { dismiss() })
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = ScanViewController()
        controller.delegate = context.coordinator
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }

    final class Coordinator: NSObject, ScanViewControllerDelegate {
        private let onImageCaptured: (UIImage) -> Void
        private let onDismiss: () -> Void

        init(onImageCaptured: @escaping (UIImage) -> Void, onDismiss: @escaping () -> Void) {
            self.onImageCaptured = onImageCaptured
            self.onDismiss = onDismiss
        }

        func scanViewController(_ controller: ScanViewController, didCapture image: UIImage) {
            onImageCaptured(image)
            onDismiss()
        }
    }
}

// MARK: - Image Picker

struct LegacyImagePicker: UIViewControllerRepresentable {

    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onImagePicked: onImagePicked,
            onCancel: onCancel,
            onDismiss: { dismiss() }
        )
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let onImagePicked: (UIImage) -> Void
        private let onCancel: () -> Void
        private let onDismiss: () -> Void

        init(onImagePicked: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void, onDismiss: @escaping () -> Void) {
            self.onImagePicked = onImagePicked
            self.onCancel = onCancel
            self.onDismiss = onDismiss
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onDismiss()
            onCancel()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            defer { onDismiss() }

            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            } else {
                onCancel()
            }
        }
    }
}

// MARK: - Ad Banner

struct AdBannerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BannerHostingController {
        BannerHostingController()
    }

    func updateUIViewController(_ uiViewController: BannerHostingController, context: Context) { }
}

final class BannerHostingController: UIViewController {

    private var hasAddedBanner = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !hasAddedBanner else { return }
        hasAddedBanner = true
        AdManager.shared.addBannerToView(view, viewController: self)
    }
}
