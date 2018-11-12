//
//  KLTNavViewController.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 9/1/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTNavViewController: UINavigationController, UINavigationControllerDelegate {
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
}
