//
//  SpeechSettingsViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 11/5/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit
import AVFoundation

class SpeechSettingViewController: UITableViewController {

    var customNav = UIImageView()
    var voices = [String]()
    var selectedVoice = String()
    var selectedSpeed = String()
    var speeds = ["Very Slow", "Slow", "Normal", "Fast", "Very Fast"]

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
    
    func setup() {
        view.backgroundColor = .white
        navigationItem.title = "Settings"
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = Colors().buttonColor
        let textAttributes = [NSAttributedString.Key.foregroundColor: Colors().buttonColor]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        selectedVoice = settingsRepository.speechVoice
        selectedSpeed = settingsRepository.speechSpeed
        
        let speechVoices = AVSpeechSynthesisVoice.speechVoices()
        speechVoices.forEach { (voice) in
            if voice.language.contains("en") {
                voices.append(voice.name)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return voices.count
        } else {
            return speeds.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Voice"
        } else {
            return "Speed"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let numberOfRows = tableView.numberOfRows(inSection: section)
        for row in 0..<numberOfRows {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                cell.accessoryType = row == indexPath.row ? .checkmark : .none
            }
        }
        
        if section == 0 {
            settingsRepository.speechVoice = voices[indexPath.row]
        }

        if section == 1 {
            settingsRepository.speechSpeed = speeds[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        
        if indexPath.section == 0 {
            cell.textLabel?.text = voices[indexPath.row]
            if cell.textLabel?.text == selectedVoice {
                cell.accessoryType = .checkmark
            }
        } else {
            cell.textLabel?.text = speeds[indexPath.row]
            if cell.textLabel?.text == selectedSpeed {
                cell.accessoryType = .checkmark
            }
        }
        
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            navigationController?.navigationBar.isTranslucent = true
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.barTintColor = Colors().offWhite
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 25) ?? UIFont.systemFont(ofSize: 25)]
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.backgroundColor = .clear
        }
    }
}
