//
//  MediaList.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/22/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class MediaList: NSObject {

    let endpoint = "/MediaList"
    
    func getMediaList() {
        let client = KLTClientServices.init()
        client.getRequest(with: endpoint, parameters: ["string": "string"]) { (response) in
            
        }
    }
    
}
