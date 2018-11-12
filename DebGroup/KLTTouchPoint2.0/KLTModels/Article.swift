//
//  Article.swift
//  KLTTouchPoint2.0
//
//  Created by Sameer Siddiqui on 3/9/18.
//  Copyright © 2018 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON


class Article: NSObject {

    fileprivate var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    var articleText: String? {
        if let text = self.json["ArticleText"].string {
            return text
        }
        else {
            return nil
        }
    }    
}
