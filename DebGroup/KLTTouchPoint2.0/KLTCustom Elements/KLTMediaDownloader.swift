//
//  KLTMediaDownloader.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 8/30/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import Alamofire

enum DownloadType {
    case item
    case thumbnail
    case tag
}

public class KLTMediaDownloader: NSObject {

    public let downloadQueue = TaskQueue()
    
    public static let sharedInstance : KLTMediaDownloader = {
        let instance = KLTMediaDownloader()
        return instance
    }()
    
    private lazy var sessionManager: SessionManager = {
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "openTab.background")
        
        //Default timeout
        configuration.timeoutIntervalForRequest = 10
        
        var manager = Alamofire.SessionManager(configuration: configuration)
        
        return manager
    }()

    public var backgroundCompletionHandler: (() -> Void)? {
        get {
            return sessionManager.backgroundCompletionHandler
        }
        set {
            sessionManager.backgroundCompletionHandler = newValue
        }
    }
    

    func addItemToDownloadQueue(item:Item) {
        var cnt = 0
        downloadQueue.tasks +=~ {[weak downloadQueue] result, next in
            cnt = cnt + 1
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
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                let fileURL = documentsURL.appendingPathComponent(fileName)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            if let url = item.url {
                self.sessionManager.download(url, to: destination).response { response in
                    if response.error == nil, let filePath = response.destinationURL?.path {
                        print("Download Succeeded ::::: FILEPATH: \(filePath)")
                        //Download Succeeded
                        kltMediaBase!.addDownloadedItemToTable(item: item, fileURL: fileName)
                        next(nil)
                    }
                    else {
                        //Download Failed
                        if cnt > 3 {
                            print("Download Failed 3 times::::: Aborting \(item.id!)")
                            next(nil)
                        } else {
                            print("Download Failed ::::: Retrying \(item.id!)")
                            downloadQueue!.retry(1)
                        }
                    }
                }
            }
        }
        downloadQueue.run()
    }
    
    func addThumbnailToDownloadQueue(item:Item) {
        var cnt = 0
        downloadQueue.tasks +=~ {[weak downloadQueue] result, next in
            
            cnt = cnt + 1
            
            let fileName = "thumbnail_\(item.id!).jpg"
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                let fileURL = documentsURL.appendingPathComponent(fileName)
                
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            if let thumbnail = item.thumbnail {
                self.sessionManager.download(thumbnail, to: destination).response { response in
                    
                    
                    if response.error == nil, let filePath = response.destinationURL?.path {
                        print("Download Succeeded ::::: FILEPATH: \(filePath)")
                        //Download Succeeded
                        kltMediaBase!.addDownloadedThumnailToTable(item: item, fileURL: fileName)
                        next(nil)
                    }
                    else {
                        //Download Failed
                        if cnt > 3 {
                            print("Download Failed 3 times::::: Aborting \(item.id!)")
                            next(nil)
                        } else {
                            print("Download Failed ::::: Retrying \(item.id!)")
                            downloadQueue!.retry(1)
                        }
                    }
                }
            }
            
            
        }
        downloadQueue.run()
    }
    
    func addTagThumbnailToDownloadQueue(tag:Tag) {
        var cnt = 0
        downloadQueue.tasks +=~ {[weak downloadQueue] result, next in

            cnt = cnt + 1
            var isIcon: Bool?
            if let _ = tag.iconMediaID {
                isIcon = true
            }
            if let _ = tag.thumbMediaID {
                isIcon = false
            }
            let id = isIcon! ?  tag.iconMediaID! : tag.thumbMediaID!


            let fileName = "thumbnail_\(id).jpg"

            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

                let fileURL = documentsURL.appendingPathComponent(fileName)

                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }

            self.sessionManager.download((isIcon! ? tag.iconURL : tag.thumbnail)!, to: destination).response { response in
    

                if response.error == nil, let filePath = response.destinationURL?.path {
                    print("Download Succeeded ::::: FILEPATH: \(filePath)")
                    //Download Succeeded
                    //                    kltMediaBase!.addDownloadedItemToTable(item: item, fileURL: fileName)
//                    kltMediaBase!.addDownloadedThumnailToTable(item: item, fileURL: fileName)
                    kltMediaBase!.addDownloadedTagThumnailToTable(tag: tag, fileURL: fileName)
                    next(nil)
                }
                else {
                    //Download Failed
                    if cnt > 3 {
                        print("Download Failed 3 times::::: Aborting \((isIcon! ? tag.iconURL : tag.thumbnail)!)")
                        next(nil)
                    } else {
                        print("Download Failed ::::: Retrying \((isIcon! ? tag.iconURL : tag.thumbnail)!)")
                        downloadQueue!.retry(1)
                    }
                }
            }
        }
        downloadQueue.run()
    }
    
}
