//
//  KLTHelpViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 8/19/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTHelpViewController: UIViewController, UITextViewDelegate {
    //MARK: -Vars
    private var gradientLayer: CAGradientLayer!
    
    //MARK: -IBOulets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyCopy: UITextView!
    
    //MARK: -IBActions
    @IBAction func email(_ sender: UIButton) {
        let email = "mike.sinsheimer@augustjackson.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    //MARK: -View funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createGradientLayer()
        bodyCopy.isEditable = false
        bodyCopy.isSelectable = true
        let localizedString = NSMutableAttributedString(string: "If you are having a technical issue with the app please contact Mike Sinsheimer. In your email please include a detailed description of the issue, what device you are on, and what iOS the device is running. For questions about adding content or users, please see the About section.")
        let tosRange = localizedString.mutableString.range(of: "Mike Sinsheimer")
        localizedString.addAttributes([NSAttributedStringKey.font:UIFont.systemFont(ofSize: 18)], range: NSRange.init(location: 0, length: localizedString.length))
        localizedString.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)], range: tosRange)
        localizedString.endEditing()
        bodyCopy.delegate = self
        self.bodyCopy.attributedText = localizedString
    }
    
    override public var prefersStatusBarHidden: Bool {
        return hideStatus
    }
    
    //MARK: -Funcs
    private func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
