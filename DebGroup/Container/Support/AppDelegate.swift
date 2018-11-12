//
//  AppDelegate.swift
//  OpenTab
//
//  Created by Raul Silva on 6/22/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import UserNotifications
import KLTTouchPoint2_0
import IQKeyboardManagerSwift
import Fabric
import Crashlytics

//var testCrash: Bool?

var pushToken = "0000000"    //Device push token ID for Apple Notification Services
var vendorID  =  String()   //Unique identifier for the push notification service

struct Platform {
    static let isSimulator: Bool = {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }()
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//      self.printFonts()

        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
      
       
        vendorID = UIDevice.current.identifierForVendor!.uuidString
        debugPrint("Vendor ID: \(vendorID)")
        KLTManager.setDeviceID(id: vendorID)
        
        let content = UNMutableNotificationContent()
        content.badge = 0
      
        
        // Check if launched from notification
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String: AnyObject]
            print(aps)
            
            KLTManager.didRecieveRemoteNotification(aps:aps)
        }
        
        IQKeyboardManager.sharedManager().enable = true
        //Fabric.with([Crashlytics.self])

        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
//        let seomthing = testCrash!
//        print(seomthing)
        return true
    }

    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        debugPrint("APNs registration failed: \(error)")
        
        if Platform.isSimulator {
            pushToken = "674341049900B2E3B06933F31E63ED6CB35DBB4E718BD7C12D5E62524D644A77"
            debugPrint("We are running on the simulator, using a dummy token")
        }
        else {
            // Do the other
        }
        

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("APP ENTERED BACKGROUND")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //fetch new data in background
        print("GETTING NEW DATA IN BACKGROUND !!!!!!")
        KLTDownloadManager.sharedInstance.downloadAllData { (success) in
            completionHandler(.newData)
        }
    }


}
// MARK:- Push Notifications 
extension AppDelegate {
   
    //Register to push notificaitons
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    //Get users push notifications settings
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    //user did register for push notifications
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        
        let debugProdKey = Bundle.main.object(forInfoDictionaryKey:"IsDebugProd") as! String
        
        let isDebugProd = debugProdKey == "YES" ? true : false
        
        if !isDebugProd {
            print("NOT In DebugProd")
            KLTManager.setPushToken(token:token)
        }
        
        print(token)
    }
    
    //user did recieve remote notification
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        print(aps)
        KLTManager.didRecieveRemoteNotification(aps:aps)
        
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        if KLTMediaDownloader.sharedInstance.downloadQueue.tasks.count > 0 {
            KLTMediaDownloader.sharedInstance.downloadQueue.run()
            print("Continue running download tasks !!!!")
        }
        else {
            print("Download tasks done!!!!")
            KLTMediaDownloader.sharedInstance.backgroundCompletionHandler = completionHandler
        }
    }
    
}


// MARK:- Methods
extension AppDelegate {
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
}

