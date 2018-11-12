//
//  KLTScrollingMenuCollectionViewCell.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 12/11/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol ScrollingMenuCellDelegate {
    func expandbuttonPressed(_ sender: Any)
}

class KLTScrollingMenuCollectionViewCell: UICollectionViewCell {
    
    var delegate: ScrollingMenuCellDelegate?
    
    @IBOutlet weak var filterImage: UIImageView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func expandButtonPressed(_ sender: Any) {
        self.delegate?.expandbuttonPressed(sender)
    }

}
