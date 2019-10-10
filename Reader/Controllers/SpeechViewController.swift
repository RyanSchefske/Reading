//
//  SpeechViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 8/28/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import AVFoundation

class SpeechViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    }
    
    func setup() {
        view.backgroundColor = .white
        
        let speakButton: UIButton = {
            let button = UIButton(frame: CGRect(x: 110, y: 110, width: 100, height: 100))
            button.addTarget(self, action: #selector(speak), for: .touchUpInside)
            button.titleLabel?.text = "Speak"
            button.backgroundColor = .blue
            button.titleLabel?.textColor = .white
            return button
        }()
        
        view.addSubview(speakButton)
    }
    
    @objc func speak() {
        let utterance = AVSpeechUtterance(string: "Hello World, this is a test of the speech synthesizer in this reading app")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        //"en-US" - American, "en-IE" - Irish, "en-AU" - Australian, "en-GB" - British
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
}
