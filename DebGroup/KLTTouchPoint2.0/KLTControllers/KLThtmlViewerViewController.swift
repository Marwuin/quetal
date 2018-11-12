//
//  KLThtmlViewerViewController.swift
//  KLTTouchPoint2.0
//
//  Created by Sameer Siddiqui on 3/8/18.
//  Copyright © 2018 Raul Silva. All rights reserved.
//

import UIKit

class KLThtmlViewerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var item: Item?
    
    let testHtml = ""
    
    class func create() -> KLThtmlViewerViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        return main as! KLThtmlViewerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
  
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
    }

}

extension KLThtmlViewerViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: - TableView Delegate and DataSource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsPhotoCell", for: indexPath) as! HTMLPhotoTableViewCell
            
            if let urlString = item?.url {
                let url = URL.init(string: urlString)
                cell.newsImage.af_setImage(withURL:  url!, placeholderImage: UIImage.init(named: "brokenLink"), filter: nil, progress: nil, progressQueue: .main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: { (response) in
                })
            }
            else{
                cell.newsImage.image = UIImage.init(named: "brokenLink")
            }
            
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsTextCell", for: indexPath) as! HTMLTextTableViewCell
            
            if let product = item?.product {
                if let details = product.details {
                    let attrString = details.html2AttributedString
                    cell.newsText.attributedText = attrString
                }
            }
            
            cell.selectionStyle = .none
            return cell
        }
        
    }
}
