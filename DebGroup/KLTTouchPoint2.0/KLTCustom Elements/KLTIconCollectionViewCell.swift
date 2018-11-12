//
//  KLTIconCollectionViewCell.swift
//  OpenTab
//
//  Created by Raul Silva on 7/6/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

// The item finder window is made up of a multiple section table
// each section contains a single row and a header
// each row contains a horizontally scrolling collection view
// this is the subclass for those cells

import UIKit

protocol iconDelegate: class {
    func didSelectToViewDocument(item:Item)
}

class KLTIconCollectionViewCell: UICollectionViewCell {
    
    var myItem:Item?
    weak var delegate:iconDelegate?
    var firstLoad = true
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var mailbagButton: UIButton!
    @IBOutlet weak var fabButton: UIButton!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        self.contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth , UIViewAutoresizing.flexibleHeight]
        nameLabel.padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func overlayDidMoveOntop(){
        if (myItem?.isFavorite!)! {
            changeFavButtonToFavState(sender: fabButton)
        }
        else {
            changeFavButtonToUnfavState(sender: fabButton)
        }
    }
    
    
    @IBAction func addToMailbag(_ sender: UIButton) {
        
        if let indexOf = KLTManager.sharedInstance.mailbagItems.index(where: { $0 == myItem?.id}){
            self.mailbagButton.tintColor = cbDeselectedStateButtonTint
            self.mailbagButton.setImage(#imageLiteral(resourceName: "envelope"), for: UIControlState.normal)
            KLTManager.sharedInstance.mailbagItems.remove(at: indexOf)
        }
        else{
            KLTManager.sharedInstance.mailbagItems.append((myItem?.id)!)
            self.mailbagButton.tintColor = cbSelectedStateButtonTint
            self.mailbagButton.setImage(#imageLiteral(resourceName: "envelopeSelected"), for: UIControlState.normal)
        }
        
        NotificationCenter.default.post(name: Notification.Name("mailbagChange"), object: self)
    }
    
    @IBAction func toggleFav(_ sender: UIButton) {
        if sender.tintColor == cbDeselectedStateButtonTint {
            changeFavButtonToFavState(sender: sender)
    
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            
            KLTManager.sharedInstance.favoriteItem(item: myItem!, completion: { success in
                
                if !success {
                    self.changeFavButtonToUnfavState(sender: sender)
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            })
            
        }
        else {
           changeFavButtonToUnfavState(sender: sender)
            
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            
            KLTManager.sharedInstance.unfavoriteItem(item: myItem!, completion: { success in
                
                if !success {
                    self.changeFavButtonToFavState(sender: sender)
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            })
            
        }
    }
    
    func changeFavButtonToFavState(sender: UIButton) {
        sender.tintColor = cbSelectedStateButtonTint
        sender.setImage(#imageLiteral(resourceName: "fav"), for: UIControlState.normal)
    }
    
    func changeFavButtonToUnfavState(sender: UIButton) {
        sender.tintColor = cbDeselectedStateButtonTint
        sender.setImage(#imageLiteral(resourceName: "unfav"), for: UIControlState.normal)
    }
    
    @IBAction func viewDocumentSelected(_ sender: UIButton) {
        self.delegate?.didSelectToViewDocument(item:myItem!)
    }
    
}


