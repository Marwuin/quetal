//
//  MailbagTableViewCell.swift
//  OpenTab
//
//  Created by Raul Silva on 7/7/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol  mailbagItemDelegate:class{
    func itemDocumentViewSelected(item:Item)
    func removeRowAtIndex(index:Int)
}

class KLTMailbagTableViewCell: UITableViewCell {
    //MARK: -Vars
    weak var delegate:mailbagItemDelegate?
    var item:Item?
    //MARK: -IBOutlets
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var envelopeButton: UIButton!
    //MARK: -IBActions
    @IBAction func viewPressed(_ sender: UIButton) {
        self.delegate?.itemDocumentViewSelected(item: item!)
    }
    @IBAction func envelopePressed(_ sender: UIButton) {
        if let index = KLTManager.sharedInstance.mailbagItems.index(of: (self.item?.id)!){
            self.delegate?.removeRowAtIndex(index:index)
        }else{
            KLTManager.sharedInstance.mailbagItems.append((self.item?.id)!)
        }
        NotificationCenter.default.post(name: Notification.Name("mailbagChange"), object: self)
    }
}
