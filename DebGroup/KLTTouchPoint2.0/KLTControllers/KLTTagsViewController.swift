//
//  KLTTagsViewController.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 10/4/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTTagsViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var tagPool = [Tag]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tagPool = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == true}

//        let tagButton = UIBarButtonItem(image: #imageLiteral(resourceName: "tag"), style: .plain, target: self, action: #selector(createTag))
        if tagPool.count > 0 {
            self.tableView.isHidden = false
            self.navigationItem.rightBarButtonItems = [self.editButtonItem]//, tagButton]
        }
        else {
//            self.navigationItem.rightBarButtonItem = tagButton
        }
        
        self.tableView.separatorColor = .white
        self.tableView.tableFooterView = UIView.init()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
    }
    
//    func createTag() {
////        KLTTagsPopUpViewController.showPopupModal(with: item)
//    }
    
}

extension KLTTagsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagPool.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell", for: indexPath) as! KLTTagsTableViewCell
        cell.tagTitle.attributedText =  NSAttributedString.init(string: tagPool[indexPath.row].name!, attributes: filterTextAttributes)
        let items = KLTManager.sharedInstance.kltItemsData.filter{($0.tags?.contains(tagPool[indexPath.row].tagID!))!}
        cell.tagDescription.attributedText = NSAttributedString.init(string: "\(items.count) media \(items.count == 1 ? "item" : "items") using tag", attributes: filterTagTextAttributes)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tagID = self.tagPool[indexPath.row].tagID!
        let vc = KLTFinder.create()
        vc.prefilterTagId = tagID
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            let request = KLTMediaRequests.init()
            request.deleteTag(tagID: tagPool[indexPath.row].tagID!, completion: { (sucess, error) in
                if sucess {
                    if self.tagPool.count > 1 {
                        let index = KLTManager.sharedInstance.kltTagsData.index(of: self.tagPool[indexPath.row])
                        KLTManager.sharedInstance.kltTagsData.remove(at: index!)
                        self.tagPool = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == true}
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                    else { // Only 1 tag
                        let index = KLTManager.sharedInstance.kltTagsData.index(of: self.tagPool[indexPath.row])
                        KLTManager.sharedInstance.kltTagsData.remove(at: index!)
                        self.tagPool = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == true}
                        self.tableView.reloadData()
                        self.tableView.isHidden = true
                        self.navigationItem.rightBarButtonItem = nil
                    }
                    
                }
                else { //error
                    self.showErrorAlert(message: "Could not delete tag at this time. Please try again.")
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
}
