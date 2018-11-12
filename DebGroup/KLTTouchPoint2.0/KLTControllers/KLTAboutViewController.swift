//
//  KLTAboutViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 8/19/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTAboutViewController: UIViewController, UITextViewDelegate {

    @IBAction func email(_ sender: UIButton) {
        let email = "mike.sinsheimer@augustjackson.com?cc=stacey.johnson@cbrands.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    @IBOutlet weak var bodyCopy: UITextView!
    var gradientLayer: CAGradientLayer!
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createGradientLayer()
        bodyCopy.isEditable = false
        bodyCopy.isSelectable = true
        let localizedString = NSMutableAttributedString(string: "If you have content you would like to see in Open Tab, or if you know of a distributor or CBI employee who needs access to the app please contact Mike Sinsheimer and CC Stacey Johnson. All requests will receive a response within 48 hours.")
        let tosRange = localizedString.mutableString.range(of: "Mike Sinsheimer")
        let tosRange2 = localizedString.mutableString.range(of: "Stacey Johnson")
//
        
        
        
        
        localizedString.addAttributes([NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18)], range: NSRange.init(location: 0, length: localizedString.length))
        localizedString.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)], range: tosRange)
         localizedString.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)], range: tosRange2)

        localizedString.endEditing()
        bodyCopy.delegate = self
        self.bodyCopy.attributedText = localizedString
    }
    override public var prefersStatusBarHidden: Bool {
        return hideStatus
    }
}
