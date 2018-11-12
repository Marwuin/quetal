//
//  Library.swift
//  OpenTab
//
//  Created by Raul Silva on 6/23/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

class Library: NSObject {
    
    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }

    var thumbnail: String? {
        if let url = self.json["ThumbUrl"].string {
            return url
        }
        else {
            return nil
        }
    }
    
    var id: Int? {
        if let id = self.json["TagID"].int {
            return id
        }
        else {
            return nil
        }
    }

    var name: String? {
        if let title = self.json["Name"].string {
            return title
        }
        else {
            return nil
        }
    }
    
    var displayStartDate: Date? {
        if let date = self.json["DisplayStartDate"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter.date(from: date)
        }
        else {
            return nil
        }
    }
    
    var displayEndDate: Date? {
        if let date = self.json["DisplayEndDate"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter.date(from: date)
        }
        else {
            return nil
        }
    }
    
    var modifiedDate: Date? {
        if let date = self.json["ModifiedDate"].string {
            return Formatter.iso8601.date(from: date)
        }
        else {
            return nil
        }
    }
    
    var createdDate: Date? {
        if let date = self.json["CreateDate"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter.date(from: date)
        }
        else {
            return nil
        }
    }
}

