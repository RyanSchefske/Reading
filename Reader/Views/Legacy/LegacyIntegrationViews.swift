//
//  LegacyIntegrationViews.swift
//  Reader
//
//  Created by GPT Coding Assistant on 11/3/25.
//
//  Legacy UIKit wrappers for features that still require UIKit integration.
//  All reading modes have been migrated to native SwiftUI.
//

import SwiftUI
import UIKit

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
