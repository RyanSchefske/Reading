//
//  PhotoViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 9/3/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import FirebaseMLVision
import AVFoundation

class InputTextController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var image: UIImage? = nil
    var textLabel = UITextView()
    var stackView = UIStackView()
    var scanButton = CustomButton()
    var photoButton = CustomButton()
    var speakButton = CustomButton()
    var nextButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors().offWhite
        
        setup()
        
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseOut, animations: {
            self.textLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
            self.textLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width - 16).isActive = true
            self.textLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height / 2.5).isActive = true
            self.textLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            
            self.stackView.topAnchor.constraint(equalTo: self.textLabel.bottomAnchor, constant: 10).isActive = true
            self.nextButton.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 15).isActive = true
            
            self.view.layoutIfNeeded()
        }) { (completed) in
            // Do Nothing
        }
        
        textLabel.selectedTextRange = textLabel.textRange(from: textLabel.beginningOfDocument, to: textLabel.beginningOfDocument)
        
        recognizeText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func setup() {
        title = "Reader"
        
        textLabel = {
            let textView = UITextView(frame: CGRect(x: 0, y: 100, width: 50, height: 50))
            textView.center.x = self.view.center.x
            textView.text = "Type, paste, or select a button below to begin!"
            textView.font = UIFont(name: "Helvetica", size: 14)
            textView.textColor = .lightGray
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.borderWidth = 1
            textView.backgroundColor = .white
            textView.layer.cornerRadius = 5
            textView.translatesAutoresizingMaskIntoConstraints = false
            
            textView.clipsToBounds = false
            textView.layer.shadowOpacity = 0.6
            textView.layer.shadowOffset = CGSize(width: 0, height: 7)
            textView.layer.shadowColor = UIColor.lightGray.cgColor
            
            textView.delegate = self
            
            return textView
        }()
        view.addSubview(textLabel)
        
        speakButton = {
            let button = CustomButton()
            button.addTarget(self, action: #selector(speak), for: .touchUpInside)
            button.setTitle("Speak", for: .normal)
            button.setImage(UIImage(named: "speak"), for: .normal)
            return button
        }()
        
        scanButton = {
            let button = CustomButton()
            button.addTarget(self, action: #selector(scan), for: .touchUpInside)
            button.setTitle("Scan", for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: -20)
            button.setImage(UIImage(named: "scan"), for: .normal)
            return button
        }()
        
        photoButton = {
            let button = CustomButton()
            button.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
            button.setTitle("Upload", for: .normal)
            button.setImage(UIImage(named: "upload"), for: .normal)
            return button
        }()
        
        stackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.distribution = .fillEqually
            stack.alignment = .center
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(scanButton)
            stack.addArrangedSubview(photoButton)
            stack.addArrangedSubview(speakButton)
            return stack
        }()
        view.addSubview(stackView)
        
        nextButton = {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width / 4, height: photoButton.frame.height))
            button.setTitle("Next", for: .normal)
            button.layer.borderColor = Colors().buttonColor.cgColor
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 2
            button.backgroundColor = .white
            button.setTitleColor(Colors().buttonColor, for: .normal)
            button.titleLabel?.textAlignment = .center
            button.clipsToBounds = false
            button.layer.shadowOpacity = 1
            button.layer.shadowOffset = CGSize(width: 0, height: 5)
            button.layer.shadowColor = UIColor.lightGray.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(nextClicked), for: .touchUpInside)
            return button
        }()
        view.addSubview(nextButton)
        
        //Text View Layout
        textLabel.center = CGPoint(x: self.view.center.x, y: 100)
        textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: view.frame.height / 3.85).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: view.frame.width / 3.5).isActive = true
        
        setupTextField()
    }
    
    func setupTextField() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        toolBar.isTranslucent = true
        textLabel.inputAccessoryView = toolBar
    }
    
    func recognizeText() {
        let vision = Vision.vision()
        let textRecognizer = vision.onDeviceTextRecognizer()
        
        if let imageResult = image {
            let visionImage = VisionImage(image: imageResult)
            
            textRecognizer.process(visionImage) { (result, error) in
                guard error == nil, let result = result else {
                    print("Error")
                    return
                }
                
                print(result.text)
                self.textLabel.text = result.text
                
                //let resultText = result.text
                for block in result.blocks {
                    let blockText = block.text
                    print("Block: ")
                    print(blockText)
//                    let blockConfidence = block.confidence
//                    let blockLanguages = block.recognizedLanguages
//                    let blockCornerPoints = block.cornerPoints
//                    let blockFrame = block.frame
                    for line in block.lines {
                        let lineText = line.text
                        print("Line: ")
                        print(lineText)
//                        let lineConfidence = line.confidence
//                        let lineLanguages = line.recognizedLanguages
//                        let lineCornerPoints = line.cornerPoints
//                        let lineFrame = line.frame
                    }
                }
            }
        }
    }
    
    @objc func speak() {
        if let text = textLabel.text {
            let utterance = AVSpeechUtterance(string: text)
            print(utterance)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            //"en-US" - American, "en-IE" - Irish, "en-AU" - Australian, "en-GB" - British
            
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    @objc func scan() {
        navigationController?.pushViewController(ScanViewController(), animated: true)
    }
    
    @objc func read() {
        let vc = ReadViewController()
        vc.readingText = textLabel.text
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @objc func nextClicked(_ sender: UIButton) {
        if let text = textLabel.text {
            if text == "Type, paste, or select a button below to begin!" || text.isEmpty {
                sender.shake()
            } else {
                navigationController?.pushViewController(ReadingChoicesViewController(), animated: true)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText: String = textView.text
        let updateText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updateText.isEmpty {
            textView.text = "Type, paste, or select a button below to begin!"
            textView.textColor = .lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == .lightGray && !text.isEmpty {
            textView.textColor = .black
            textView.text = text
        } else {
            return true
        }
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == .lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
