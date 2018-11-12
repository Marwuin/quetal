//
//  KLTLogInPasswordViewController.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 9/6/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTLogInPasswordViewController: UIViewController, UITextFieldDelegate {
    var readyToProceed: Bool = false

    @IBAction func forgotPassword(_ sender: UIButton) {
        self.readyToProceed = true
        self.performSegue(withIdentifier: "passToForgot", sender: nil)
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBAction func cancelPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "passToForgot"){
            let destiny = segue.destination as! KLTForgotPasswordViewController
            destiny.codeToVerify = "0000"
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {

        let endpoint = "/api/v1/User/Password/Reset/Request/Email/"
        let parameters:[String:String] = ["Email":KLTManager.sharedInstance.keychain["email"]!]
 
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint, parameters: parameters) { (response) in
            if response.json != nil {
                print(response)
                //completion(response.json, nil)
            }
            else {
                
                let errors =  response.error?.localizedDescription.values.first as! [String]
                self.alertLabel.text = errors[0]
            }
        }
        
        self.performSegue(withIdentifier: "passToForgot", sender: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        self.alertLabel.text = ""
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        self.verifyLogin(passwordString: passwordTextField.text!)
    }
    private func attemptLogin() -> Bool{
        let password = KLTManager.sharedInstance.keychain["password"]
        if (password != nil){
            return true
        }else{
            return false
        }
    }
    private func verifyLogin(passwordString:String){
        let userRequest = KLTUserRequests.init()
        userRequest.getToken(username: KLTManager.sharedInstance.keychain["email"]!, password: passwordString, completion: { (expiresIn, token, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                do {
                   try KLTManager.sharedInstance.keychain.set(token!, key: "token")
                }
                catch let error {
                    print(error)
                }
                do {
                    try KLTManager.sharedInstance.keychain.set(expiresIn!, key: "expires_in")
                }
                catch let error {
                    print(error)
                }
                do {
                   try KLTManager.sharedInstance.keychain.set(passwordString, key: "password")
                }
                catch let error {
                    print(error)
                }
                
         
                self.performSegue(withIdentifier: "loginPasswordToDash", sender: nil)
                print("No errors")
            }
            else {
                self.activityIndicator.stopAnimating()
                self.alertLabel.text = "We could not verify your password. please try again."
                // self.showErrorAlert(message: error!.localizedDescription["error_description"]! as! String)
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextField.delegate = self
        
      //  if self.attemptLogin(){
      //      self.verifyLogin(passwordString: KLTKeychainServices.loadPassword()! as String)
      //  }else{
      //  }
    }
}
