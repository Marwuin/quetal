//
//  LogInViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 8/1/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

import KLTTouchPoint2_0

class LogInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let vc = KLTSplashViewController.create()
//        let vc = KLTLogInViewController.create()
        self.present(vc, animated: false, completion: nil)
    }
    
    
}
