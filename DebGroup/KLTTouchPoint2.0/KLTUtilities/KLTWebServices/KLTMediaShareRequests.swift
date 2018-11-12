//
//  KLTMediaShareRequests.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 9/5/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTMediaShareRequests: NSObject {

    let endpoint = "/api/v1/Media/Share/"

    /// Shares media to specified recipients with a custom message
    ///
    /// - completion: returns a success boolean
    
    func shareMedia(recipients: Array<String>, message: String, ItemIDs: Array<Int>, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        let recipientString = recipients.joined(separator: ",")
        
        let parameters: [String : Any] = ["Recipient" : recipientString, "Message" : message, "Media" : ItemIDs]
        
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint, parameters: parameters) { (response) in
            if response.json != nil {
                completion(true, nil)
            }
            else if response.error != nil {
                completion(false, response.error)
            }
        }
        
    }
    
    
    
}
