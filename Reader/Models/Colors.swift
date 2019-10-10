//
//  Colors.swift
//  Reader
//
//  Created by Ryan Schefske on 9/23/19.
//  Copyright © 2019 Ryan Schefske. All rights reserved.
//

import UIKit

class Colors {
    var gl: CAGradientLayer!
    var offWhite = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    var buttonColor = UIColor(red: 31/255, green: 128/255, blue: 1, alpha: 1)
    
    init() {
        let topColor = UIColor.white.cgColor
        let bottomColor = UIColor.cyan.cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [topColor, bottomColor]
        self.gl.locations = [0, 1.5]
    }
}
