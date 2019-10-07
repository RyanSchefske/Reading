//
//  ReadViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 9/13/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class ReadViewController: UIViewController {
    
    var readingLabel = UILabel()
    var readButton = UIButton()
    var readingText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        view.backgroundColor = .white
        title = "Read"
        
        readingLabel = {
            let label = UILabel(frame: CGRect(x: self.view.frame.width, y: self.view.center.y, width: readingText.width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 24)), height: 30))
            label.text = readingText
            label.textColor = .blue
            label.font = label.font.withSize(24)
            return label
        }()
        view.addSubview(readingLabel)
        
        readButton = {
            let button = UIButton(frame: CGRect(x: 100, y: 100, width: self.view.frame.width / 2, height: 50))
            button.setTitle("Start", for: .normal)
            button.titleLabel?.textColor = .white
            button.backgroundColor = .blue
            button.addTarget(self, action: #selector(read), for: .touchUpInside)
            return button
        }()
        view.addSubview(readButton)
    }
    
    @objc func read() {
        if readButton.titleLabel?.text == "Start" {
            UIView.animate(withDuration: 3, delay: 0, options: .curveLinear, animations: {
                self.readingLabel.center.x -= self.view.frame.width * 2.5
            }, completion: { (complete) in
                if complete {
                    self.readButton.setTitle("Reset", for: .normal)
                }
            })
            readButton.setTitle("Pause", for: .normal)
        } else if readButton.titleLabel?.text == "Pause" {
            pauseText(layer: readingLabel.layer)
            readButton.setTitle("Resume", for: .normal)
        } else if readButton.titleLabel?.text == "Resume" {
            resumeLayer(layer: readingLabel.layer)
            readButton.setTitle("Pause", for: .normal)
        } else if readButton.titleLabel?.text == "Reset" {
            readingLabel.center.x = self.view.frame.width + readingLabel.frame.width / 2
            readButton.setTitle("Start", for: .normal)
        }
    }
    
    @objc func pauseText(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0
        layer.timeOffset = pausedTime
    }
    
    @objc func resumeLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
