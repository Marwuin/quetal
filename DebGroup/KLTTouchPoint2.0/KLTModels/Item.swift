//
//  Item.swift
//  OpenTab
//
//  Created by Raul Silva on 6/23/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

enum ItemType {
    case pdf
    case video
    case product
    case article
    case other
}

class Item: NSObject {
    
    
    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    var itemType: ItemType? {
        if let id = self.json["TypeID"].int {
            switch id {
            case 4:
                return .article
            case 3:
                return .pdf
            case 2:
                return .video
            case 1:
                return .product
            default:
                return .other
            }
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
    
    var descriptionText: String? {
        if let description = self.json["Description"].string {
            return description
        }
        else {
            return nil
        }
    }
    
    var url: String? {
        if let url = self.json["Url"].string {
            return url
        }
        else {
            return nil
        }
    }
    
    var thumbnail: String? {
        if let url = self.json["ThumbUrl"].string {
            return url
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
    
    var id: Int? {
        if let id = self.json["MediaID"].int {
            return id
        }
        else {
            return nil
        }
    }
    
    var isFileOver100mbs: Bool? {
        if let attributes = self.json["Attributes"].dictionary {
            let attributesJSON = JSON(attributes)
            if attributesJSON != JSON.null {
                if let filesize = attributesJSON["FileSize"].string {
                    let bcf = ByteCountFormatter()
                    bcf.countStyle = .file
                    bcf.allowsNonnumericFormatting = false
                    bcf.includesUnit = false
                    let kbs = bcf.string(fromByteCount: Int64(filesize)!)
                    if Double(kbs)! > 100000 {
                        return true
                    }
                    else {
                      return false
                    }
                }
                else {
                    return false
                }
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    var tags: Array<Int>? {
        get {
            if let tags = self.json["Tags"].arrayObject {
                return tags as? Array<Int>
            }
            else {
                return nil
            }
        }
        set {
            self.json["Tags"].arrayObject = newValue
        }
    }
    
    var product: Product? {
        if self.itemType != .article {
            if let attributes = self.json["Attributes"].dictionary {
                let attributesJSON = JSON(attributes)
                if attributesJSON != JSON.null {
                    let product = Product.init(json: attributesJSON)
                    return product
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
        else { return nil }
    }
    
    var article: Article? {
        if self.itemType == .article {
            if let attributes = self.json["Attributes"].dictionary {
                let attributesJSON = JSON(attributes)
                if attributesJSON != JSON.null {
                    let article = Article.init(json: attributesJSON)
                    return article
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
        else { return nil }
    }
    
    var isFavorite: Bool? {
        get {
            if let bool = self.json["IsFavorite"].bool {
                return bool
            }
            else {
                return false
            }
        }
        set {
            self.json["IsFavorite"].bool = newValue
        }
    }
    
    var isToShare: Bool? {
        get {
            if let bool = self.json["IsToShare"].bool {
                return bool
            }
            else {
                return false
            }
        }
        set {
            self.json["IsToShare"].bool = newValue
        }
    }
    
    
    
}
