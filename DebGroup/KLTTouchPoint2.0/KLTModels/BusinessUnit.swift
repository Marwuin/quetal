//
//  BusinessUnit.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 12/7/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

class BusinessUnit: NSObject {

    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    var tagID: Int? {
        if let tagID = self.json["TagID"].int {
            return tagID
        }
        else {
            return nil
        }
    }
    
    var typeID: Int? {
        if let tagID = self.json["TypeID"].int {
            return tagID
        }
        else {
            return nil
        }
    }
    
    var name: String? {
        if let tagID = self.json["Name"].string {
            return tagID
        }
        else {
            return nil
        }
    }
    
    var sublabel: String? {
        if let tagID = self.json["SubLabel"].string {
            return tagID
        }
        else {
            return nil
        }
    }
    
    var tags: Array<BusinessUnit>? {
        if let tagsJson = self.json["Tags"].array  {
            var arr: Array<BusinessUnit> = Array()
            for tag in tagsJson {
                let bu = BusinessUnit.init(json: tag)
                arr.append(bu)
            }
            return arr
        }
        else {
            return nil
        }
    }
    
}
