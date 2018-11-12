//
//  KLTSplashViewController.swift
//  KLTTouchPoint2.0
//
//  Created by cloudemotion on 10/8/18.
//  Copyright © 2018 Raul Silva. All rights reserved.
//

import UIKit

public class KLTSplashViewController: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -View funcs
    public override func viewDidAppear(_ animated: Bool) {
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.isNavigationBarHidden = true
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //navigationController?.setNavigationBarHidden(false, animated: true)
    }
    //MARK: -Funcs
    public class func create() -> KLTSplashViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        UIApplication.shared.isStatusBarHidden = true
        //Sample call to add an analytics item to the analytics queue:
        //        let kltAnalytics = KLTAnalytics.init()
        //        kltAnalytics.addItem(withID: 1, andDescription: "Framework Instantiated")
        return main as!
        KLTSplashViewController
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
