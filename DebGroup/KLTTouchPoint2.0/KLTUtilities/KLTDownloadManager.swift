//
//  KLTDownloadManager.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 9/5/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON


protocol KLTError: Error {
    var localizedTitle: String { get }
    var localizedDescription: Dictionary<String, Any>? { get }
}

protocol KLTDownloadManagerDelegate:class{
    func didDownloadData()
}

struct DownloadError: KLTError {
    var localizedTitle: String
    var localizedDescription: Dictionary<String, Any>?
    
    init(localizedTitle: String?, localizedDescription: Dictionary<String, Any>?) {
        self.localizedTitle = localizedTitle ?? "Error"
        self.localizedDescription = localizedDescription
    }
}

public class KLTDownloadManager: NSObject {

    var queue = TaskQueue()
    weak var delegate:KLTDownloadManagerDelegate?
    public static let sharedInstance : KLTDownloadManager = {
        let instance = KLTDownloadManager()
        return instance
    }()
    
    public func downloadAllData(completion: @escaping (_ succes: Bool) -> Void) {
        
        let request = KLTMediaRequests.init()
        let userRequest = KLTUserRequests.init()

        var cnt = 1
        queue.tasks += {[weak queue] result, next in
            cnt = cnt + 1
            userRequest.getUser(completion: { (success, error) in
                if error != nil {
                    if cnt > 3 { //retry 3 times failed resort to docs directory
                        self.getUserFromDocumentsDirectory(completion: { (success, error) in
                            if success {
                                next(nil)
                                print("got user")
                            }
                            else {
                                self.getDataFailureRetryMessage()
                            }
                        })
                    }
                    else {
                        queue!.retry(1)
                    }
                }
                else { //no error, use newest user from docs directory
                    self.getUserFromDocumentsDirectory(completion: { (success, error) in
                        if success {
                            next(nil)
                            print("got new user")
                        }
                        else {
                            self.getDataFailureRetryMessage()
                        }
                    })
                }
            })
        }
        
        cnt = 1
        queue.tasks += {[weak queue] result, next in
            cnt = cnt + 1
            request.getAllItems(completion: { (items, error) in
                if error != nil {
                    if cnt > 3 { //retry 3 times failed resort to docs directory
                        self.getItemsFromDocumentsDirectory(completion: { (success, error) in
                            if success {
                                next(nil)
                                print("got items")
                            }
                            else {
                               self.getDataFailureRetryMessage()
                            }
                        })
                    }
                    else {
                        queue!.retry(1)
                    }
                }
                else { //no error, use newest items from docs directory
                    self.getItemsFromDocumentsDirectory(completion: { (success, error) in
                        if success {
                            UserDefaults.standard.set(Formatter.iso8601.string(from: Date()), forKey: "lastItemRefreshDate")
                            next(nil)
                            print("got new items")
                        }
                        else {
                            self.getDataFailureRetryMessage()
                        }
                    })
                }
            })
        }
        cnt = 1
        queue.tasks += {[weak queue] result, next in
            cnt = cnt + 1
            request.getAllTags(completion: { (tags, error) in
                if error != nil {
                    if cnt > 3 { //retry 3 times failed
                        self.getTagsFromDocumentsDirectory(completion: { (success, error) in
                            if success {
                                next(nil)
                                print("got tags")
                            }
                            else {
                                self.getDataFailureRetryMessage()
                            }
                        })
                    }
                    else {
                        queue!.retry(1)
                    }
                }
                else {
                    self.getTagsFromDocumentsDirectory(completion: { (success, error) in
                        if success {
                            
                            UserDefaults.standard.set(Formatter.iso8601.string(from: Date()), forKey: "lastTagRefreshDate")
                            next(nil)
                            print("got new tags")
                        }
                        else {
                            self.getDataFailureRetryMessage()
                        }
                    })
                }
            })
        }
        
//        cnt = 1
//        queue.tasks += {[weak queue] result, next in
//            cnt = cnt + 1
//            request.getBusinessData(completion: { (tags, error) in
//                if error != nil {
//                    if cnt > 3 { //retry 3 times failed
//                        self.getBusinessDataFromDocumentsDirectory(completion: { (success, error) in
//                            if success {
//                                next(nil)
//                                print("got business data")
//                            }
//                            else {
//                                self.getDataFailureRetryMessage()
//                            }
//                        })
//                    }
//                    else {
//                        queue!.retry(1)
//                    }
//                }
//                else {
//                    self.getBusinessDataFromDocumentsDirectory(completion: { (success, error) in
//                        if success {
//                            next(nil)
//                            print("got new business data")
//                        }
//                        else {
//                            self.getDataFailureRetryMessage()
//                        }
//                    })
//                }
//            })
//        }
        
        queue.run {
            self.delegate?.didDownloadData()
            completion(true)
            
        }
    }
    
    func getDataFailureRetryMessage() {
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { (action: UIAlertAction!) in
            self.queue.retry(1)
        })
        if KLTManager.sharedInstance.networkConnectionAvailable! {
            UIViewController.top?.showErrorAlert(message: "Unable to download content. Please try again.", action: retry)
        }
        else {
             UIViewController.top?.showErrorAlert(message: "Check internet connection and please try again.", action: retry)
        }
    }
}

extension KLTDownloadManager {
    
    func getBusinessDataFromDocumentsDirectory(completion: @escaping (_ succes: Bool, _ error: Error?) -> Void) {
        let fileURL = getFileURL(path: "BusinessData.json")
        
        //First check if ItemData file is in Documents Directory
        do {
            guard let jsonData = try? Data.init(contentsOf: fileURL, options: .mappedIfSafe) else {
                throw DownloadError.init(localizedTitle: "Could not find BusinessData in Documents Directory", localizedDescription: nil)
            }
            let json = JSON(jsonData)
            
            KLTManager.sharedInstance.businessUnitsData = BusinessUnitsData(json: json)
            completion(true, nil)
        }
        catch {
            //could not get items from documents directory
            completion(false, error)
        }
    }
    
    func getItemsFromDocumentsDirectory(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let fileURL = getFileURL(path: "ItemData.json")
        //First check if ItemData file is in Documents Directory
        do {
            guard let jsonData = try? Data.init(contentsOf: fileURL, options: .mappedIfSafe) else {
                throw DownloadError.init(localizedTitle: "Could not find Items in Documents Directory", localizedDescription: nil)
            }
            let json = JSON(jsonData)
            var arr: Array<Item> = Array()
            if let itemsArray = json.array {
                for item in itemsArray {
                    let currentItem = Item.init(json: item)
                    arr.append(currentItem)
                }
                
                let articles = arr.filter{$0.itemType == .article}
                KLTManager.sharedInstance.kltItemsData = arr
                KLTManager.sharedInstance.kltArticlesData = articles

                //Download Media Associated with items
                KLTDownloadManager.sharedInstance.downloadItemMedia(itemArray: arr)
                completion(true, nil)
            }
        }
        catch {
            //could not get items from documents directory
            completion(false, error)
        }
    }
    
    func getTagsFromDocumentsDirectory(completion: @escaping (_ succes: Bool, _ error: Error?) -> Void) {
        let fileURL = getFileURL(path: "TagsData.json")
        
        //First check if ItemData file is in Documents Directory
        do {
            guard let jsonData = try? Data.init(contentsOf: fileURL, options: .mappedIfSafe) else {
                throw DownloadError.init(localizedTitle: "Could not find Tags in Documents Directory", localizedDescription: nil)
            }
            let json = JSON(jsonData)
            var arr: Array<Tag> = Array()
            if let tagsArray = json.array {
                for tag in tagsArray {
                    let currentTag = Tag.init(json: tag)
                    arr.append(currentTag)
                }
                self.saveTagsToVar(array: arr)
                KLTDownloadManager.sharedInstance.downloadTagsThumbnails(tags: arr)
                completion(true, nil)
            }
        }
        catch {
            //could not get items from documents directory
            completion(false, error)
        }
    }
    
    func getUserFromDocumentsDirectory(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let fileURL = getFileURL(path: "UserData.json")
        //First check if ItemData file is in Documents Directory
        do {
            guard let jsonData = try? Data.init(contentsOf: fileURL, options: .mappedIfSafe) else {
                throw DownloadError.init(localizedTitle: "Could not find User in Documents Directory", localizedDescription: nil)
            }
            let json = JSON(jsonData)
            let user = User.init(json:json)
            KLTManager.sharedInstance.currentUser = user
            UserDefaults.standard.set(user.roleID, forKey: "roleID")
            completion(true, nil)

        }
        catch {
            //could not get user from documents directory
            completion(false, error)
        }
    }
    
    func getFileURL(path: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(path)
        return fileURL
    }
    
    func saveTagsToVar(array: Array<Tag>) {
        ///Populate tags filter
        var libraryTags: Array<Tag> = Array()
        var searchableTags: Array<Tag> = Array()
        var promotionsTags: Array<Tag> = Array()
        var calendarTags: Array<Tag> = Array()
        var brandsTags: Array<Tag> = Array()
        var categoryTags: Array<Tag> = Array()
        var dashboardTags: Array<Tag> = Array()
        var browseLibraryHardcodedtag: Tag?

        for tag in array {
            if tag.typeID == 2000 {
                brandsTags.append(tag)
            }
            
            if tag.typeID == 2002 {
                if (tag.isOnCalendar)! {
                    calendarTags.append(tag)
                }
                promotionsTags.append(tag)
            }
            
            if tag.typeID == 2003 {
                libraryTags.append(tag)
            }
            
            if tag.isSearchableFilter == true {
                searchableTags.append(tag)
            }
            
            if tag.isFilterMenu == true {
                categoryTags.append(tag)
            }
            
            if tag.isDashboard == true && tag.typeID != 2003{
                dashboardTags.append(tag)
            }
            
            if tag.tagID == 3000 {
                browseLibraryHardcodedtag = tag
            }
        }
        
        if dashboardTags.count > 0 {
            if let tag = browseLibraryHardcodedtag {
                dashboardTags.insert(tag, at: 1)
            }
        }
        
        KLTManager.sharedInstance.kltLibrariesData = libraryTags
        KLTManager.sharedInstance.kltTagsData = searchableTags
        KLTManager.sharedInstance.kltBrandsData = brandsTags
        KLTManager.sharedInstance.kltPromotionsData = promotionsTags
        KLTManager.sharedInstance.kltCalendarData = calendarTags
        KLTManager.sharedInstance.kltCategoriesData = categoryTags
        KLTManager.sharedInstance.dashboardSections = dashboardTags
        KLTManager.sharedInstance.calendarTags = calendarTags
        
    }
    
    func urlFromDocDirectory(item: Item) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var fileName = String()//
        switch item.itemType! {
        case .video:
            fileName = "\(item.id!).mp4"
        case .pdf:
            fileName = "\(item.id!).pdf"
        case .product:
            fileName = "\(item.id!).jpg"
        default:
            fileName = "\(item.id!).mp4"
        }
        return documentsURL.appendingPathComponent(fileName)
    }
    
    
    func urlFromDocDirectory(itemLocation: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent(itemLocation)
    }
    
    func saveToFile(fileName: String, json: JSON) {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
        
        do {
            let jsonData = try json.rawData()
            try jsonData.write(to:fileURL)
        } catch {
            print(error)
        }
    }
    
    func downloadItemMedia(itemArray: Array<Item>) {
        
        var didPopup = false
        
        for item in itemArray {
            if item.itemType != .other {
                
                //check if item has been modified
                if item.modifiedDate != nil {
                    if itemHasBeenModified(item: item) {
                        kltMediaBase?.deleteItemThumbnailFromLocalStore(item: item)
                        kltMediaBase?.deleteItemMediaFromLocalStore(item: item)
                    }
                }
                
                //Download video or pdf
                if !kltMediaBase!.isItemDownloaded(item: item) {
                    if item.isFileOver100mbs! && !KLTManager.sharedInstance.reachability.isReachableViaWiFi {
                        if KLTManager.sharedInstance.isAllowedToDownloadOver100mbs {
                            KLTMediaDownloader.sharedInstance.addItemToDownloadQueue(item: item)
                        }
                        else {
                            //Do something here to stop download
                            //FIXME: -
                            if !didPopup {
                                UIViewController.top?.showErrorAlert(message: "By default large files will only be downloaded over wifi. Please change your settings if you would like to continue to download over cellular connection.")
                                didPopup = true
                            }
                        }
                    }
                    else {
                        KLTMediaDownloader.sharedInstance.addItemToDownloadQueue(item: item)
                    }
                }
                
                if !kltMediaBase!.isThumbnailDownloaded(item: item) {
                    if let _ = item.thumbnail {
                        KLTMediaDownloader.sharedInstance.addThumbnailToDownloadQueue(item: item)
                    }
                }
            }
        }
        //Check and delete expired items
        kltMediaBase!.checkForItemDeletionFromLocalStore(items: itemArray)
        kltMediaBase!.checkForThumbnailDeletionFromLocalStore(items: itemArray)
    }
    
    func downloadTagsThumbnails(tags: Array<Tag>) {
        for tag in tags {
            
            if tag.modifiedDate != nil {
                if tagHasBeenModified(tag: tag) {
                    kltMediaBase?.deleteTagFromLocalStore(tag: tag)
                }
            }
            
            if tag.iconMediaID != nil || tag.thumbMediaID != nil {
                if !kltMediaBase!.isTagThumbnailDownloaded(tag: tag) {
                    KLTMediaDownloader.sharedInstance.addTagThumbnailToDownloadQueue(tag: tag)
                }
            }
        }
        kltMediaBase!.checkForTagThumbnailDeletionFromLocalStore(tags: tags)
    }
    
    func tagHasBeenModified(tag: Tag) -> Bool {
        
        if let lastTagRefreshDate = UserDefaults.standard.string(forKey: "lastTagRefreshDate")  {
            let oldDate = Formatter.iso8601.date(from: lastTagRefreshDate)
            
            if let newDate = tag.modifiedDate {
                if oldDate != nil {
                    if oldDate! < newDate {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func itemHasBeenModified(item: Item) -> Bool {
        if let lastTagRefreshDate = UserDefaults.standard.string(forKey: "lastItemRefreshDate")  {
            let oldDate = Formatter.iso8601.date(from: lastTagRefreshDate)
            
            if let newDate = item.modifiedDate {
                if oldDate != nil {
                    if oldDate! < newDate {
                        return true
                    }
                }
            }
        }
        return false
    }
}
