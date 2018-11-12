//
//  KLTDashboardViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 7/12/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

public class KLTDashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, KLTdashboardTableCellDelegate {
    
    
    fileprivate let slidingMenuWidth:CGFloat = 300.0
    
    var senderID:Int?
    var selectedItem:Item?
    
    //MARK: -IBOutlets
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var slidingMenu: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var spinnerView: UIView!
    
    
    
    //MARK: - View Funcs
    public class func create() -> KLTDashboardViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        return main as! KLTDashboardViewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        kltMediaBase = KLTMediaBase.init()
        downloadData()
        
        tableView.register(UINib(nibName: "KLTDashboardTableViewCell", bundle: self.nibBundle), forCellReuseIdentifier: "dashboardTableViewCellIdentifier")
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(self.blurView)
        self.blurView.isHidden = true
        self.blurView.frame = self.view.frame
        
        self.view.addSubview(self.slidingMenu)
        slidingMenu.frame = CGRect(x: -slidingMenuWidth, y: 0, width: slidingMenuWidth, height: self.view.frame.size.height)
        
        self.navigationController?.navigationBar.layer.zPosition = -1
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToFromBackground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        //        if let user = KLTManager.sharedInstance.currentUser {
        //            user.selectedTags = []
        //        }
        KLTManager.sharedInstance.selectedTags = []
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "didViewTutorial") == false {
            let vc = TutorialPageViewController.create()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override public var prefersStatusBarHidden: Bool {
        return hideStatus
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if(segue.identifier == "dashToDetail"){
            let itemDetailView = segue.destination as! KLTItemDetailViewController
            itemDetailView.item = self.selectedItem
        }
            
        else if(segue.identifier == "favToSearch"){
            let searchView = segue.destination as! KLTFinder
            let backItem = UIBarButtonItem()
            searchView.prefilterTagId = nil
            searchView.favFilter = true
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem //
        }
            
        else if (segue.identifier == "searchSegue") {
            let searchView = segue.destination as! KLTFinder
            let backItem = UIBarButtonItem()
            if let _ = sender as? UIBarButtonItem{
                searchView.prefilterTagId = nil
            }else{
                searchView.prefilterTagId = self.senderID
            }
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
            
        else if (segue.identifier == "dashToProduct") {
            let searchView = segue.destination as! KLTProductViewController
            let backItem = UIBarButtonItem()
            searchView.item = selectedItem
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem 
        }
        else if segue.identifier == "dashToProfile" {
            let destination = segue.destination as! KLTUserInfoEntryViewController
            destination.fromLogin = false
        }
    }
    
}

//MARK: -IBActions
extension KLTDashboardViewController {
    
    @IBAction func customTagsPressed(_ sender: Any) {
        self.toggleSlider(self)
        self.performSegue(withIdentifier: "dashToTags", sender: self)
    }
    
    @IBAction func reloaddDataButtonPressed(_ sender: Any) {
        self.downloadData()
    }
    
    func downloadData() {
        self.view.bringSubview(toFront: self.activityIndicator)
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.spinnerView.isHidden = false
        }
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.navigationController?.view.isUserInteractionEnabled = false
        
        KLTDownloadManager.sharedInstance.downloadAllData(completion: { (success) in
            if success {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.spinnerView.isHidden = true
                }
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                self.navigationController?.view.isUserInteractionEnabled = true
                self.tableView.reloadData()
            }
            self.sliderClose()
        })
    }
    
    @objc func appMovedToFromBackground() {
         KLTAnalytics.eventFired(type: KLTAnalytics.EventTypes.appEvent)
        self.downloadData()
    }
    
    @objc func appMovedToBackground() {
        self.spinnerView.isHidden = false
    }
    
    func didSelectDashboardBrand() {
        print("brand selected")
    }
    
    @IBAction func toggleSlider(_ sender: Any!) {
        if(self.slidingMenu.center.x <= 0){
            sliderOpen()
        }
        else{
            sliderClose()
        }
    }
    
    func sliderOpen() {
        self.blurView.isHidden = false
        self.blurView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.slidingMenu.frame = CGRect(x: 0, y: 0, width: self.slidingMenuWidth, height: self.tableView.frame.size.height)
            self.blurView.alpha = 1
        })
    }
    
    func sliderClose() {
        UIView.animate(withDuration: 0.3, animations: {
            
            self.slidingMenu.frame = CGRect(x: -self.self.slidingMenuWidth, y: 0, width: self.slidingMenuWidth, height: self.tableView.frame.size.height)
            self.blurView.alpha = 0
        })
    }
    
    @objc func viewAllPressed(_ sender: Any) {
        let btn = sender as! UIButton
        print("View All pressed in section : \(btn.tag)")
        
        let items = KLTManager.sharedInstance.kltItemsData.filter{($0.tags?.contains(btn.tag))!}
        
        let vc = KLTAllArticlesViewController.create() 
        vc.items = items
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func userProfileSelected(_ sender: Any) {
        self.toggleSlider(self)
//        let vc = KLTProfileViewController.create()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logoutButtonPress(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            do {
                try KLTManager.sharedInstance.keychain.remove("token")
            } catch let error {
                print("error: \(error)")
            }
            do {
                try KLTManager.sharedInstance.keychain.remove("expires_in")
            } catch let error {
                print("error: \(error)")
            }
            do {
                try KLTManager.sharedInstance.keychain.remove("email")
            } catch let error {
                print("error: \(error)")
            }
            do {
                try KLTManager.sharedInstance.keychain.remove("password")
            } catch let error {
                print("error: \(error)")
            }
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            
            self.performSegue(withIdentifier: "unwindToMainView", sender: self)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        self.toggleSlider(self)
        present(refreshAlert, animated: true, completion: nil)
    }
}

//MARK: -Delegation
extension KLTDashboardViewController {
    func didSelectDashboardTableItem(tagID: Int?, item: Item?) {
        if((tagID) != nil){
            print("A -> ((tagID) != nil)")
            self.senderID = tagID
            performSegue(withIdentifier: "searchSegue", sender: self)
        }
        else {
            print("A -> ((tagID) == nil)")
            KLTAnalytics.eventFired(type: KLTAnalytics.EventTypes.viewItem, valueTypeID: 1000, value: (item?.id)!)
            self.selectedItem = item
            
            if item?.itemType == .pdf {
                self.senderID = item?.id
                
                performSegue(withIdentifier: "dashToDetail", sender: self)
            }
            else if item?.itemType == .video {
                
                let player = KLTVideoPlayer.init()
                player.playVideo(with: item!)
                
            }
            else if item?.itemType == .product {
                //                if let productDescription = item?.product?.details {
                //                }
//                performSegue(withIdentifier: "dashToProduct", sender: self)
                let vc = KLThtmlViewerViewController.create()
                vc.item = item!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if item?.itemType == .article {
                
            }
        }
    }
}

//MARK: -Table
extension KLTDashboardViewController {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return KLTManager.sharedInstance.dashboardSections.count
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        let headerBG = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 45.0))
        headerBG.backgroundColor = #colorLiteral(red: 0.07259241492, green: 0.2311677933, blue: 0.4132259488, alpha: 1)
        
        let headerLabel = UILabel()
        headerLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        headerLabel.frame = CGRect.init(x: 19, y: 17, width: headerLabel.intrinsicContentSize.width, height: 15)
        headerLabel.textColor = #colorLiteral(red: 0.9607108235, green: 0.9608257413, blue: 0.9606716037, alpha: 1)
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: self.view.frame.size.width - 100 , y: 17 + 4, width: 100, height: 15)
        btn.tag = KLTManager.sharedInstance.dashboardSections[section].tagID!
        btn.setTitle("View All", for: .normal)
        btn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        btn.titleLabel?.textColor = UIColor.lightGray
        btn.addTarget(self, action: #selector(viewAllPressed(_:)), for: .touchUpInside)
        
        headerView.addSubview(headerBG)
        headerView.addSubview(headerLabel)
        if section != 0 {
            headerView.addSubview(btn)
        }
        
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if(KLTManager.sharedInstance.dashboardSections[section].tagID == 3000){
//            return "Browse Libraries"
//        }else{
            return KLTManager.sharedInstance.dashboardSections[section].name!
//        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemThumbnailHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardTableViewCellIdentifier", for: indexPath) as! KLTDashboardTableViewCell
        var items: Array<Item> = Array()
//        var tags: Array<Tag> = Array()
        
//        if KLTManager.sharedInstance.dashboardSections[indexPath.section].tagID! == 3000 {
//            for tag in KLTManager.sharedInstance.kltLibrariesData {
//                tags.append(tag)
//                cell.tags = tags
//            }
//            cell.items = []
//        }
//        else {
            for item in KLTManager.sharedInstance.kltItemsData {
                if let tags = item.tags {
                    if (tags.contains(KLTManager.sharedInstance.dashboardSections[indexPath.section].tagID!)) {
                        items.append(item)
                    }
                }
            }
            cell.items = items
            cell.tags = []
//        }
        cell.delegate = self
        return cell
    }
    
}
