//
//  KLTanalytics.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 8/10/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import Foundation

class KLTReportItem:NSObject{
    var ID:Int?
    var typeID:Int?
    var itemDescription:String?
    
    init(withID ID:Int, andTypeID typeID:Int, andDescription itemDescription:String) {
        self.ID = ID
        self.typeID = typeID
        self.itemDescription = itemDescription
            super.init()
    }
}

class KLTAnalytics:NSObject{
    var useReports = [KLTReportItem]()

    override init() {
          super.init()
        
     NotificationCenter.default.addObserver(self, selector: #selector(self.addItem(notification:)), name: Notification.Name("addItemToAnalytics"), object: nil)
    }
    
    func processQueue(){
        for item in useReports{
            //process queue item
        }
    }
    
    func addItem(notification:Notification) {
        
    }
}
