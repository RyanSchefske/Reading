//
//  ReadingChoicesViewController.swift
//  Reader
//
//  Created by Ryan Schefske on 10/6/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class ReadingChoicesViewController: UIViewController {
    
    var oneAtATimeButton = ChoiceButton()
    var readButton = ChoiceButton()
    var speakButton = ChoiceButton()
    var stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        title = "Choices"
        view.backgroundColor = Colors().offWhite
        navigationItem.backBarButtonItem?.title = ""
        
        oneAtATimeButton.setTitle("Speed Read", for: .normal)
        oneAtATimeButton.addTarget(self, action: #selector(speedClicked), for: .touchUpInside)
        
        readButton.setTitle("Read", for: .normal)
        readButton.addTarget(self, action: #selector(readClicked), for: .touchUpInside)
        
        speakButton.setTitle("Speak", for: .normal)
        speakButton.addTarget(self, action: #selector(speakClicked), for: .touchUpInside)
        
        stackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.distribution = .fillEqually
            stack.alignment = .center
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(oneAtATimeButton)
            stack.addArrangedSubview(readButton)
            stack.addArrangedSubview(speakButton)
            return stack
        }()
        view.addSubview(stackView)
        
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: view.frame.height / 1.5).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: view.frame.width - 16).isActive = true
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
    
}
