//
//  CodeVerificationViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 7/24/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTCodeVerificationViewController: UIViewController, RCBPinEntryViewDelegate {
    
    //MARK: -Vars
    let numberToolbar: UIToolbar = UIToolbar()
    
    //MARK: -IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var codeEntry: RCBPinEntryView!
    @IBOutlet weak var alertText: UILabel!
    
    //MARK: -IBActions
    @IBAction func sendAgainPressed(_ sender: UIButton) {
        let endpoint = "/api/v1/User/" + KLTManager.sharedInstance.guid! + "/ResendCode/"
        let client = KLTClientServices.init()
        client.postRequest(with: endpoint, parameters: nil) { (response) in
            if response.json != nil {
                debugPrint("Code resent")
    KLTMessages.displaySuccess(withTitle: "Success!", andMessage: "A new code has been emailed.")
            }
            else {
                print("did recieve error \(response.error!)")
            }
        }
    }
    
    //MARK: -View funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.codeEntry.delegate = self
        numberToolbar.barStyle = UIBarStyle.blackTranslucent
        let barButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(KLTCodeVerificationViewController.cancelEntry))
        barButtonItem.tintColor = UIColor.white
        numberToolbar.items = [barButtonItem]
        numberToolbar.sizeToFit()
        codeEntry.textField.inputAccessoryView  = numberToolbar
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pinToProfile" {
            let destination = segue.destination as! KLTProfileViewController//KLTUsKLTerInfoEntryViewController
            destination.fromLogin = true
        }
    }
    
    //MARK: -Funcs
    @objc private func cancelEntry() {
        codeEntry.textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -Delegation
    func pinEntryValueDidChangeTo(_ pinNumber: String) {
        if pinNumber.count == 4 {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            let request = KLTUserRequests.init()
            request.verifyPin(pin: pinNumber, completion: { (success, error) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                if success! {
                    self.performSegue(withIdentifier: "pinToProfile", sender: nil)
                }
                else {
                    self.alertText.text = "Could not verify the pin number. Please try again."
                }
            })
        }
        else {
            self.alertText.text = ""
        }
    }
}
