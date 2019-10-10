//
//  CustomButton.swift
//  Reader
//
//  Created by Ryan Schefske on 9/15/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    let cellSize = UIScreen.main.bounds.width - 20
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentHorizontalAlignment = .left
        let availableSpace = bounds.inset(by: contentEdgeInsets)
        let availableWidth = availableSpace.width - imageEdgeInsets.right - (imageView?.frame.width ?? 0) - (titleLabel?.frame.width ?? 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: availableWidth / 3, bottom: 0, right: 0)
    }
    
    func setupButton() {
        titleLabel?.textAlignment = .center
        titleLabel?.textColor = .white
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 0)
        backgroundColor = Colors().buttonColor
        
        clipsToBounds = false
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 7)
        layer.shadowColor = UIColor.lightGray.cgColor
        
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: cellSize).isActive = true
        layer.cornerRadius = 10
    }
}

extension UIButton {
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: nil)
    }
}

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
        contentVerticalAlignment = .top
        titleEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
}
