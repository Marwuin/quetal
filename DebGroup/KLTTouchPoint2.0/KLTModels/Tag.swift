//
//  Tag.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/22/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON



class Tag: NSObject {
    
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
        if let typeID = self.json["TypeID"].int {
            return typeID
        }
        else {
            return nil
        }
    }
    
    var isLibItem: Bool? {
      return  self.json["TypeID"].int == 2003
    }
    
    var iconURL: String? {
        if let url = self.json["IconUrl"].string {
            let arr = url.components(separatedBy: ".png")
            let string = arr[0] + "@\(Int(UIScreen.main.scale))x" + ".png"
            return string
        }
        else {
            return nil
        }
    }
    
    var iconMediaID: Int? {
        if let typeID = self.json["IconMediaID"].int {
            return typeID
        }
        else {
            return nil
        }
    }
    
    var title: String? {
        if let title = self.json["Title"].string {
            return title
        }
        else {
            return nil
        }
    }
    
    var thumbnail: String? {
        if let title = self.json["ThumbUrl"].string {
            return title
        }
        else {
            return nil
        }
    }
    
    var thumbMediaID: Int? {
        if let typeID = self.json["ThumbMediaID"].int {
            return typeID
        }
        else {
            return nil
        }
    }
    
    var name: String? {
        if let name = self.json["Name"].string {
            return name
        }
        else {
            return nil
        }
    }
    
    var sortOrder: Int? {
        if let sort = self.json["SortOrder"].int {
            return sort
        }
        else {
            return nil
        }
    }
    
    var isDashboard: Bool? {
        if let isDash = self.json["IsDashboard"].bool {
            return isDash
        }
        else {
            return nil
        }
    }
    
    var isFilterMenu: Bool? {
        if let isFilterMenu = self.json["IsFilterMenu"].bool {
            return isFilterMenu
        }
        else {
            return nil
        }
    }
    
    var isSearchableFilter: Bool? {
        if let isSearchableFilter = self.json["IsSearchFilterable"].bool {
            return isSearchableFilter
        }
        else {
            return nil
        }
    }
    
    var backgroundColor: UIColor? {
        if let color = self.json["BackgroundColor"].string {
   
            return UIColor.init(hexString: color)
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
    
    var isUserTag: Bool? {
        if let isuserTag = self.json["IsUserTag"].bool {
            return isuserTag
        }
        else {
            return nil
        }
    }
    
    var brandTags: [Int]?{
        if self.json["Tags"] != JSON.null{
            var ints = [Int]()
            for tag in self.json["Tags"]{
                ints.append(tag.1.int!)
            }
            return ints
        } else {
            return nil
        }
    }
    
    var containsSubbrandIDs: Bool {
        if let _ = brandTags {
            return true
        }
        else { return false }
    }
    
    var isOnCalendar: Bool? {
        if let calendarFlag = self.json["IsOnCalendar"].bool {
                return calendarFlag
        }
        else {
            return nil
        }
    }
    
    var isCenter: Bool? {
        if let centerFlag = self.json["IsFocus"].bool {
            return centerFlag
        }
        else {
            return nil
        }
    }
    
    var calStart:Date? {
        let startDate = self.json["DashboardStartDate"]
        if (startDate != JSON.null){
            let formatter = DateFormatter()
            formatter.timeZone =  NSTimeZone(name: "UTC")! as TimeZone
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let date = formatter.date(from: startDate.string!)
            return date
        }else{
            return nil
        }
    }
    
    var calEnd:Date? {
        let endDate = self.json["DashboardEndDate"]
        if (endDate != JSON.null){
            let formatter = DateFormatter()
            formatter.timeZone =  NSTimeZone(name: "UTC")! as TimeZone
           formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let date = formatter.date(from: endDate.string!)
            return date
        }else{
            return nil
        }
    }

    var isParent: Bool?  {
        let isparentexists = self.json["IsParent"].bool
        if let isParent = isparentexists {
            return isParent
        }
        else {
            return nil
        }
    }
}
