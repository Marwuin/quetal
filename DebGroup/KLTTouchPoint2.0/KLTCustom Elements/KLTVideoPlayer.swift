//
//  KLTVideoPlayer.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/17/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTVideoPlayer: NSObject, MobilePlayerDelegate {

    var itemID:Int?
    var currentItem: Item?
    
    func playVideo(with item: Item) {
        self.itemID = item.id!
        self.currentItem = item
        let config: MobilePlayerConfig = MobilePlayerConfig.init(fileURL: (frameworkBundle?.url(forResource: "videoPlayer", withExtension: "json"))!)
        let isDownloaded = kltMediaBase!.isItemDownloaded(item: item)
        var url: URL?
        if isDownloaded {
            url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(item: item)
        }
        else {
            url = URL.init(string: item.url!)
        }
        
        let playerVC = MobilePlayerViewController(contentURL: url!, config: config)
        playerVC.delegate = self
        playerVC.item = item
        playerVC.title = url!.absoluteString
        playerVC.controlsHidden = false
        playerVC.activityItems = [url!]
        
        UIViewController.top?.present(playerVC, animated: true, completion: nil)
    }
    
    func didPressMailButton(sender: UIButton) {
        print("mail pressed")
        
        if KLTManager.sharedInstance.mailbagItems.contains(itemID!) {
            KLTManager.sharedInstance.mailbagItems.remove(at: KLTManager.sharedInstance.mailbagItems.index(of: itemID!)!)
            sender.setImage(#imageLiteral(resourceName: "envelope"), for: UIControlState.normal)
        }
         else{
            KLTManager.sharedInstance.mailbagItems.append(itemID!)
            
            let outboxVC = KLTMailbagViewController.create()
            
            UIViewController.top?.present(outboxVC, animated: true, completion: nil)
            sender.setImage(#imageLiteral(resourceName: "envelopeSelected"), for: UIControlState.normal)
        }
    }
    
    func didPressTagButton(sender: UIButton) {
        KLTTagsPopUpViewController.showPopupModal(with: currentItem!)
    }
    
    func didPressFavButton(sender: UIButton) {
        if !currentItem!.isFavorite! {
            changeFavButtonToFavState(sender: sender)
                        
            KLTManager.sharedInstance.favoriteItem(item: currentItem!, completion: { success in
                if !success {
                    self.changeFavButtonToUnfavState(sender: sender)
                }
            })
        }
        else {
            changeFavButtonToUnfavState(sender: sender)
            
            KLTManager.sharedInstance.unfavoriteItem(item: currentItem!, completion: { success in
                if !success {
                    self.changeFavButtonToFavState(sender: sender)
                }
            })
            
        }
    }
    
 
    
    func changeFavButtonToFavState(sender: UIButton) {
        sender.setImage(#imageLiteral(resourceName: "fav"), for: UIControlState.normal)
    }
    
    func changeFavButtonToUnfavState(sender: UIButton) {
        sender.setImage(#imageLiteral(resourceName: "unfav"), for: UIControlState.normal)
    }
}
