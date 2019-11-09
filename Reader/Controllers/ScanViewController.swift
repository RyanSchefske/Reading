//
//  ScanViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 8/29/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import WeScan

class ScanViewController: UIViewController, ImageScannerControllerDelegate {
    
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
        scanner.dismiss(animated: true) {
            
            if results.doesUserPreferEnhancedImage {
                if let imageResults = results.enhancedImage {
                    if let vc = self.navigationController?.viewControllers[0] as? InputTextController {
                        vc.image = imageResults
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            } else {
                if let vc = self.navigationController?.viewControllers[0] as? InputTextController {
                    vc.image = results.scannedImage
                    self.navigationController?.popToRootViewController(animated: true)
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
