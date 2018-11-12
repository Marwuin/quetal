//
//  User.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 9/5/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON



enum userStates: Int {
    case registered = 9001
    case pendingActivation = 9002
    case active = 9003
}

class User: NSObject {
    
    fileprivate var json: JSON
    
//    var selectedTags = [Int]()
    var selectedItems = [Int]()
    var favItems = [Int]()
    var systemTags = [Int]()
    var customsTags = [Int]()
    var onPremise = false
    var offPremise = false
    var userState = userStates.active
    
    var profileDictionary = [2006:10263,2007:10055,2008:10278,2011:10388]
    
    init(json: JSON) {
        self.json = json
         profileDictionary = [Int:Int]()
        for tag in self.json["Tags"]{
            profileDictionary[ tag.1["TypeID"].int! ] = tag.1["TagID"].int
        }
        
       
        
        
    }
//
//    var profileDictionary: [Int:Int]? {
//        get {
//            if  self.json["Tags"] != JSON.null {
//                var prof = [Int:Int]()
//                for tag in self.json["Tags"] {
//                    prof[ tag.1["TypeID"].int! ] = tag.1["TagID"].int
//                }
//                return prof
//            }
//            else {
//                return [:]
//            }
//        }
//        set {
//            profileDictionary = newValue
//        }
//    }


    var userID: Int? {
        if let id = self.json["UserID"].int {
            return id
        }
        else {
            return nil
        }
    }
    
    var profileTags:JSON{
        return self.json["Tags"]
    }
    
    var firstName: String? {
        if let string = self.json["FirstName"].string {
            return string
        }
        else {
            return nil
        }
    }
    
    var lastName: String? {
        if let string = self.json["LastName"].string {
            return string
        }
        else {
            return nil
        }
    }
    
    var phone: String? {
        if let string = self.json["Phone"].string {
            return string
        }
        else {
            return nil
        }
    }
    
    var email: String? {
        print(self.json["Email"].string!)
        if let string = self.json["Email"].string {
            return string
        }
        else {
            return nil
        }
        
    }
    
    var role: String? {
        if let string = self.json["RoleName"].string {
            return string
        }
        else {
            return nil
        }
    }
    
    var roleID: Int? {
        if let interger = self.json["RoleID"].int {
            return interger
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
    
    var isActive: Bool? {
        if let bool = self.json["IsActive"].bool {
            return bool
        }
        else {
            return nil
        }
    }
    
    var isDeviceVerified: Bool? {
        if let bool = self.json["IsDeviceVerified"].bool {
            return bool
        }
        else {
            return nil
        }
    }

    
    
}
