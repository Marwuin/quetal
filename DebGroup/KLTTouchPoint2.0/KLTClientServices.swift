//
//  KLTClientServices.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/15/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import Alamofire

enum Service: String {
    case prod = "http://www.google.com/"
    case qa   = "https://www.google.com/"
}

enum Endpoint: String {
    case mediaList = "GetMediaList"
}


class KLTClientServices: NSObject {

    func getRequest(with endpoint:Endpoint, completion: @escaping (_ responseJSON: Any?) -> Void) {
        Alamofire.request("\(Service.prod)+\(endpoint)").responseJSON { (response) in
            if let json = response.result.value {
                print("JSON: \(json)")
                completion(json)
            }
            
        }
    }
}
