//
//  KLTNavBarRightItemButtons.swift
//  OpenTab
//
//  Created by Raul Silva on 8/16/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import Foundation
import UIKit

enum buttonTypes {
    case mailbagButton
    case favButton
    case tagButton
}

protocol navRightSideButtonDelegate:class{
    func didSelectNavBarRightButton(buttonType:buttonTypes, sender:UIBarButtonItem)
}

class KLTNavBarRightItemButtons:NSObject{
    static weak var delegate:navRightSideButtonDelegate?
    static var myItem:Int?
    static var item: Item?
    
    class func getItems(client:UIViewController, item:Item) -> [UIBarButtonItem]{
        myItem = item.id!
        self.item = item
        self.delegate = client as? navRightSideButtonDelegate
        let mailbagButton = UIBarButtonItem(image: self.getMailbagButtonImage(), style: .plain, target: self, action: #selector(eventFired(sender:)))
        let tagImage = #imageLiteral(resourceName: "tag")

        mailbagButton.tag = 0
        let favButton = UIBarButtonItem(image: self.getFavButtonImage(), style: .plain, target: self, action: #selector(eventFired(sender:)))
        favButton.tag = 1
        let tagButton = UIBarButtonItem(image: tagImage, style: .plain, target: self, action: #selector(eventFired(sender:)))
        tagButton.tag = 2
        return([mailbagButton,favButton,tagButton])
    }

    class func getMailbagButtonImage () -> UIImage{
        var mailbagImage = UIImage()
        if(KLTManager.sharedInstance.mailbagItems.contains(myItem!)){
            mailbagImage = #imageLiteral(resourceName: "envelopeSelected")
        }else{
            mailbagImage = #imageLiteral(resourceName: "envelope")
        }
        return mailbagImage
    }
    
    class func getFavButtonImage () -> UIImage{
        var favImage = UIImage()
        if item!.isFavorite!{
            favImage = #imageLiteral(resourceName: "fav")
        }else{
            favImage = #imageLiteral(resourceName: "unfav")
        }
        return favImage
    }
    @objc class func eventFired(sender: UIBarButtonItem){
        switch sender.tag {
        case 0:
            delegate?.didSelectNavBarRightButton(buttonType:  buttonTypes.mailbagButton, sender: sender)
            NotificationCenter.default.post(name: Notification.Name("mailbagChange"), object: self)
        case 1:
            delegate?.didSelectNavBarRightButton(buttonType: buttonTypes.favButton, sender: sender)
        case 2:
            delegate?.didSelectNavBarRightButton(buttonType: buttonTypes.tagButton, sender: sender)
        default:
            debugPrint("Non supported tag")
        }
    }
}
