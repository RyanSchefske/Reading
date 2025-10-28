//
//  SpeechRecognizer.swift
//  Reader
//
//  Created by Ryan Schefske on 10/9/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import GoogleMobileAds
import Speech
import UIKit

protocol SpeechRecognizerViewControllerDelegate: AnyObject {
    func speechRecognizerViewController(_ controller: SpeechRecognizerViewController, didFinishWith text: String)
}

class SpeechRecognizerViewController: UIViewController {

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var customNav = UIImageView()
    
    weak var delegate: SpeechRecognizerViewControllerDelegate?
    
    let startStopButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(startStopPushed), for: .touchUpInside)
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
        button.setTitle("Start", for: .normal)
        return button
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(donePushed), for: .touchUpInside)
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
        button.setTitle("Done", for: .normal)
        return button
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Click start to begin speech recognition!"
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 5
        textView.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            textView.font = UIFont(name: "Helvetica", size: 24)
        } else {
            textView.font = UIFont(name: "Helvetica", size: 14)
        }
        textView.clipsToBounds = false
        textView.layer.shadowOpacity = 0.6
        textView.layer.shadowOffset = CGSize(width: 0, height: 7)
        textView.layer.shadowColor = UIColor.lightGray.cgColor
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        navigationItem.titleView = CustomNavigationBar().customTitle(title: "Speech Recognizer")
        view.backgroundColor = Colors().offWhite
        
        view.addSubview(textView)
        view.addSubview(startStopButton)
        view.addSubview(doneButton)
        
        customNavBar()
        
        textView.topAnchor.constraint(equalTo: customNav.bottomAnchor, constant: 10).isActive = true
        textView.widthAnchor.constraint(equalToConstant: view.frame.width - 20).isActive = true
        textView.heightAnchor.constraint(equalToConstant: view.frame.height / 2).isActive = true
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        startStopButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10).isActive = true
        startStopButton.widthAnchor.constraint(equalTo: textView.widthAnchor).isActive = true
        startStopButton.heightAnchor.constraint(equalToConstant: view.frame.height / 12).isActive = true
        startStopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startStopButton.titleLabel?.textAlignment = .center
        
        doneButton.topAnchor.constraint(equalTo: startStopButton.bottomAnchor, constant: 10).isActive = true
        doneButton.widthAnchor.constraint(equalTo: textView.widthAnchor).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: view.frame.height / 12).isActive = true
        doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doneButton.titleLabel?.textAlignment = .center

        // Add banner ad using AdManager
        AdManager.shared.addBannerToView(view, viewController: self)
    }
    
    private func customNavBar() {
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
    }
    
    func recognizeSpeech() {
        startStopButton.isEnabled = false
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = true
            
            switch authStatus {
                case .authorized:
                    isButtonEnabled = true
                    
                case .denied:
                    isButtonEnabled = false
                    
                case .restricted:
                    isButtonEnabled = false
                
                case .notDetermined:
                    isButtonEnabled = false
            }
            
            DispatchQueue.main.async {
                self.startStopButton.isEnabled = isButtonEnabled
            }
        }
    }

    @objc func startStopPushed() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            startStopButton.isEnabled = false
            startStopButton.setTitle("Start", for: .normal)
        } else {
            startRecording()
            startStopButton.setTitle("Stop", for: .normal)
        }
    }
    
    @objc func donePushed() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            startStopButton.isEnabled = false
            startStopButton.setTitle("Start", for: .normal)
        }
        
        let capturedText = textView.text ?? ""
        let trimmed = capturedText.trimmingCharacters(in: .whitespacesAndNewlines)
        let isDefaultMessage = capturedText == "Click start to begin speech recognition!" || capturedText == "Say something, I'm listening!"

        if !isDefaultMessage && !trimmed.isEmpty {
            if let delegate = delegate {
                delegate.speechRecognizerViewController(self, didFinishWith: capturedText)
            } else if let inputController = navigationController?.viewControllers.first as? InputTextController {
                inputController.contentString = inputController.contentString + " " + capturedText
            }
        }

        if let navigationController = navigationController {
            if navigationController.presentingViewController != nil && navigationController.viewControllers.count == 1 {
                navigationController.dismiss(animated: true)
            } else {
                navigationController.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    func startRecording() {
        if let task = recognitionTask {
            task.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in

            var isFinal = false

            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.startStopButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = "Say something, I'm listening!"
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startStopButton.isEnabled = true
        } else {
            startStopButton.isEnabled = false
        }
    }
}
