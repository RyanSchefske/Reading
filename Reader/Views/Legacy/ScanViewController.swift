//
//  ScanViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 8/29/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import VisionKit

protocol ScanViewControllerDelegate: AnyObject {
    func scanViewController(_ controller: ScanViewController, didCapture image: UIImage)
    func scanViewController(_ controller: ScanViewController, didCaptureMultiple images: [UIImage])
}

// Make multi-page method optional for backward compatibility
extension ScanViewControllerDelegate {
    func scanViewController(_ controller: ScanViewController, didCaptureMultiple images: [UIImage]) {
        // Default implementation: call single image delegate with first image
        if let firstImage = images.first {
            scanViewController(controller, didCapture: firstImage)
        }
    }
}

@available(iOS 13.0, *)
class ScanViewController: UIViewController, VNDocumentCameraViewControllerDelegate {

    weak var delegate: ScanViewControllerDelegate?
    private var hasPresented = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Present scanner only once when view appears
        guard !hasPresented else { return }
        hasPresented = true

        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }

    // MARK: - VNDocumentCameraViewControllerDelegate

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            // Collect all scanned pages
            var scannedImages: [UIImage] = []
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                scannedImages.append(image)
            }

            guard !scannedImages.isEmpty else { return }

            if let delegate = self.delegate {
                DispatchQueue.main.async {
                    // Call multi-page delegate method
                    delegate.scanViewController(self, didCaptureMultiple: scannedImages)
                }
            }
        }
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("Document scan error: \(error.localizedDescription)")
        controller.dismiss(animated: true)

        // Optionally show error to user
        let alert = UIAlertController(title: "Scan Error",
                                     message: error.localizedDescription,
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
