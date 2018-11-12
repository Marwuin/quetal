//
//  KLTClientServices.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/15/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


protocol KLTClientError: Error {
    var localizedTitle: String { get }
    var localizedDescription: Dictionary<String, Any> { get }
    var code: Int { get }
}

struct CustomError: KLTClientError {
    var localizedTitle: String
    var localizedDescription: Dictionary<String, Any>
    var code: Int
    
    init(localizedTitle: String?, localizedDescription: Dictionary<String, Any>, code: Int) {
        self.localizedTitle = localizedTitle ?? "Error"
        self.localizedDescription = localizedDescription
        self.code = code
    }
}

struct KLTResponse {
    let json: JSON?
    let error: CustomError?
    let statusCode: Int?
}

class KLTClientServices: NSObject {
    
    let clientID = 1
    

    func getRequest(with endpoint:String, parameters: [String:Any], completion: @escaping (_ responseJSON: Any?) -> Void) {
        self.request(with: endpoint, method: .get, parameters: parameters) { (json) in
            completion(json)
        }
    }
    
    func request(with endpoint:String, method: HTTPMethod, parameters: [String:Any]?, completion: @escaping (_ response: KLTResponse) -> Void) {
        
        var headers: HTTPHeaders? = endpoint.contains("Token") ? [
            "Content-Type": "application/x-www-form-urlencoded"
            ] : nil
        
        if let token = KLTManager.sharedInstance.keychain["token"] {
            if headers != nil {
                headers?["Authorization"] = "Bearer " + token
            }
            else {
                headers = ["Authorization" : "Bearer " + token]
            }
        }
        
        if let _ = KLTManager.sharedInstance.keychain["expires_in"] {
            let request = KLTUserRequests.init()
            if request.isTokenExpired() {
                print("token is expired. kicking user out")
                self.logout()
            }
        }
        
        let encoding: ParameterEncoding = endpoint.contains("Token") ? URLEncoding.httpBody : JSONEncoding.default
        
        Alamofire.request(currentService + endpoint,  method: method, parameters : parameters, encoding: encoding, headers: headers).responseJSON { (response) in

            print("method: \(method), currentService \(currentService), endpoint: \(endpoint), parameters: \(parameters)")
            print(response.request)
            print(response.request?.httpBody)

            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                
                if response.response?.statusCode == 400 {
                    if let message = json["Message"].string {
                        let error = CustomError.init(localizedTitle: message, localizedDescription:json["ModelState"].dictionaryObject!, code: 400)
                        let result = KLTResponse.init(json: nil, error: error, statusCode: 400)
                        completion(result)
                    }
                    
                    if let errorMessage = json["error"].string {
                        let error = CustomError.init(localizedTitle: errorMessage, localizedDescription: ["error_description": json["error_description"]], code: 400)
                        let result = KLTResponse.init(json: nil, error: error, statusCode: 400)
                        completion(result)
                    }
                    
                }
                else if response.response?.statusCode == 200 {
                    let result = KLTResponse.init(json: json, error: nil, statusCode: 200)
                    completion(result)
                }
                else if  response.response?.statusCode == 401 {
                    let error = CustomError.init(localizedTitle: "Network error", localizedDescription:["error_description" : "Unauthorized"], code: 401)
                    let result = KLTResponse.init(json: nil, error: error, statusCode: 401)
                    self.logout()
                    KLTDownloadManager.sharedInstance.queue.cancel()
                    completion(result)
                }
                else {
                    let error = CustomError.init(localizedTitle: "Unknown Error in KLTRequest", localizedDescription: ["error_description":"error"], code: response.response!.statusCode)
                    let result = KLTResponse.init(json: nil, error: error, statusCode: response.response!.statusCode)
                    print("Error with status code : \(response.response!.statusCode)")
                    completion(result)
                }
                
            case .failure(let error):
                //200 with no response json
                if response.response?.statusCode == 200 {
                    let result = KLTResponse.init(json: nil, error: nil, statusCode: 200)
                    completion(result)
                }
                else if  response.response?.statusCode == 401 {
                    let error = CustomError.init(localizedTitle: "Network error", localizedDescription:["error_description" : "Unauthorized"], code: 401)
                    let result = KLTResponse.init(json: nil, error: error, statusCode: 401)
                    self.logout()
                    completion(result)
                }
                else {
                    
                    if let statusCode = response.response?.statusCode {
                        let error = CustomError.init(localizedTitle: "Network error", localizedDescription:["error_description" : error.localizedDescription], code: statusCode)
                        let result = KLTResponse.init(json: nil, error: error, statusCode: statusCode)
                        completion(result)
                    }
                    else {
                        let error = CustomError.init(localizedTitle: "Network error", localizedDescription:["error_description" : "No network connection"], code: 0)
                        let result = KLTResponse.init(json: nil, error: error, statusCode: 0)
                        completion(result)
                    }
                    
                }
            }
            
        }
    }
    
    func logout() {
        do {
            try KLTManager.sharedInstance.keychain.remove("token")
        } catch let error {
            print("error: \(error)")
        }
        do {
            try KLTManager.sharedInstance.keychain.remove("expires_in")
        } catch let error {
            print("error: \(error)")
        }
        do {
            try KLTManager.sharedInstance.keychain.remove("email")
        } catch let error {
            print("error: \(error)")
        }
        do {
            try KLTManager.sharedInstance.keychain.remove("password")
        } catch let error {
            print("error: \(error)")
        }
       
        KLTDownloadManager.sharedInstance.queue.cancel()
        KLTDownloadManager.sharedInstance.queue.removeAll()

        
//        let vc = KLTLogInViewController.create()
        let vc = KLTSplashViewController.create()
        let appDelegate = UIApplication.shared.delegate
        appDelegate!.window!?.rootViewController = vc
    }
    
}

extension KLTClientServices {
    
    func getRequest(with endpoint:String, parameters: [String:Any]?, completion: @escaping (_ response: KLTResponse) -> Void) {
        self.request(with: endpoint, method: .get, parameters: parameters) { (response) in
            completion(response)
        }
    }
    
    func postRequest(with endpoint:String, parameters: [String:Any]?, completion: @escaping (_ response: KLTResponse) -> Void) {
        self.request(with: endpoint, method: .post, parameters: parameters) { (response) in
            completion(response)
        }
    }
    
    func putRequest(with endpoint:String, parameters: [String:Any]?, completion: @escaping (_ response: KLTResponse) -> Void) {
        self.request(with: endpoint, method: .put, parameters: parameters) { (response) in
            completion(response)
        }
    }
    
    func deleteRequest(with endpoint:String, parameters: [String:Any]?, completion: @escaping (_ response: KLTResponse) -> Void) {
        self.request(with: endpoint, method: .delete, parameters: parameters) { (response) in
            completion(response)
        }
    }
}


