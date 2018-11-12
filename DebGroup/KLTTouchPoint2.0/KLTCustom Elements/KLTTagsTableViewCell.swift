//
//  KLTTagsTableViewCell.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 10/4/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTTagsTableViewCell: UITableViewCell {

    @IBOutlet weak var tagTitle: UILabel!
    @IBOutlet weak var tagDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = openTabLightBlue
        self.selectedBackgroundView = bgColorView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
