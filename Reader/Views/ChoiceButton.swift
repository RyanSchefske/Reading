//
//  ChoicesButton.swift
//  Reader
//
//  Created by Ryan Schefske on 10/6/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class ChoiceButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = Colors().buttonColor
        clipsToBounds = false
        layer.cornerRadius = 10
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 7)
        layer.shadowColor = UIColor.lightGray.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 16).isActive = true
    }
}
