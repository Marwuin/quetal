//
//  KLTForgotPasswordViewController.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 9/7/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTForgotPasswordViewController: UIViewController, RCBPinEntryViewDelegate {
    //MARK: -Vars
    var codeToVerify:String?
    var appVerifyCode:String?
    
    //MARK: -IBOutlets
    @IBOutlet weak var pinEntryView: RCBPinEntryView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    
    //MARL: -IBActions
    @IBAction func resendPressed(_ sender: UIButton) {
            let endpoint = "/api/v1/User/Password/Reset/Request/Email/"
            let parameters:[String:String] = ["Email":KLTManager.sharedInstance.keychain["email"]!]
            let client = KLTClientServices.init()
            client.postRequest(with: endpoint, parameters: parameters) { (response) in
            if response.json != nil {
            }
            else {
                let errors =  response.error?.localizedDescription.values.first as! [String]
                self.alertLabel.text = errors[0]
            }
            }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNumberLabel.text = KLTManager.sharedInstance.keychain["email"]!
        self.pinEntryView.delegate = self
        self.alertLabel.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "codeToPasswordEntryIdentifier"){
            let destination = segue.destination as! KLTNewPasswordEntryViewController
            destination.appcode = appVerifyCode
        }
    }

    //MARK: -Funcs
    internal func pinEntryValueDidChangeTo(_ pinNumber: String) {
        if(pinNumber.count == 4){
                let endpoint = "/api/v1/User/Password/Reset/Verify/Email/"
                let parameters:[String:String] = ["Email":KLTManager.sharedInstance.keychain["email"]!,"SentCode":pinNumber]
                
                let client = KLTClientServices.init()
                client.postRequest(with: endpoint, parameters: parameters) { (response) in
                    if response.json != nil {
                        self.appVerifyCode = response.json!["AppVerifyCode"].string
                       self.performSegue(withIdentifier: "codeToPasswordEntryIdentifier", sender: nil)
                    }
                    else {
                        let errors =  response.error?.localizedDescription.values.first as! [String]
                        self.alertLabel.text = errors[0]
                    }
                }
        }else{
            self.alertLabel.text = ""
        }
    }
}
