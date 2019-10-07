//
//  SpeedReadViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 9/2/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class SpeedReadViewController: UIViewController {
    
    let sentence = "This is a test sentence to test the speed reading app"
    var words: [String] = []
    var wordLabel = UILabel()
    var playPauseButton = UIButton()
    var resetButton = UIButton()
    var timer = Timer()
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        view.backgroundColor = .darkGray
        
        words = sentence.components(separatedBy: " ")
        
        wordLabel = {
            let label = UILabel(frame: CGRect(x: 0, y: self.view.center.y, width: self.view.frame.width, height: 35))
            label.center = view.center
            label.font = label.font.withSize(30)
            label.numberOfLines = 0
            label.textColor = .white
            label.textAlignment = .center
            return label
        }()
        view.addSubview(wordLabel)
        
        playPauseButton = {
            let button = UIButton(frame: CGRect(x: 0, y: self.view.center.y + 100, width: self.view.frame.width / 3, height: 50))
            button.center.x = self.view.center.x
            button.setTitle("Start", for: .normal)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.textColor = .white
            button.layer.cornerRadius = 20
            button.backgroundColor = .red
            button.addTarget(self, action: #selector(playPause), for: .touchUpInside)
            return button
        }()
        view.addSubview(playPauseButton)
        
        resetButton = {
           let button = UIButton(frame: CGRect(x: 0, y: self.view.center.y + 160, width: self.view.frame.width / 3, height: 50))
            button.center.x = self.view.center.x
            button.setTitle("Reset", for: .normal)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.textColor = .white
            button.layer.cornerRadius = 20
            button.backgroundColor = .red
            button.addTarget(self, action: #selector(reset), for: .touchUpInside)
            return button
        }()
        view.addSubview(resetButton)
    }
    
    @objc func playPause() {
        if playPauseButton.titleLabel?.text == "Play" || playPauseButton.titleLabel?.text == "Start" {
            timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(newWord), userInfo: nil, repeats: true)
            playPauseButton.setTitle("Pause", for: .normal)
        } else {
            timer.invalidate()
            playPauseButton.setTitle("Play", for: .normal)
        }
    }
    
    @objc func reset() {
        counter = 0
    }
    
    @objc func newWord() {
        if counter < words.count {
            
            if words[counter].count > 2 {
                let range = NSRange(location:2,length:1)
                let attributedString = NSMutableAttributedString(string: words[counter], attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica", size: 30)!])
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
                wordLabel.attributedText = attributedString
            } else {
                wordLabel.text = words[counter]
            }
            
            counter += 1
        } else {
            print("Done")
            timer.invalidate()
        }
    }
    
}
