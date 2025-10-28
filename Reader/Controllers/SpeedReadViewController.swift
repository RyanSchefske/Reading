//
//  SpeedReadViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 9/2/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SpeedReadViewController: UIViewController {

    var customNav = UIImageView()
    var readingText = String()
    var words: [String] = []
    var wordLabel = UILabel()
    var resetButton = UIButton()
    var timer = Timer()
    var slider = UISlider()
    var sliderLabel = UILabel()
    var pauseButton = UIButton()
    var buttonView = UIView()
    var counter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        view.backgroundColor = Colors().offWhite
        navigationItem.titleView = CustomNavigationBar().customTitle(title: "Speed Read")

        readingText = readingText.replacingOccurrences(of: "\n", with: " ")

        // Add banner ad using AdManager
        AdManager.shared.addBannerToView(view, viewController: self)


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
        
        words = readingText.components(separatedBy: " ")
        
        wordLabel = {
            let label = UILabel(frame: CGRect(x: 0, y: self.view.center.y, width: self.view.frame.width, height: 35))
            label.center = view.center
            label.font = label.font.withSize(30)
            label.numberOfLines = 0
            label.textColor = .black
            label.textAlignment = .center
            return label
        }()
        view.addSubview(wordLabel)
        
        slider = {
            let slider = UISlider()
            slider.minimumValue = 50
            slider.maximumValue = 800
            slider.setValue(100, animated: true)
            slider.isContinuous = true
            slider.isEnabled = true
            slider.tintColor = Colors().buttonColor
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
            return slider
        }()
        view.addSubview(slider)
        
        slider.topAnchor.constraint(equalTo: customNav.bottomAnchor, constant: 10).isActive = true
        slider.widthAnchor.constraint(equalToConstant: view.frame.width - 50).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 20).isActive = true
        slider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        sliderLabel = {
            let label = UILabel()
            label.text = "\(Int(slider.value)) WPM"
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            return label
        }()
        view.addSubview(sliderLabel)
        
        sliderLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 10).isActive = true
        sliderLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        sliderLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        sliderLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        buttonView = {
            let view = UIView(frame: CGRect(x: 0, y: self.view.center.y + 100, width: self.view.frame.width / 1.5, height: 75))
            view.backgroundColor = Colors().buttonColor
            view.center.x = self.view.center.x
            view.layer.cornerRadius = 10
            view.layer.shadowOpacity = 1
            view.layer.shadowOffset = CGSize(width: 0, height: 7)
            view.layer.shadowColor = UIColor.lightGray.cgColor
            return view
        }()
        view.addSubview(buttonView)
        
        let backButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "back10"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
            return button
        }()
        
        let forwardButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "forward10"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(forwardClicked), for: .touchUpInside)
            return button
        }()
        
        pauseButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "play"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(playPause), for: .touchUpInside)
            return button
        }()
        
        let stackView: UIStackView = {
            let stack = UIStackView()
            stack.alignment = .center
            stack.distribution = .equalCentering
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(backButton)
            stack.addArrangedSubview(pauseButton)
            stack.addArrangedSubview(forwardButton)
            return stack
        }()
        buttonView.addSubview(stackView)
        
        stackView.heightAnchor.constraint(equalToConstant: buttonView.frame.height - 5).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: buttonView.frame.width - 10).isActive = true
        stackView.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor).isActive = true
        
        resetButton = {
            let button = UIButton(frame: CGRect(x: 0, y: self.view.center.y + 190, width: self.view.frame.width / 3.5, height: 40))
            button.center.x = self.view.center.x
            button.setTitle("Reset", for: .normal)
            button.titleLabel?.textAlignment = .center
            button.setTitleColor(Colors().buttonColor, for: .normal)
            button.layer.borderColor = Colors().buttonColor.cgColor
            button.layer.borderWidth = 3
            button.layer.cornerRadius = 20
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(reset), for: .touchUpInside)
            return button
        }()
        view.addSubview(resetButton)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            timer.invalidate()
            slider.isEnabled = true
            pauseButton.setImage(UIImage(named: "play"), for: .normal)
            counter = 0
            wordLabel.text = ""
        }
    }
    
    @objc func playPause() {
        if pauseButton.imageView?.image == UIImage(named: "play") {
            let speed: Double = 60 / Double(slider.value)
            timer = Timer.scheduledTimer(timeInterval: speed, target: self, selector: #selector(newWord), userInfo: nil, repeats: true)
            pauseButton.setImage(UIImage(named: "pause"), for: .normal)
            slider.isEnabled = false
        } else {
            timer.invalidate()
            pauseButton.setImage(UIImage(named: "play"), for: .normal)
            slider.isEnabled = true
        }
    }
    
    @objc func forwardClicked() {
        if counter + 10 < words.count {
            counter += 10
        }
    }
    
    @objc func backClicked() {
        if counter - 10 >= 0 {
            counter -= 10
        }
    }
    
    @objc func reset() {
        timer.invalidate()
        counter = 0
        slider.isEnabled = true
        pauseButton.setImage(UIImage(named: "play"), for: .normal)
        wordLabel.text = ""
    }
    
    @objc func sliderValueDidChange(_ sender: UISlider!) {
        let roundedStepValue = round(sender.value / 5) * 5
        sender.value = roundedStepValue
        sliderLabel.text = "\(Int(roundedStepValue)) WPM"
    }
    
    @objc func newWord() {
        if counter < words.count {
            if words[counter].count > 2 {
                let range = NSRange(location:2,length:1)
                let attributedString = NSMutableAttributedString(string: words[counter], attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica", size: 30) ?? UIFont.systemFont(ofSize: 30)])
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors().buttonColor, range: range)
                wordLabel.attributedText = attributedString
            } else {
                wordLabel.text = words[counter]
            }
            
            counter += 1
        } else {
            timer.invalidate()
            reset()
            pauseButton.setImage(UIImage(named: "play"), for: .normal)
            slider.isEnabled = true
        }
    }
}
