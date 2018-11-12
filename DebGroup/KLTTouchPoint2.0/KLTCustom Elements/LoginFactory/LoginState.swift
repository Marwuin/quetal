//
//  LoginState.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 9/18/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

enum LoginStatus {
    case exists
    case verified
    case approved
    case active
}

class LoginState: NSObject {

    var loginStatus: LoginStatus?
    
    static let sharedState : LoginState = {
        let instance = LoginState()
        return instance
    }()
    
    
}
