//
//  KLTDashboardCollectionViewCell.swift
//  OpenTab
//
//  Created by Raul Silva on 7/18/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol dashboardIconDelegate:class {
    func didSelectDashboardItemToView(tagID:Int?, item:Item?)
}

class KLTDashboardCollectionViewCell: UICollectionViewCell {
    //MARK: -Vars
    var itemID:Int?
    var item: Item?
    var tagID:Int?
    weak var delegate:dashboardIconDelegate?
    //MARK: -IBOutlets
    @IBOutlet weak var fabButton: UIButton!//hidden in xib
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    //MARK: -IBActions
    @IBAction func fabPressed(_ sender: Any) {
    }
    
    @IBAction func viewDocPressed(_ sender: UIButton) {
        self.delegate?.didSelectDashboardItemToView(tagID:self.tagID, item:self.item)
    }
    @IBAction func toggleFav(_ sender: UIButton) {
        if(self.fabButton.alpha == 1){
            self.fabButton.alpha = kltGlobalDisabledTransparency
        }else{
            self.fabButton.alpha = 1
        }
    }
    //MARK: -View funcs
    override func awakeFromNib() {
        super.awakeFromNib()
        self.fabButton.alpha = kltGlobalDisabledTransparency
        label.padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
}
