//
//  Brand.swift
//  
//
//  Created by Raul Silva on 6/23/17.
//

import Foundation
import UIKit

class Brand{
    var name = ""
    var id:Int?
    var fileRef = ""
    var color = UIColor()
    init(name:String, id:Int, fileRef:String, color:UIColor) {
        self.name = name
        self.fileRef = fileRef
        self.id = id
        self.color = color
    }
}
