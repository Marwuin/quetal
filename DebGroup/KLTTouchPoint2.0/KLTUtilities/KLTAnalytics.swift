//
//  KLTanalytics.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 8/10/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import Foundation
import SwiftyJSON

class KLTAnalytics:NSObject{
    
    enum EventTypes:Int{
        case viewItem = 6004
        case filter = 6001
        case appEvent = 6000
    }
    
    fileprivate let analyticsQueue = TaskQueue()
    
    fileprivate static let sharedInstance : KLTAnalytics = {
        let instance = KLTAnalytics()
        return instance
    }()
    
    class func eventFired(type: EventTypes, id: Int? = nil, valueTypeID: Int? = nil, value: Int? = nil, eventDetails:JSON? = nil) {
        let endpoint = "/api/v1/User/Event/"
        let analyticsQueue = KLTAnalytics.sharedInstance.analyticsQueue
        var parameters = [String:Any]()
        analyticsQueue.tasks +=~ { result, next in
            switch type {
            case EventTypes.filter:
                var details:[[String:Int]] = [[String:Int]]()
                for detail in KLTManager.sharedInstance.selectedTags{
                    details.append(["ValueTypeID":1001,"ValueInt":detail])
                }
                parameters = ["TypeID":String(describing: type.rawValue),"EventDetails":details]
            case EventTypes.viewItem:
                parameters = ["TypeID":String( type.rawValue),"ValueTypeID":valueTypeID!,"ValueInt":value!]
            case EventTypes.appEvent:
                parameters = ["TypeID":String(describing: type.rawValue)]
            }
            
            let client = KLTClientServices.init()
            client.postRequest(with: endpoint, parameters: parameters) { (response) in
                if response.statusCode == 200 {
                    debugPrint("saved analytics event")
                }
                else {
                    debugPrint("could not save analytics event")
                }
            }
            next(nil)
        }
        
        if KLTManager.sharedInstance.reachability.isReachable {
            analyticsQueue.run()
        }
    }
}
