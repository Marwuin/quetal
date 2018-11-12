//
//  KLTDesignablePicker.swift
//  OpenTab
//
//  Created by Raul Silva on 8/14/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit


@IBDesignable

class KLTDesignablePicker: UIPickerView {

    @IBInspectable var cornerRadius:CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth:Int = 0 {
        didSet{
            self.layer.borderWidth = CGFloat(borderWidth)
        }
    }
    @IBInspectable var borderColor:UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }

}
