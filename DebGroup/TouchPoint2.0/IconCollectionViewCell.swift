//
//  IconCollectionViewCell.swift
//  OpenTab
//
//  Created by Raul Silva on 7/6/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol iconDelegate:class{
    func didSelectIcon(item:Item)
}

class IconCollectionViewCell: UICollectionViewCell, itemDelegate {
    func didLoadThumb() {
        self.icon.image = myItem?.thumbView
    }
    
    weak var delegate:iconDelegate?
    var myItem:Item?
    @IBOutlet weak var overlayToggleButton: UIButton!
    
    @IBOutlet weak var viewButton: UIButton!
    
    @IBAction func viewSelect(_ sender: UIButton) {
        self.delegate?.didSelectIcon(item: myItem!)
    }
    @IBAction func toggleOverlay(_ sender: Any) {
        myItem?.selected = !(myItem?.selected)!
        self.overlay.isHidden = (myItem?.selected)!
    }
    
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        self.overlay.frame.size = self.frame.size
        self.overlay.isHidden = !(myItem?.selected)!
          self.icon.image =    myItem?.thumbView
        self.label.text = myItem?.name
    }
}
