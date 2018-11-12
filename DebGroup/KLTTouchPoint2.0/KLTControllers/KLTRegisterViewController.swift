//
//  KLTRegisterViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 7/19/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTRegisterViewController: UIViewController {

    var emailAddress: String?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = emailAddress {
            emailTextField.text = email
        }
        
    }
    
    @IBAction func sendConfirmationPressed(_ sender: Any) {
        let userRequest = KLTUserRequests.init()
        if !(emailTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! && !(passwordTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! && !(firstNameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! && !(lastNameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            
            userRequest.validateEmail(email: self.emailTextField.text!, completion: { (success, userExists, isActive, isRegistered ,isVerified, isApproved, error) in
                
                
                if success {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    do {
                        try KLTManager.sharedInstance.keychain.set(self.emailTextField.text!, key: "email")
                    }
                    catch let error {
                        print(error)
                    }
                    if !userExists! {
                        //Create new user here
                        userRequest.createAccount(email: self.emailTextField.text!, password: self.passwordTextField.text!, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, completion: { (success, error) in
                            if success {
                                self.performSegue(withIdentifier: "registerToCodeVerify", sender: nil)
                            }
                            else {
                                self.showErrorAlert(message: "There was an error while registering. Please try again.")
                            }
                        })
                    }
                    else if userExists! && !isRegistered! {
                        //Update user
                        userRequest.updateAccount(email: self.emailTextField.text!, password: self.passwordTextField.text!, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, completion: { (success, error) in
                            if success {
                                self.performSegue(withIdentifier: "registerToCodeVerify", sender: nil)
                            }
                            else {
                                self.showErrorAlert(message: "There was an error while registering. Please try again.")
                            }
                        })
                    }
                    else if userExists! && isRegistered! {
                        self.showRegisteredUser()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    self.showErrorAlert(message: "There was an error while registering. Please try again.")
                    
                }
            })
        }
        else {
            var title: String?
            
            if (self.emailTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                title = "Email"
            }
            else if (self.firstNameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                title = "First name"
            }
            else if (self.lastNameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                title = "Last name"
            }
            else if (self.passwordTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                title = "Password"
            }
            
            self.showErrorAlert(message: title! + " field can not be empty")
        }
    }
    
    func showRegisteredUser() {
        self.showAlert(title: "Error", message: "The email has already been\nregistered.\nPlease go back to login", action: UIAlertAction(title: "Go back", style: .default, handler: { (action:
            UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
    }
    
    
}
