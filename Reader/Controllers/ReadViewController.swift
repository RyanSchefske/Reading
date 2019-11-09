//
//  ReadViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 9/13/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ReadViewController: UIViewController, GADBannerViewDelegate {
    
    var customNav = UIImageView()
    var slider = UISlider()
    var sliderLabel = UILabel()
    var buttonView = UIView()
    var readingLabel = UILabel()
    var pauseButton = UIButton()
    var readingText = String()
    var bannerView = GADBannerView()
    
    var started = false
    var paused = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        view.backgroundColor = Colors().offWhite
        navigationItem.titleView = CustomNavigationBar().customTitle(title: "Read")
        
        readingText = readingText.replacingOccurrences(of: "\n", with: " ")
        
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
        
        readingLabel = {
            var label = UILabel()
            if UIDevice.current.userInterfaceIdiom == .pad {
                label = UILabel(frame: CGRect(x: self.view.frame.width, y: self.view.center.y, width: readingText.width(withConstrainedHeight: 45, font: UIFont.systemFont(ofSize: 35)), height: 45))
                label.font = label.font.withSize(35)
            } else {
                label = UILabel(frame: CGRect(x: self.view.frame.width, y: self.view.center.y, width: readingText.width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 24)), height: 30))
                label.font = label.font.withSize(24)
            }
            label.text = readingText
            label.textColor = .black
            return label
        }()
        view.addSubview(readingLabel)
        
        slider = {
            let slider = UISlider()
            slider.minimumValue = 20
            slider.maximumValue = 300
            slider.setValue(60, animated: true)
            slider.isContinuous = true
            slider.tintColor = Colors().buttonColor
            slider.isEnabled = true
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
        
        pauseButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(read), for: .touchUpInside)
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
            button.setTitle("Play", for: .normal)
            return button
        }()
        view.addSubview(pauseButton)
        
        pauseButton.topAnchor.constraint(equalTo: readingLabel.bottomAnchor, constant: 100).isActive = true
        pauseButton.widthAnchor.constraint(equalToConstant: view.frame.width - 16).isActive = true
        pauseButton.heightAnchor.constraint(equalToConstant: view.frame.height / 12).isActive = true
        pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pauseButton.titleLabel?.textAlignment = .center
    }
    
    @objc func sliderValueDidChange(_ sender: UISlider!) {
        let roundedStepValue = round(sender.value / 5) * 5
        sender.value = roundedStepValue
        sliderLabel.text = "\(Int(roundedStepValue)) WPM"
    }
    
    @objc func read() {
        let layer = readingLabel.layer
        let words = readingText.components(separatedBy: " ")
        let characters = readingText.count
        let avgCharPerWord: Double = Double(characters / words.count)
        let wps = slider.value / 60
        let cps = Double(wps) * Double(avgCharPerWord)
        let speed = Double(characters) / cps
        if !started {
            UIView.animate(withDuration: speed, delay: 0, options: .curveLinear, animations: {
                self.readingLabel.center.x -= self.view.frame.width + self.readingLabel.frame.width
            }, completion: { (complete) in
                if complete {
                    self.pauseButton.setTitle("Play", for: .normal)
                    self.readingLabel.center.x = self.view.frame.width + self.readingLabel.frame.width / 2
                    self.started = false
                    self.slider.isEnabled = true
                }
            })
            started = true
            self.pauseButton.setTitle("Pause", for: .normal)
            self.slider.isEnabled = false
        } else {
            if !paused {
                let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
                layer.speed = 0
                layer.timeOffset = pausedTime
                paused = true
                self.pauseButton.setTitle("Play", for: .normal)
            } else {
                let pausedTime: CFTimeInterval = layer.timeOffset
                layer.speed = 1
                layer.timeOffset = 0
                layer.beginTime = 0
                let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
                paused = false
                self.pauseButton.setTitle("Pause", for: .normal)
            }
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        view.addBannerViewToView(bannerView, view)
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
