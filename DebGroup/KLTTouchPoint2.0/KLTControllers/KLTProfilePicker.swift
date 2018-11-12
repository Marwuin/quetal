//
//  KLTProfilePicker.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 9/18/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

class KLTProfilePicker: UIPickerView {
    var label:UILabel?
    var child:KLTProfilePicker?
    var data:JSON!
    var typeID:Int?
    var ID:Int?
}
