//
//  HTMLTextTableViewCell.swift
//  KLTTouchPoint2.0
//
//  Created by Sameer Siddiqui on 3/21/18.
//  Copyright © 2018 Raul Silva. All rights reserved.
//

import UIKit

class HTMLTextTableViewCell: UITableViewCell {

    @IBOutlet weak var newsText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
