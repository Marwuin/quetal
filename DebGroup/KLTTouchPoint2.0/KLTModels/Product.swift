//
//  Product.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 8/29/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

class Product: NSObject {
    
    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    var shopTitle: String? {
        if let string = self.json["ShopTitle"].string {
            return string
        }
        else {
            return nil
        }
    }
    
    var details: String? {
        if let string = self.json["Details"].string {
            return string
        }
        else {
            return nil
        }
    }
    
    var price: String? {
        if let string = self.json["Price"].string {
            return string
        }
        else {
            return nil
        }
    }
    
    var preBuyPrice: String? {
        if let string = self.json["Pre-buyPrice"].string {
            return string
        }
        else {
            return nil
        }
    }
    
    var sku: String? {
        if let string = self.json["BdaSKU"].string {
            return string
        }
        else {
            return nil
        }
    }
    
}
