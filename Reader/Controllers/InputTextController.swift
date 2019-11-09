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
import GoogleMobileAds

class InputTextController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, GADBannerViewDelegate {
    
    var image: UIImage? = nil
    var contentString = String()
    var customNav = UIImageView()
    var textLabel = UITextView()
    var stackView = UIStackView()
    var scanButton = CustomButton()
    var photoButton = CustomButton()
    var speakButton = CustomButton()
    var nextButton = UIButton()
    var bgView = UIView()
    var bannerView = GADBannerView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseOut, animations: {
            self.textLabel.topAnchor.constraint(equalTo: self.customNav.bottomAnchor, constant: 7).isActive = true
            self.textLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width - 16).isActive = true
            self.textLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height / 2.5).isActive = true
            self.textLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            
            self.bgView.topAnchor.constraint(equalTo: self.textLabel.topAnchor).isActive = true
            self.bgView.heightAnchor.constraint(equalTo: self.textLabel.heightAnchor).isActive = true
            self.bgView.widthAnchor.constraint(equalTo: self.textLabel.widthAnchor).isActive = true
            self.bgView.centerXAnchor.constraint(equalTo: self.textLabel.centerXAnchor).isActive = true
            
            self.stackView.topAnchor.constraint(equalTo: self.textLabel.bottomAnchor, constant: 10).isActive = true
            self.nextButton.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 15).isActive = true
            
            self.view.layoutIfNeeded()
        }) { (completed) in
            // Do Nothing
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if image != nil {
            recognizeText()
        }
        
        if contentString.isEmpty && (textLabel.text == "Type, paste, or select a button below to begin!" || textLabel.text.isEmpty) {
            textLabel.text = "Type, paste, or select a button below to begin!"
            textLabel.textColor = .lightGray
        } else {
            textLabel.text = contentString
            textLabel.textColor = .black
        }
    }
    
    func setup() {
        navigationItem.titleView = CustomNavigationBar().customTitle(title: "Scholarly")
        
        view.backgroundColor = Colors().offWhite
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
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
        customNav.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        textLabel = {
            let textView = UITextView(frame: CGRect(x: 0, y: 100, width: 50, height: 50))
            if UIDevice.current.userInterfaceIdiom == .pad {
                textView.font = UIFont(name: "Helvetica", size: 24)
            } else {
                textView.font = UIFont(name: "Helvetica", size: 14)
            }
            textView.backgroundColor = .white
            textView.isEditable = true
            textView.center.x = self.view.center.x
            textView.textColor = .black
            textView.layer.cornerRadius = 5
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.delegate = self
            return textView
        }()
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 5
            view.layer.cornerRadius = 10
            view.layer.shadowOpacity = 1
            view.layer.shadowOffset = CGSize(width: 0, height: 7)
            view.layer.shadowColor = UIColor.lightGray.cgColor
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = false
            return view
        }()
        view.addSubview(bgView)
        view.addSubview(textLabel)
        
        speakButton = {
            let button = CustomButton()
            button.addTarget(self, action: #selector(speak), for: .touchUpInside)
            button.setTitle("Speak", for: .normal)
            button.setImage(UIImage(named: "speak"), for: .normal)
            if UIDevice.current.userInterfaceIdiom == .pad {
                button.titleLabel?.font = button.titleLabel?.font.withSize(30)
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
            }
            return button
        }()
        
        scanButton = {
            let button = CustomButton()
            button.addTarget(self, action: #selector(scan), for: .touchUpInside)
            button.setTitle("Scan", for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: -20)
            button.setImage(UIImage(named: "scan"), for: .normal)
            if UIDevice.current.userInterfaceIdiom == .pad {
                button.titleLabel?.font = button.titleLabel?.font.withSize(30)
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
            }
            return button
        }()
        
        photoButton = {
            let button = CustomButton()
            button.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
            button.setTitle("Upload", for: .normal)
            button.setImage(UIImage(named: "upload"), for: .normal)
            if UIDevice.current.userInterfaceIdiom == .pad {
                button.titleLabel?.font = button.titleLabel?.font.withSize(30)
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
            }
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
        
        bgView.center = CGPoint(x: self.view.center.x, y: 100)
        bgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: view.frame.height / 3.85).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: view.frame.width / 3.5).isActive = true
        
        setupTextField()
    }
    
    private func setupTextField() {
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
                    return
                }
                
                if self.textLabel.text != "Type, paste, or select a button below to begin!" {
                    self.contentString = self.textLabel.text + result.text
                    self.textLabel.text = self.contentString
                } else {
                    self.contentString = result.text
                    self.textLabel.text = self.contentString
                    self.textLabel.textColor = .black
                }
            }
        }
    }
    
    @objc private func speak() {
        saveContent()
        navigationController?.pushViewController(SpeechRecognizerViewController(), animated: true)
    }
    
    @objc private func scan() {
        saveContent()
        navigationController?.pushViewController(ScanViewController(), animated: true)
    }
    
    @objc private func read() {
        let vc = ReadViewController()
        vc.readingText = textLabel.text
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func selectPhoto() {
        saveContent()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = pickedImage
            recognizeText()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func nextClicked(_ sender: UIButton) {
        if let text = textLabel.text {
            if text == "Type, paste, or select a button below to begin!" || text.isEmpty {
                sender.shake()
            } else {
                saveContent()
                image = nil
                let vc = ReadingChoicesViewController()
                vc.readingText = contentString
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func saveContent() {
        if self.textLabel.text != "Type, paste, or select a button below to begin!" {
            self.contentString = self.textLabel.text
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        view.addBannerViewToView(bannerView, view)
    }
}

extension UIDevice {
    var hasNotch: Bool {
        let top = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        return top > 0
    }
}
