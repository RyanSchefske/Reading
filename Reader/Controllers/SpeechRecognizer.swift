//
//  SpeechRecognizer.swift
//  Reader
//
//  Created by Ryan Schefske on 10/9/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import Speech

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {
    
    let blackView = UIView()
    
    let startStopButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.backgroundColor = Colors().buttonColor
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override init() {
        super.init()

    }
    
    func showSpeechRecognizer() {
        if let window = (UIApplication.shared.windows.first { $0.isKeyWindow }) {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDismiss)))
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            startStopButton.addTarget(self, action: #selector(startStopPushed), for: .touchUpInside)
            startStopButton.alpha = 0
            
            window.addSubview(blackView)
            blackView.addSubview(startStopButton)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.startStopButton.alpha = 1
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.startStopButton.alpha = 0
        }
    }
    
    @objc func startStopPushed() {
        print("Start")
    }
}
