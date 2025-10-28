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
    
    init() {
        let topColor = UIColor.white.cgColor
        let bottomColor = UIColor.cyan.cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [topColor, bottomColor]
        self.gl.locations = [0, 1.5]
    }
}
