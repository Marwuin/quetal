//
//  KLTMessages.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 10/3/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import Foundation
import SwiftMessages

class KLTMessages:NSObject{
    
 class func displaySuccess(withTitle title:String, andMessage message:String){
        let view = MessageView.viewFromNib(layout: .cardView)
        var config = SwiftMessages.Config()
        config.preferredStatusBarStyle = .lightContent
        view.configureDropShadow()
        view.configureTheme(.success)
        view.configureTheme(backgroundColor: UIColor(red: 20.0/255.0, green: 59.0/255.0, blue: 105.0/255.0, alpha: 1.0), foregroundColor: UIColor.white)
        view.tintColor = UIColor(red: 20.0/255.0, green: 59.0/255.0, blue: 105.0/255.0, alpha: 1.0)
        view.button?.isHidden = true
        view.configureContent(title: title, body: message)
        SwiftMessages.show(config:config, view: view)
    }
}
