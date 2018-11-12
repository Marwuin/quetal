//
//  TutorialBaseViewController.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 9/20/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class TutorialBaseViewController: UIViewController {

    var vcIndex: Int!
    
    @IBOutlet weak var mainImage: UIImageView!
    
    public class func create(at index: Int) -> TutorialBaseViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! TutorialBaseViewController
        main.vcIndex = index
        return main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainImage.image = UIImage.init(named: "walkthrough\(vcIndex+1)")
    }

   
    
}
