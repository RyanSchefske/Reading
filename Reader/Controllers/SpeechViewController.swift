//
//  SpeechViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 8/28/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class SpeechViewController: UIViewController, AVSpeechSynthesizerDelegate, GADBannerViewDelegate {
    
    var readingText = String()
    var customNav = UIImageView()
    var textView = UITextView()
    var speakButton = UIButton()
    var resetButton = UIButton()
    let synthesizer = AVSpeechSynthesizer()
    var speechIdentifier = String()
    var speechRate = Float()
    var bannerView = GADBannerView()
    
    var strokeTextAttributes = [NSAttributedString.Key : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        synthesizer.delegate = self
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userdefaults = UserDefaults.standard
        if let savedValue = userdefaults.string(forKey: "SpeechVoice"){
            let speechVoices = AVSpeechSynthesisVoice.speechVoices()
            speechVoices.forEach { (voice) in
                if voice.name == savedValue {
                    speechIdentifier = voice.identifier
                }
            }
        } else {
            userdefaults.set("Daniel", forKey: "SpeechVoice")
            speechIdentifier = "com.apple.ttsbundle.Daniel-compact"
        }
        
        if let savedSpeed = userdefaults.string(forKey: "SpeechSpeed") {
            if savedSpeed == "Very Slow" {
                speechRate = 0.2
            } else if savedSpeed == "Slow" {
                speechRate = 0.35
            } else if savedSpeed == "Normal" {
                speechRate = 0.5
            } else if savedSpeed == "Fast" {
                speechRate = 0.65
            } else {
                speechRate = 0.75
            }
        } else {
            userdefaults.set("Normal", forKey: "SpeechSpeed")
            speechRate = 0.5
        }
    }
    
    func setup() {
        view.backgroundColor = Colors().offWhite
        navigationItem.titleView = CustomNavigationBar().customTitle(title: "Speak")
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            strokeTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24)]
            as [NSAttributedString.Key : Any]
        } else {
            strokeTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
            as [NSAttributedString.Key : Any]
        }
        
        let settingsBtn = UIButton(type: .custom)
        settingsBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        settingsBtn.setImage(UIImage(named:"settings")?.withRenderingMode(.alwaysTemplate), for: .normal)
        settingsBtn.addTarget(self, action: #selector(showSettings), for: UIControl.Event.touchUpInside)
        let settingsBarItem = UIBarButtonItem(customView: settingsBtn)
        let currWidth = settingsBarItem.customView?.widthAnchor.constraint(equalToConstant: 25)
        currWidth?.isActive = true
        let currHeight = settingsBarItem.customView?.heightAnchor.constraint(equalToConstant: 25)
        currHeight?.isActive = true
        navigationItem.rightBarButtonItem = settingsBarItem
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-2392719817363402/9276402219"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        customNav = {
            let image = UIImageView(frame: CGRect(x: -2, y: -2, width: view.frame.width + 4, height: view.frame.height / 8))
            image.image = UIImage(named: "customNavBar")?.withRenderingMode(.alwaysTemplate)
            image.tintColor = Colors().buttonColor
            image.translatesAutoresizingMaskIntoConstraints = false
            return image
        }()
        view.addSubview(customNav)

        if UIDevice.current.hasNotch {
            customNav.heightAnchor.constraint(equalToConstant: self.view.frame.height / 7.5).isActive = true
        }
        customNav.topAnchor.constraint(equalTo: view.topAnchor, constant: -4).isActive = true
        customNav.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -4).isActive = true
        customNav.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 4).isActive = true
        
        textView = {
            let textView = UITextView(frame: CGRect(x: 0, y: 100, width: 50, height: 50))
            textView.backgroundColor = .white
            textView.isEditable = false
            textView.center.x = self.view.center.x
            textView.attributedText = NSMutableAttributedString(string: readingText, attributes: strokeTextAttributes)
            textView.text = readingText
            textView.layer.cornerRadius = 5
            textView.translatesAutoresizingMaskIntoConstraints = false
            return textView
        }()
        view.addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: customNav.bottomAnchor, constant: 10).isActive = true
        textView.widthAnchor.constraint(equalToConstant: view.frame.width - 16).isActive = true
        textView.heightAnchor.constraint(equalToConstant: view.frame.height / 2).isActive = true
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        speakButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(speak), for: .touchUpInside)
            button.backgroundColor = Colors().buttonColor
            button.setTitleColor(.white, for: .normal)
            if UIDevice.current.userInterfaceIdiom == .pad {
                button.titleLabel?.font = button.titleLabel?.font.withSize(30)
            }
            button.layer.cornerRadius = 10
            button.clipsToBounds = false
            button.layer.shadowOpacity = 1
            button.layer.shadowOffset = CGSize(width: 0, height: 7)
            button.layer.shadowColor = UIColor.lightGray.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Speak", for: .normal)
            return button
        }()
        view.addSubview(speakButton)
        
        speakButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10).isActive = true
        speakButton.widthAnchor.constraint(equalToConstant: view.frame.width - 16).isActive = true
        speakButton.heightAnchor.constraint(equalToConstant: view.frame.height / 12).isActive = true
        speakButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        speakButton.titleLabel?.textAlignment = .center
        
        resetButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(reset), for: .touchUpInside)
            button.backgroundColor = Colors().buttonColor
            button.setTitleColor(.white, for: .normal)
            if UIDevice.current.userInterfaceIdiom == .pad {
                button.titleLabel?.font = button.titleLabel?.font.withSize(30)
            }
            button.layer.cornerRadius = 10
            button.clipsToBounds = false
            button.layer.shadowOpacity = 1
            button.layer.shadowOffset = CGSize(width: 0, height: 7)
            button.layer.shadowColor = UIColor.lightGray.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Reset", for: .normal)
            return button
        }()
        view.addSubview(resetButton)
        
        resetButton.topAnchor.constraint(equalTo: speakButton.bottomAnchor, constant: 10).isActive = true
        resetButton.widthAnchor.constraint(equalToConstant: view.frame.width - 16).isActive = true
        resetButton.heightAnchor.constraint(equalToConstant: view.frame.height / 12).isActive = true
        resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resetButton.titleLabel?.textAlignment = .center
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableAttributedString = NSMutableAttributedString(string: readingText, attributes: strokeTextAttributes)
        mutableAttributedString.addAttribute(.backgroundColor, value: UIColor.yellow, range: characterRange)
        textView.attributedText = mutableAttributedString
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        textView.attributedText = NSMutableAttributedString(string: readingText, attributes: strokeTextAttributes)
        speakButton.setTitle("Speak", for: .normal)
    }
    
    @objc func speak() {
        if speakButton.titleLabel?.text == "Speak" {
            let utterance = AVSpeechUtterance(string: readingText)
            utterance.voice = AVSpeechSynthesisVoice(identifier: speechIdentifier)
            utterance.rate = speechRate
            synthesizer.speak(utterance)
            speakButton.setTitle("Pause", for: .normal)
        } else if speakButton.titleLabel?.text == "Pause" {
            synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
            speakButton.setTitle("Resume", for: .normal)
        } else if speakButton.titleLabel?.text == "Resume" {
            synthesizer.continueSpeaking()
            speakButton.setTitle("Pause", for: .normal)
        }
    }
    
    @objc func showSettings() {
        navigationController?.pushViewController(SpeechSettingViewController(), animated: true)
    }
    
    @objc func reset() {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speakButton.setTitle("Speak", for: .normal)
        speak()
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        view.addBannerViewToView(bannerView, view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            synthesizer.pauseSpeaking(at: .immediate)
        }
    }
}
