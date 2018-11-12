//
//  KLTProductViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 8/12/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTProductViewController: UIViewController, navRightSideButtonDelegate {
    //MARK: -Vars
    var item:Item!
    let defaultText = "-"
    
    //MARK: -IBOutlets
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var preBuyPriceLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: -IBActions
    @IBAction func orderButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL.init(string: "https://www.constellationbeergear.com/store/account/logon")!, options: [:], completionHandler: nil)
    }

    //MARK: -View funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = KLTNavBarRightItemButtons.getItems(client:self, item: item)
        
        let isDownloaded = kltMediaBase!.isItemDownloaded(item: item)
        var url: URL?
        if isDownloaded {
            url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(item: item)
        }
        else {
            if let itemUrl = item.url {
                url = URL.init(string: itemUrl)
            }
            else {
                url = URL.init(string: "")
            }
        }
        
        if let imageUrl = url {
            self.productImage.af_setImage(withURL: imageUrl, placeholderImage:UIImage.init(named: "brokenLink"))
        }
        else {
            self.productImage.image = UIImage.init(named: "brokenLink")
        }
        
        if let title = self.item.product?.shopTitle {
            self.titleLabel.text = title
        }

        if let details = self.item.product?.details {
            self.detailsLabel.text = "Details: " + details
        }

        if let price = self.item.product?.price {
            self.priceLabel.text = "Price: " + price
        }

        if let preBuyPrice = self.item.product?.preBuyPrice {
            self.preBuyPriceLabel.text = "Pre-buy Price: " + preBuyPrice
        }

        if let sku = self.item.product?.sku {
            self.skuLabel.text = "BDA SKU: " + sku
        }
        
    }
    
    override public var prefersStatusBarHidden: Bool {
        return hideStatus
    }
    
    //MARK: -Delegation
    func didSelectNavBarRightButton(buttonType: buttonTypes, sender:UIBarButtonItem) {
        if buttonType == .tagButton {
            KLTTagsPopUpViewController.showPopupModal(with: item)
        }
        else if buttonType == .favButton {
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
        else if buttonType == .mailbagButton {
            if (KLTManager.sharedInstance.mailbagItems.contains(item.id!)){
                KLTManager.sharedInstance.mailbagItems.remove(at: KLTManager.sharedInstance.mailbagItems.index(of: item.id!)!)
                sender.image = #imageLiteral(resourceName: "envelope")
            }
            else{
                KLTManager.sharedInstance.mailbagItems.append(item.id!)
                sender.image = #imageLiteral(resourceName: "envelopeSelected")
                  performSegue(withIdentifier: "productToOutboxIdentifier", sender: self)
            }
        }
    }
}
