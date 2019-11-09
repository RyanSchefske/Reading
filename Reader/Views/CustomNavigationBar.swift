//
//  CustomNavigationBar.swift
//  Reader
//
//  Created by Ryan Schefske on 10/11/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class CustomNavigationBar: UIView {
    var width = UIScreen.main.bounds.width + 4
    var height = UIScreen.main.bounds.height / 8
    var customNav = UIImageView()
    
    func customTitle(title: String) -> UILabel {
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : UIColor.lightGray,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeWidth : -1,
            NSAttributedString.Key.font : UIFont(name: "ArialRoundedMTBold", size: 30) ?? UIFont.systemFont(ofSize: 30)]
            as [NSAttributedString.Key : Any]
        
        let titleLabel = UILabel()
        titleLabel.attributedText = NSMutableAttributedString(string: title, attributes: strokeTextAttributes)
        return titleLabel
    }
}
