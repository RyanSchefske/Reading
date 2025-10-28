//
//  ScanViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 8/29/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import WeScan

protocol ScanViewControllerDelegate: AnyObject {
    func scanViewController(_ controller: ScanViewController, didCapture image: UIImage)
}

class ScanViewController: UIViewController, ImageScannerControllerDelegate {
    
    weak var delegate: ScanViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        view.backgroundColor = .white
        title = "Scan"
        
        let scannerViewController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        present(scannerViewController, animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        scanner.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            let chosenImage: UIImage?

            if results.doesUserPreferEnhancedImage {
                chosenImage = results.enhancedImage
            } else {
                chosenImage = results.scannedImage
            }

            guard let image = chosenImage else { return }

            if let delegate = self.delegate {
                DispatchQueue.main.async {
                    delegate.scanViewController(self, didCapture: image)
                }
            }
        }
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print("Error")
    }
    
}
