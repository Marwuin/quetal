//
//  KLTMediaRequests.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/22/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

class KLTMediaRequests: NSObject {

    enum MediaEndpoints: String {
        case search = "Search/"
        case tags = "Tags/"
        case favorite = "/User/Favorite/"
        case createTag = "Tag/User/"
        case deleteTag = "Tag/"
    }
    
    let endpoint = "/api/v1/Media/"
    
    /// Gets all the media items that currently exist for the user
    ///
    /// - completion: returns an array of Items and/or an error.
    
    func getAllItems(completion: @escaping (_ items: [Item]?, _ error: Error?) -> Void) {
       
        let parameters: [String : Any] = ["MediaID" : "", "SearchText" : "", "Types" : ["1","2","3","4","5","6"], "BusinessUnits" : "", "Brands" : "", "Tags" : "", "OrderBy" : "Title"]
        
        print("getAllItems")
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint + MediaEndpoints.search.rawValue, parameters: parameters) { (response) in
            if response.json != nil {
                
                
                var arr: Array<Item> = Array()
                
                //print("getAllItems A \(response.json?.array)")
                if let itemsArray = response.json?.array {
                    for item in itemsArray {
                        let currentItem = Item.init(json: item)
                        arr.append(currentItem)
 
                    }
                    
                    //Got Fresh set of items
                    KLTDownloadManager.sharedInstance.saveToFile(fileName: "ItemData.json", json: response.json!)
                  

                    
                    //remove no longer existing items from mailbag
                    var itemIDsRetrieved: Array<Int> = Array()
                    for item in arr {
                        itemIDsRetrieved.append(item.id!)
                    }
                    for mail in KLTManager.sharedInstance.mailbagItems {
                        if !itemIDsRetrieved.contains(mail) {
                            KLTManager.sharedInstance.mailbagItems.remove(at: KLTManager.sharedInstance.mailbagItems.index(of: mail)!)
                        }
                    }
                    
                    //Return items array
                    completion(arr, nil)
                }
            }
            else {
                print("getAllItems B")
                completion(nil, response.error!)
            }
        }
    }
    
    /// Gets all the tags that currently exist for the user
    ///
    /// - completion: returns an array of Tags and/or an error.
    
    func getBusinessData(completion: @escaping (_ data: JSON?, _ error: Error?) -> Void) {

        var compound = "/api/v1/Client/Role/"
        if let user = KLTManager.sharedInstance.currentUser {
            compound = compound + String(describing: user.roleID!) +  "/Hierarchy/"
        }else{
            if let roleID = UserDefaults.standard.object(forKey: "roleID") {
                compound = compound + String(describing: roleID) +  "/Hierarchy/"
            }else{
                compound = compound + "1/Hierarchy/"
            }
        }
        let client = KLTClientServices.init()
        client.getRequest(with: compound, parameters: nil) { (response) in
            if response.json != nil {
                
                KLTManager.sharedInstance.businessUnitsData = BusinessUnitsData(json:response.json!)
                KLTDownloadManager.sharedInstance.saveToFile(fileName: "BusinessData.json", json: response.json!)
                completion(response.json, nil)
            }
            else {
                completion(nil, response.error!)
            }
        }
    }
    
    func getAllTags(completion: @escaping (_ items: [Tag]?, _ error: Error?) -> Void) {
       
        let client = KLTClientServices.init()
        client.getRequest(with: endpoint + MediaEndpoints.tags.rawValue, parameters: nil) { (response) in
            if response.json != nil {
                
                
                var arr: Array<Tag> = Array()
                if let itemsArray = response.json?.array {
                    for item in itemsArray {
                        let currentTag = Tag.init(json: item)
                        arr.append(currentTag)
                    }
                     KLTDownloadManager.sharedInstance.saveToFile(fileName: "TagsData.json", json: response.json!)
  
                    completion(arr, nil)
                }
            }
            else {
                completion(nil, response.error!)
            }
        }
    }
    
    func getAllItemsIfChanged(after date:Date) {
        
    }
    
}


//Favoriting
extension KLTMediaRequests {

    func favorite(itemID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let request = KLTClientServices.init()
        request.putRequest(with: endpoint + "\(itemID)" + MediaEndpoints.favorite.rawValue, parameters: nil) { (response) in
            if response.statusCode! == 200 {
                completion(true, nil)
            }
            else {
                completion(false, response.error)
            }
        }
    }
    
    func unfavorite(itemID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let request = KLTClientServices.init()
        request.deleteRequest(with: endpoint + "\(itemID)" + MediaEndpoints.favorite.rawValue, parameters: nil) { (response) in
            if response.statusCode! == 200 {
                completion(true, nil)
            }
            else {
                completion(false, response.error)
            }
        }
    }
}

//Tags
extension KLTMediaRequests {
    func createTag(tagName: String, completion: @escaping (_ tagID: Int?, _ success: Bool, _ error: Error?) -> Void) {
        let request = KLTClientServices.init()
        request.postRequest(with: endpoint + MediaEndpoints.createTag.rawValue, parameters: ["TagName": tagName]) { (response) in
            if response.json != nil {
                if let tag = response.json!["TagID"].int {
                    completion(tag, true, nil)
                }
                else {
                    completion(nil, false, nil)
                }
            }
            else {
                completion(nil, false, response.error)
            }
        }
    }
    
    func tagMedia(tags:[Int], mediaId: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void ) {
        let request = KLTClientServices.init()
        request.putRequest(with: endpoint + "\(mediaId)/" + MediaEndpoints.createTag.rawValue, parameters: ["Tags" : tags]) { (response) in
            if response.statusCode == 200 {
                completion (true, nil)
            }
            else {
                completion (false, response.error)
            }
        }
    }
    
    func deleteTag(tagID: Int, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let request = KLTClientServices.init()
        request.deleteRequest(with: endpoint + MediaEndpoints.deleteTag.rawValue + "\(tagID)/" , parameters: nil) { (response) in
            if response.statusCode == 200 {
                completion(true, nil)

            }
            else {
                completion(false, response.error)
            }
        }
    }
    
}
