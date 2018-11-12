//
//  BusinessUnitsData.swift
//  OpenTab
//
//  Created by Raul Silva on 7/19/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import Foundation
import SwiftyJSON

class BusinessUnitsData:NSObject{
    
    init(json:JSON) {
       data = json
    }
        
    var data:JSON?
    var managers:[[String:Any]]?
    var managerAreas:[[String:Any]]?
    var businessUnitAreas:[[String:Any]]?

}
