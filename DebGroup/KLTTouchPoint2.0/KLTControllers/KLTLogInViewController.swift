
//  KLTLogInViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 7/12/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

public class KLTLogInViewController: UIViewController, UITextFieldDelegate {
    //MARK: -VARS
    var readyToProceed: Bool = false
    
    //MARK: -IBOutlet
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: -View funcs
    public override func viewDidAppear(_ animated: Bool) {
        
        KLTDownloadManager.sharedInstance.queue = TaskQueue()

        let token = KLTManager.sharedInstance.keychain["token"]
        if token != nil {
            debugPrint("*** TOKEN FOUND ***")
            let userRequest = KLTUserRequests()
            if !userRequest.isTokenExpired(){
                debugPrint("*** TOKEN NOT EXPIRED ***")
                self.performSegue(withIdentifier: "loginToDash", sender: nil)
            }else{
                 debugPrint("*** TOKEN EXPIRED ***")
                self.mainView.isHidden = false
            }
        }else{
            debugPrint("*** NO TOKEN FOUND ***")
            self.mainView.isHidden = false
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.userName.delegate = self
        self.userName.text = KLTManager.sharedInstance.currentUser?.email
        self.mainView.isHidden = true

    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override public var prefersStatusBarHidden: Bool {
        return hideStatus
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToRegister" {
            let destination = segue.destination as! KLTRegisterViewController
            if !(userName.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                destination.emailAddress = userName.text
            }
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
    }
    
    //MARK: -Funcs
    public class func create() -> KLTLogInViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        UIApplication.shared.isStatusBarHidden = true
        //Sample call to add an analytics item to the analytics queue:
//        let kltAnalytics = KLTAnalytics.init()
//        kltAnalytics.addItem(withID: 1, andDescription: "Framework Instantiated")
        return main as!
        KLTLogInViewController
    }
    
    private func verifyEmailRequest(emailString:String){
        let userRequest = KLTUserRequests.init()
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        userRequest.validateEmail(email: emailString, completion: { (success, userExists, isActive, isRegistered ,isVerified, isApproved, error) in
            
            if success {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                do {
                    try KLTManager.sharedInstance.keychain.set(emailString, key: "email")
                }
                catch let error {
                    print(error)
                }
                if !userExists! && !emailString.contains("@cbrands.com") {
                    self.alertLabel.text = "Your account is currently inactive. Please contact your MDM for access"
                }
                else if !userExists! && emailString.contains("@cbrands.com")  {
                    self.performSegue(withIdentifier: "loginToRegister", sender: nil)
                }
                else if userExists! && !isActive! {
                    self.alertLabel.text = "Your account is currently inactive. Please contact your MDM for access"
                }
                else if userExists! && isActive! && !isRegistered! {
                    self.performSegue(withIdentifier: "loginToRegister", sender: nil)
                }
                else if userExists! && isActive! && isRegistered! && !isVerified! {
                    self.performSegue(withIdentifier: "loginToConfirmation", sender: nil)
                }
//                else if userExists!  && isActive! && isRegistered! && isVerified! && !isApproved! {
//                    let vc = KLTProfileViewController.create()//KLTUserInfoEntryViewController.create()
//                    vc.fromLogin = true
//                    self.present(vc, animated: true, completion: nil)
//                }
                else if userExists!  && isActive! && isRegistered! && isVerified! {//&& isApproved!{
                    self.performSegue(withIdentifier: "loginToPassword", sender: nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                self.alertLabel.text = "We could not verify your email. Please try again."
            }
        }
        )
    }
    
    @IBOutlet weak var alertLabel: UILabel!
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.alertLabel.text = ""
        if !(userName.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            self.verifyEmailRequest(emailString: userName.text!)
        }
        else {
            self.alertLabel.text = "Email cannot be empty."
        }
    }
}

