//
//  KLTAllArticlesViewController.swift
//  KLTTouchPoint2.0
//
//  Created by Sameer Siddiqui on 3/7/18.
//  Copyright © 2018 Raul Silva. All rights reserved.
//

import UIKit

class KLTAllArticlesViewController: UIViewController {

    @IBOutlet weak var tableView: KLTAllArticlesViewController!
    
    var items: [Item]?
    
     class func create() -> KLTAllArticlesViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        return main as! KLTAllArticlesViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}

extension KLTAllArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: - TableView Delegate and DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = items {
            return items.count
        }
        else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! KLTNewsFeedTableViewCell
        if let items = items {
            let item = items[indexPath.row]
            if let thumbail = item.thumbnail {
                cell.newsImage.af_setImage(withURL: URL.init(string: thumbail)!, placeholderImage:UIImage.init(named: "brokenLink"))
            }
            else {
                cell.newsImage.image = UIImage.init(named: "brokenLink")
            }
            if let title = item.title {
                cell.newsTitle.text = title
            }
            if let product = item.product {
                if let description = product.details {
                    let attrString = description.html2AttributedString
                    cell.newsDescription.attributedText = attrString
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let item = items![indexPath.row]
        let vc = KLThtmlViewerViewController.create()
        vc.item = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
