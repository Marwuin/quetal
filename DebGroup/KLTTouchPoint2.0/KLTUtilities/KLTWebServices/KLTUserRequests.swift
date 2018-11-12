//
//
//  KLTUserRequests.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/22/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTUserRequests: NSObject {
    
    enum UserEndpoints: String {
        case create = "Create/"
        case validateEmail = "Exists/"
        case token = "Token"
        case resetWithEmail = "Password/Reset/Request/Email/"
        case verifyCodeEmail = "Password/Reset/Verify/Email/"
        case verifyCodePhone = "Password/Reset/Verify/Phone/"
        case updatePasswordEmail = "Password/Reset/Email/"
        case saveProfile = "Tag/"
        case verifyCell = "VerifyCell/"
        case updateUser = "/Update/"
    }
    
    let endpoint = "/api/v1/User/"
}


//MARK: - Account Creation
extension KLTUserRequests {
    /// Creates an account for the user.
    ///
    /// - completion: returns a success boolean and/or an error.
    
    func createAccount(email: String, password: String, firstName: String, lastName: String, completion: @escaping (_ success: Bool,_ error: Error?) -> Void) {
        
        let parameters = ["Email" : email, "Password" : password, "FirstName" : firstName, "LastName" : lastName, "ClientID" : "1"]
        
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint + UserEndpoints.create.rawValue, parameters: parameters) { (response) in
            if response.json != nil {
                completion(true, nil)
            }
            else {
                print("did recieve error \(response.error!)")
                completion(false, response.error!)
            }
        }
    }
    
    /// Creates an account for an existing user.
    ///
    /// - completion: returns a success boolean and/or an error.
    
    func updateAccount(email: String, password: String, firstName: String, lastName: String, completion: @escaping (_ success: Bool,_ error: Error?) -> Void) {
        
        let parameters = ["Email" : email, "Password" : password, "FirstName" : firstName, "LastName" : lastName, "ClientID" : "1"]
        
        let client = KLTClientServices.init()
        client.putRequest(with: endpoint + KLTManager.sharedInstance.guid!, parameters: parameters) { (response) in
            if response.json != nil {
                completion(true, nil)
            }
            else {
                print("did recieve error \(response.error!)")
                completion(false, response.error!)
            }
        }
    }
    
    func validateEmail(email: String, completion: @escaping (_ success: Bool, _ userExists: Bool?, _ isActive: Bool?, _ isRegistered: Bool?, _ isVerified: Bool?, _ isApproved: Bool?, _ error: CustomError?) -> Void) {
        if email.contains("@cbrands.com") {
            UserDefaults.standard.set("1", forKey: "roleID")
        }
        else {
            UserDefaults.standard.set("3", forKey: "roleID")
        }
        let parameters = ["grant_type" : "password", "Email" : email]
        let client = KLTClientServices.init()
        
        client.postRequest(with: endpoint + UserEndpoints.validateEmail.rawValue, parameters: parameters) { (response) in
            if let result = response.json {
                
                var userExists: Bool = false
                var isActive: Bool = false
                var isRegistered: Bool = false
                var isVerified: Bool = false
                var isApproved: Bool = false
                
                if result["Exists"].boolValue == true {
                    userExists = true
                }
                
                if result["IsActive"].boolValue == true {
                    isActive = true
                }
                
                if result["IsVerified"].boolValue == true {
                    isVerified = true
                }
                
                if let status = result["StatusID"].int {
                    switch status {
                    case 3001:
                        isApproved = true
                        isRegistered = true
                    case 3000:
                        isRegistered = false
                        isApproved = false
                    case 3002:
                        isRegistered = true
                        isApproved = false
                    default:
                        break
                    }
                    
                }
                
                if let guid = result["Guid"].string {
                    KLTManager.sharedInstance.guid = guid
                }
                
                completion(true, userExists, isActive, isRegistered, isVerified, isApproved, nil)
                
            }
            else {
                print("did recieve error \(response.error!)")
                completion(false, false,false, false, false, false, response.error)
            }
        }
    }
    
    
    /// Gets a token for authorization for the user. Token is to be appended to all subsequent call if it exists
    ///
    /// - completion: returns a token and/or an error.
    
    func isTokenExpired() -> Bool{
        let timeInterval = Double(KLTManager.sharedInstance.keychain["expires_in"]!)
        let creationDate = KLTManager.sharedInstance.keychain[attributes: "token"]?.creationDate
        let expirationDate = Date(timeInterval: timeInterval!, since: creationDate!)
        if(Date() > expirationDate){
            return true
        }
        else{
            return false
        }
    }
    
    /// Verify pin number
    ///
    /// - completion: returns a success boolean and/or an error
    
    func verifyPin(pin: String, completion: @escaping ( _ success: Bool?, _ error: Error?) -> Void ) {
        let parameters = ["Code": pin]
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint + "\(KLTManager.sharedInstance.guid!)/"+UserEndpoints.verifyCell.rawValue, parameters: parameters) { (response) in

            if response.statusCode == 200 {
                completion(true, nil)
            }
            else {
                completion(false, response.error)
            }
        }
    }
    
    func getToken(username: String, password: String, completion: @escaping (_ expiresIn:String?, _ token: String?, _ error: CustomError?) -> Void) {
        
        let parameters = ["grant_type" : "password", "username" : username, "password" : password]
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint + UserEndpoints.token.rawValue, parameters: parameters) { (response) in
            if let result = response.json {
                print(result["expires_in"])
                if let token = result["access_token"].string {
                    let expiresIn = String(describing: result["expires_in"])
                    completion(expiresIn, token, nil)
                }
            }
            else {
                print("did recieve error \(response.error!)")
                completion(nil, nil, response.error)
            }
        }
    }
    
}

//MARK: - Account Actions
extension KLTUserRequests {
    
    /// Get User Info
    ///
    /// - completion: returns a user object and/or error
    
    func getUser(completion: @escaping (_ success: Bool?, _ error: Error?) -> Void) {
        let client = KLTClientServices.init()
        
        if KLTManager.pushtoken != "0000"{
            let parameters = ["DeviceID" : KLTManager.deviceID!, "PushToken" : KLTManager.pushtoken, "PlatformID":"24"]
            print("getUser -> DeviceID: \(KLTManager.deviceID!), PushToken: \(KLTManager.pushtoken), PlatformID: 24")
            client.putRequest(with: endpoint, parameters: parameters) { (response) in
                if response.json != nil {
                    //Got Fresh User
                    KLTDownloadManager.sharedInstance.saveToFile(fileName: "UserData.json", json: response.json!)
                    completion(true, nil)

                }
                else if response.error != nil {
                    completion(false, response.error!)
                }
            }
        }
        else{
           client.getRequest(with: endpoint, parameters: nil) { (response) in
                if response.json != nil {
                    //Got Fresh User
                    KLTDownloadManager.sharedInstance.saveToFile(fileName: "UserData.json", json: response.json!)
                    completion(true, nil)
                }
                else if response.error != nil {
                    completion(false, response.error!)
                }
            }
        }
    }
    
    
    
}
//MARK: - Profile update
extension KLTUserRequests {
    
    func saveProfile(profile:[Int], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let request = KLTClientServices.init()
        let parameters: [String : Any] = ["Tags" : profile]
        request.putRequest(with: endpoint + UserEndpoints.saveProfile.rawValue, parameters: parameters) { (response) in
            if response.json != nil {
                completion(true, nil)
            }
            else {
                completion(false, response.error)
            }
        }
    }
    
    func saveProfilewithGuid(profile:[Int], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let request = KLTClientServices.init()
        let parameters: [String : Any] = ["Tags" : profile]
        request.putRequest(with: endpoint + "\(KLTManager.sharedInstance.guid!)/" + UserEndpoints.saveProfile.rawValue, parameters: parameters) { (response) in
            if response.json != nil {
                completion(true, nil)
            }
            else {
                completion(false, response.error)
            }
        }
    }
}

//MARK: - Password reset
extension KLTUserRequests {
    
    /// Resets Password with Email
    ///
    /// - completion: returns a success boolean and/or an error.
    
    func resetPassword(email: String, completion: @escaping (_ success: Bool?, _ error: Error?) -> Void) {
        let parameters = ["Email" : email]
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint + UserEndpoints.resetWithEmail.rawValue, parameters: parameters) { (response) in
            
            if response.json != nil {
                completion(true, nil)
            }
            else {
                completion(false, response.error!)
            }
        }
    }
    
    /// Verify code with email
    ///
    /// - completion: returns a success boolean and/or an error.
    
    func verifyCode(email: String, sentCode: String, completion: @escaping (_ success: Bool?, _ error: Error?) -> Void) {
        let parameters = ["Email" : email, "SentCode" : sentCode]
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint + UserEndpoints.verifyCodeEmail.rawValue, parameters: parameters) { (response) in
            
            if response.json != nil {
                completion(true, nil)
            }
            else {
                completion(false, response.error!)
            }
        }
    }
    
    /// Update Password with email
    ///
    /// - completion: returns a success boolean and/or an error.
    
    func updatePassword(email: String, appCode: String, password: String, completion: @escaping (_ success: Bool?, _ error: Error?) -> Void) {
        let parameters = ["Email" : email, "AppCode" : appCode, "Password" : password]
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint + UserEndpoints.updatePasswordEmail.rawValue, parameters: parameters) { (response) in
            
            if response.json != nil {
                completion(true, nil)
            }
            else {
                completion(false, response.error!)
            }
        }
    }
}


