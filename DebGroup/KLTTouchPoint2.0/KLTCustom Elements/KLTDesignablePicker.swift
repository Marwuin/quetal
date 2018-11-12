//
//  KLTDesignablePicker.swift
//  OpenTab
//
//  Created by Raul Silva on 8/14/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit


class KLTDesignablePicker: UIPickerView {
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
         self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
         self.layer.borderColor = #colorLiteral(red: 0.9160427451, green: 0.9160427451, blue: 0.9160427451, alpha: 1).cgColor
    }

}
