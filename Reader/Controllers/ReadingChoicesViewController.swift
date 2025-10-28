//
//  ReadingChoicesViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 10/6/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ReadingChoicesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var customNav = UIImageView()
    private var choicesCV = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: UICollectionViewFlowLayout())
    var readingText = String()
    var clicks = 0

    // Settings repository for type-safe preferences access
    private let settingsRepository: SettingsRepositoryProtocol

    init(settingsRepository: SettingsRepositoryProtocol = SettingsRepository()) {
        self.settingsRepository = settingsRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.settingsRepository = SettingsRepository()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Load interstitial ad for later use
        AdManager.shared.loadInterstitial()
        clicks = settingsRepository.clicks
    }
    
    func setup() {
        navigationItem.titleView = CustomNavigationBar().customTitle(title: "Choices")
        view.backgroundColor = Colors().offWhite
        navigationItem.backBarButtonItem?.title = ""
        
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
        
        choicesCV = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), collectionViewLayout: UICollectionViewFlowLayout())
            collectionView.backgroundColor = Colors().offWhite
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(SpeakCell.self, forCellWithReuseIdentifier: "speakCellId")
            collectionView.register(ReadCell.self, forCellWithReuseIdentifier: "readCellId")
            collectionView.register(SpeedCell.self, forCellWithReuseIdentifier: "speedCellId")
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.layer.zPosition = -1
            return collectionView
        }()
        view.addSubview(choicesCV)
        
        choicesCV.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 65, right: 0)
        
        choicesCV.topAnchor.constraint(equalTo: customNav.bottomAnchor, constant: -25).isActive = true
        choicesCV.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        choicesCV.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        choicesCV.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        choicesCV.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Add banner ad using AdManager
        AdManager.shared.addBannerToView(view, viewController: self)
    }
    
    @objc private func speedClicked() {
        let vc = SpeedReadViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func readClicked() {
        let vc = ReadViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func speakClicked() {
        let vc = SpeechViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.height / 3.5
        return CGSize(width: choicesCV.frame.width - 10, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = choicesCV.dequeueReusableCell(withReuseIdentifier: "speakCellId", for: indexPath) as! BaseCell
            cell.titleLabel.text = "Speak"
            return cell
        } else if indexPath.item == 1 {
            let cell = choicesCV.dequeueReusableCell(withReuseIdentifier: "speedCellId", for: indexPath) as! SpeedCell
            cell.titleLabel.text = "Speed Read"
            return cell
        } else {
            let cell = choicesCV.dequeueReusableCell(withReuseIdentifier: "readCellId", for: indexPath) as! ReadCell
            cell.titleLabel.text = "Scroll"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Show interstitial ad every 2 clicks
        if clicks % 2 == 0 {
            AdManager.shared.showInterstitial(from: self)
        }

        clicks += 1
        settingsRepository.clicks = clicks
        
        if indexPath.item == 0 {
            let vc = SpeechViewController()
            vc.readingText = readingText
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.item == 1 {
            let vc = SpeedReadViewController()
            vc.readingText = readingText
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.item == 2 {
            let vc = ReadViewController()
            vc.readingText = readingText
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
