//
//  KLTNewPasswordEntryViewController.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 9/7/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTNewPasswordEntryViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: -Vars
    var appcode:String?
    
    //MARK: -IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!

    //MARK: -IBActions
    @IBAction func submitPressed(_ sender: UIButton) {
        let client = KLTClientServices.init()
         self.alertLabel.text = ""
        let endpoint = "/api/v1/User/Password/Reset/Email/"
        let parameters:[String:String] = ["Email":KLTManager.sharedInstance.keychain["email"]!,"AppCode":appcode!,"Password":passwordField.text!]
        client.putRequest(with: endpoint, parameters: parameters) { (response) in
            if response.json != nil {
                        KLTMessages.displaySuccess(withTitle: "Success!", andMessage: "Your password has been reset.")
                 self.performSegue(withIdentifier: "goBackToMain", sender: self)
            }
            else {
                let errors =  response.error?.localizedDescription.values.first as! [String]
                self.alertLabel.text = errors[0]
            }
        }
        
    }
    
    @IBAction func showPressed(_ sender: UIButton) {
        passwordField.isSecureTextEntry =  !passwordField.isSecureTextEntry
        if( passwordField.isSecureTextEntry ){
            showButton.setTitle("Show", for: UIControlState.normal)
        }else{
             showButton.setTitle("Hide", for: UIControlState.normal)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -View Funcs
    override func viewDidLoad() {
        self.passwordField.delegate = self
        super.viewDidLoad()
        self.alertLabel.text = ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
