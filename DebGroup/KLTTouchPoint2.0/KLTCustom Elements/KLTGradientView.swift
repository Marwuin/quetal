//
//  KLTGradientView.swift
//  OpenTab
//
//  Created by Raul Silva on 8/12/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTGradientView: UIView {
    let  gradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        gradientLayer.colors = [UIColor.gray.cgColor, UIColor.clear.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [ 0.0, 1.0]
        self.alpha = 0.4
        self.layer.addSublayer(gradientLayer)
    }
}
