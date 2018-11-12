//
//  KLTManager.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/15/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON
import KeychainAccess
import Reachability


public class KLTManager: NSObject {
    
    static let sharedInstance : KLTManager = {
        let instance = KLTManager()
        return instance
    }()
    
    public var tags: Array<String>?
    
    var keychain = Keychain(service: frameworkBundleIdentifier)
    
   static var pushtoken = "0000"
   static var deviceID: String?
    
    var guid: String?
    var token: String?
    var tokenExpiration: Date?
    var currentUser: User?
    var mailbagItems = [Int]()
    var dashboardSections: Array<Tag> = Array()
    var calendarTags: Array<Tag> = Array()
    var lastItemsPullDate: Date?
    var networkConnectionAvailable: Bool?

    var reachability = Reachability()!
    var kltItemsData = [Item]()
    var kltArticlesData = [Item]()
    var kltTagsData = [Tag]()
    var kltBrandsData = [Tag]()
    var kltPromotionsData = [Tag]()
    var kltCalendarData = [Tag]()
    var kltLibrariesData = [Tag]()
    var kltCategoriesData = [Tag]()
    
    var selectedTags = [Int]()
    
    var businessUnitsData: BusinessUnitsData?
    
    var isAllowedToDownloadOver100mbs: Bool {
        if  UserDefaults.standard.object(forKey: "sizeLimit") != nil {
            return UserDefaults.standard.bool(forKey: "sizeLimit")
        }
        else {
            return false
        }
    }

   

    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: Notification.Name.reachabilityChanged,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        reachability = note.object as! Reachability
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                networkConnectionAvailable = true
            }
            else {
                networkConnectionAvailable = true
                print("Reachable via Cellular")
            }
        }
        else {
            networkConnectionAvailable = false
            print("Network not reachable")
        }
    }
    
    public class func didRecieveRemoteNotification(aps: [String: AnyObject]) {
        // handle recieved data
        print(aps)
    }
    
    public class func setPushToken(token:String) {
        print("MY PUSH TOKEN IS:\(token)")
        self.pushtoken = token
    }
    
    public class func setDeviceID(id:String) {
        print("MY DEVICE ID IS:\(id)")

        self.deviceID = id
    }

}

//Favorite management
extension KLTManager {
    func favoriteItem(item: Item, completion: @escaping (_ success: Bool) -> Void) {
        let request = KLTMediaRequests.init()
        request.favorite(itemID: item.id!, completion: { (success, error) -> Void in
            if success {
                item.isFavorite = true
            }
            else {
                UIViewController.top?.showErrorAlert(message: "Could not favorite at this time.\n Please try again.")
            }
            completion(success)
        })
    }
    
    func unfavoriteItem(item: Item, completion: @escaping (_ success: Bool) -> Void) {
        let request = KLTMediaRequests.init()
        request.unfavorite(itemID: item.id!, completion: { (success, error) -> Void in
            if success {
                item.isFavorite = false
            }
            else {
                UIViewController.top?.showErrorAlert(message: "Could not favorite at this time.\n Please try again.")
            }
            completion(success)
        })
    }
    
    //Profile  management
    func saveProfile(profile: [Int], completion: @escaping (_ success: Bool) -> Void) {
        let request = KLTUserRequests.init()
        request.saveProfile(profile: profile, completion: { (success, error) -> Void in
            if success {
               
            }
            else {
                UIViewController.top?.showErrorAlert(message: "Could not save your profile at this time")
            }
            completion(success)
        })
    }
}
