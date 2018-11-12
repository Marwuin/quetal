//
//  KLTItemDetailViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 6/26/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTItemDetailViewController: UIViewController, UIWebViewDelegate, navRightSideButtonDelegate {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    //MARK: -Vars
    var item:Item!
//    var sentURL:NSURL?
    var myName:String?
    //MARK: -IBOutlets
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isDownloaded = kltMediaBase!.isItemDownloaded(item: item)

        var url: URL?
        if isDownloaded {
            url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(item: item)
        }
        else {
            url = URL.init(string: item.url!)
        }
        
        let request = NSURLRequest(url: url!)
        print("REQUEST:\(request)")
        webView.loadRequest(request as URLRequest)
        webView.isHidden = true
        webView.delegate = self as UIWebViewDelegate
        navigationItem.rightBarButtonItems = KLTNavBarRightItemButtons.getItems(client:self, item: item)
    }

    //MARK: -View funcs
    override public var prefersStatusBarHidden: Bool {
        return hideStatus
    }
    
    //MARK: -Delegation
    func didSelectNavBarRightButton(buttonType: buttonTypes, sender: UIBarButtonItem) {
        if buttonType == .tagButton {
            KLTTagsPopUpViewController.showPopupModal(with: item)
        }
        if buttonType == .favButton {
            if item.isFavorite! {
                KLTManager.sharedInstance.unfavoriteItem(item: item, completion: { success in
                    self.navigationItem.rightBarButtonItems = KLTNavBarRightItemButtons.getItems(client:self, item: self.item)
                    
                })
            }
            else {
                KLTManager.sharedInstance.favoriteItem(item: item, completion: { success in
                    self.navigationItem.rightBarButtonItems = KLTNavBarRightItemButtons.getItems(client:self, item: self.item)
                })
            }
        }
        if buttonType == .mailbagButton {
            if(KLTManager.sharedInstance.mailbagItems.contains(item.id!)){
                KLTManager.sharedInstance.mailbagItems.remove(at: KLTManager.sharedInstance.mailbagItems.index(of: item.id!)!)
                sender.image = #imageLiteral(resourceName: "envelope")
            }else{
                KLTManager.sharedInstance.mailbagItems.append(item.id!)
                sender.image = #imageLiteral(resourceName: "envelopeSelected")
                performSegue(withIdentifier: "itemDetailToOutboxIdentifier", sender: self)
            }
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spinner.stopAnimating()
        self.webView.isHidden = false
        self.webView.alpha = 0
        self.webView.dataDetectorTypes = UIDataDetectorTypes.all
        UIView.animate(withDuration: 0.3, animations: {
            self.webView.alpha = 1
        })
    }
}
