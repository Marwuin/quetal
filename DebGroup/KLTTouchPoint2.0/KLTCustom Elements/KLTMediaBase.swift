//
//  KLTMediaBase.swift
//  OpenTab
//
//  Created by Raul Silva on 8/24/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import Foundation
import SQLite


class KLTMediaBase:NSObject{
    
    var db: Connection!

    let filePath = Bundle.path(forResource: "OpenTab", ofType: "db", inDirectory: "Resources")
    let media = Table("Media")
    let thumbnails = Table("Thumbnails")
    let tagThumbnails = Table("TagThumbnails")
    let mediaID = Expression<Int64>("MediaID")
    let fileUrl = Expression<String>("FileURL")
    let isTag = Expression<Int64>("IsTag")



    override init() {
        super.init()
        checkDataBase()
    }
    
    func checkDataBase() {
        let bundlePath = (frameworkBundle?.bundlePath)! + "/OpenTab.db"
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("OpenTab.db")
        let fullDestPathString = fullDestPath!.path
//        print(fileManager.fileExists(atPath: bundlePath)) // prints true
        if fileManager.fileExists(atPath: fullDestPathString) {
//            print("File is available")
            try! db = Connection(fullDestPathString)
        }
        else{
            do{
                try fileManager.copyItem(atPath: bundlePath, toPath: fullDestPathString)
                print("DB copied to path")
                try! db = Connection(fullDestPathString)

            }
            catch{
                print("\n")
                print("could not read or write db to documents directory. reverting to bundle ")
                db = try! Connection((frameworkBundle?.bundlePath)! + "/OpenTab.db")
            }
        }
    }

}

//Items
extension KLTMediaBase {
    func isItemDownloaded(item: Item) -> Bool {
        let count = try? db.scalar(media.filter(mediaID == Int64(item.id!)).count)
        
        if count != 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func checkForItemDeletionFromLocalStore(items: Array<Item>) {
        
        var itemIDsRetrieved: Array<Int> = Array()
        for item in items {
            itemIDsRetrieved.append(item.id!)
        }
        
        for mediaItem in try! db.prepare(media){
            
            
            if !itemIDsRetrieved.contains(Int(mediaItem[mediaID])) {
                
                
                let url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: mediaItem[fileUrl])
                
                let fileManager = FileManager.default
                
                do {
                    try fileManager.removeItem(at: url)
                } catch let error as NSError {
                    print(error.debugDescription)
                }
                
                let target = media.filter(mediaID == mediaItem[mediaID])
                do {
                    if try db.run(target.delete()) > 0 {
                        print("deleted target")
                    } else {
                        print("target not found")
                    }
                } catch {
                    print("delete failed: \(error)")
                }
                
            }
        }
    }
    
    func deleteItemMediaFromLocalStore(item: Item) {
        
        for mediaItem in try! db.prepare(media) {
            if  item.id == Int(mediaItem[mediaID]) {
                let url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: mediaItem[fileUrl])
                
                let fileManager = FileManager.default
                
                do {
                    try fileManager.removeItem(at: url)
                } catch let error as NSError {
                    print(error.debugDescription)
                }
                
                let target = media.filter(mediaID == mediaItem[mediaID])
                do {
                    if try db.run(target.delete()) > 0 {
                        print("deleted target")
                    } else {
                        print("target not found")
                    }
                } catch {
                    print("delete failed: \(error)")
                }
            }
        }
        
    }
    
    
    func addDownloadedItemToTable(item:Item, fileURL: String) {
        let count = try? db.scalar(media.filter(mediaID == Int64(item.id!)).count)
        if(count == 0){// This item is not on the DB, lets add it
            let insert = media.insert(or: .replace,mediaID <- Int64(item.id!), fileUrl <- fileURL)
            _ = try? db.run(insert)
        }
    }
}

//Thumbnails
extension KLTMediaBase {
    
    func isThumbnailDownloaded(item: Item) -> Bool {
        let count = try? db.scalar(thumbnails.filter(mediaID == Int64(item.id!)).count)
        
        if count != 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func checkForThumbnailDeletionFromLocalStore(items: Array<Item>) {
        
        var itemIDsRetrieved: Array<Int> = Array()
        for item in items {
            itemIDsRetrieved.append(item.id!)
        }
        
        for mediaItem in try! db.prepare(thumbnails){
            if !itemIDsRetrieved.contains(Int(mediaItem[mediaID])) {
                
                
                let url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: mediaItem[fileUrl])
                
                let fileManager = FileManager.default
                
                do {
                    try fileManager.removeItem(at: url)
                } catch let error as NSError {
                    print(error.debugDescription)
                }
                
                let target = thumbnails.filter(mediaID == mediaItem[mediaID])
                do {
                    if try db.run(target.delete()) > 0 {
                        print("deleted target")
                    } else {
                        print("target not found")
                    }
                } catch {
                    print("delete failed: \(error)")
                }
                
            }
        }
    }
    
    func deleteItemThumbnailFromLocalStore(item: Item) {
        
        let imageCache = UIImageView.af_sharedImageDownloader.imageCache
        _ = imageCache?.removeAllImages()
        UIImageView.af_sharedImageDownloader.sessionManager.session.configuration.urlCache?.removeAllCachedResponses()
        
            for mediaItem in try! db.prepare(thumbnails) {
                if  item.id == Int(mediaItem[mediaID]) {
                    let url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: mediaItem[fileUrl])
                    
                    let fileManager = FileManager.default
                    
                    do {
                        try fileManager.removeItem(at: url)
                    } catch let error as NSError {
                        print(error.debugDescription)
                    }
                    
                    let target = thumbnails.filter(mediaID == mediaItem[mediaID])
                    do {
                        if try db.run(target.delete()) > 0 {
                            print("deleted target")
                        } else {
                            print("target not found")
                        }
                    } catch {
                        print("delete failed: \(error)")
                    }
                }
            }
        
    }
    
    func addDownloadedThumnailToTable(item:Item, fileURL: String) {
        let count = try? db.scalar(thumbnails.filter(mediaID == Int64(item.id!)).count)
        if(count == 0){// This item is not on the DB, lets add it
            let insert = thumbnails.insert(or: .replace,mediaID <- Int64(item.id!), fileUrl <- fileURL)
            _ = try? db.run(insert)
        }
    }

}

//tags
extension KLTMediaBase {
    func isTagThumbnailDownloaded(tag: Tag) -> Bool {
        var count = 0
        
        if tag.iconMediaID != nil || tag.thumbMediaID != nil {
            if let tagMediaId = tag.iconMediaID {
                let x = try! db.scalar(tagThumbnails.filter(mediaID == Int64(tagMediaId)).count)
                count = count + x
            }
            if let tagThumbID = tag.thumbMediaID {
                let x = try! db.scalar(tagThumbnails.filter(mediaID == Int64(tagThumbID)).count)
                count = count + x
            }
            if count != 0 {
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
    
    
    
    func checkForTagThumbnailDeletionFromLocalStore(tags: Array<Tag>) {
        
        var itemIDsRetrieved: Array<Int> = Array()
        for tag in tags {
            if let tagMediaId = tag.iconMediaID {
                itemIDsRetrieved.append(tagMediaId)
            }
            if let tagThumbID = tag.thumbMediaID {
                itemIDsRetrieved.append(tagThumbID)
            }
        }
        
        for mediaItem in try! db.prepare(tagThumbnails){
            
            
            if !itemIDsRetrieved.contains(Int(mediaItem[mediaID])) {
                
                
                let url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: mediaItem[fileUrl])
                
                let fileManager = FileManager.default
                
                do {
                    try fileManager.removeItem(at: url)
                } catch let error as NSError {
                    print(error.debugDescription)
                }
                
                let target = tagThumbnails.filter(mediaID == mediaItem[mediaID])
                do {
                    if try db.run(target.delete()) > 0 {
                        print("deleted target")
                    } else {
                        print("target not found")
                    }
                } catch {
                    print("delete failed: \(error)")
                }
                
            }
        }
    }
    
    func deleteTagFromLocalStore(tag: Tag) {
        if tag.iconMediaID != nil || tag.thumbMediaID != nil {
            var tagID: Int?
            if let tagMediaId = tag.iconMediaID {
                tagID = tagMediaId
            }
            if let tagThumbID = tag.thumbMediaID {
                tagID = tagThumbID
            }
            
            let imageCache = UIImageView.af_sharedImageDownloader.imageCache
            _ = imageCache?.removeAllImages()
            UIImageView.af_sharedImageDownloader.sessionManager.session.configuration.urlCache?.removeAllCachedResponses()
            
            for mediaItem in try! db.prepare(tagThumbnails) {
                if tagID == Int(mediaItem[mediaID]) {
                    let url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: mediaItem[fileUrl])
                    
                    let fileManager = FileManager.default
                    
                    do {
                        try fileManager.removeItem(at: url)
                    } catch let error as NSError {
                        print(error.debugDescription)
                    }
                    
                    let target = tagThumbnails.filter(mediaID == mediaItem[mediaID])
                    do {
                        if try db.run(target.delete()) > 0 {
                            print("deleted target")
                        } else {
                            print("target not found")
                        }
                    } catch {
                        print("delete failed: \(error)")
                    }
                }
            }
        }
    }
    
    func addDownloadedTagThumnailToTable(tag:Tag, fileURL: String) {
        var count = 0
        var isIcon: Bool?
        
        if let _ = tag.iconMediaID {
            let x = try! db.scalar(tagThumbnails.filter(mediaID == Int64(tag.iconMediaID!)).count)
            count = count + x
            isIcon = true
        }
        if let _ = tag.thumbMediaID {
            let x = try! db.scalar(tagThumbnails.filter(mediaID == Int64(tag.thumbMediaID!)).count)
            count = count + x
            isIcon = false
        }
        
        if(count == 0){// This item is not on the DB, lets add it
            let id = isIcon! ?  tag.iconMediaID! : tag.thumbMediaID!
            let insert = tagThumbnails.insert(or: .replace,mediaID <- Int64(id), fileUrl <- fileURL)
            _ = try? db.run(insert)
        }
    }
}
