//
//  ProfileSegmentedTableViewCell.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 12/4/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol ProfileSegmentDelegate {
    func segmentSelected(index: Int)
}

class ProfileSegmentedTableViewCell: UITableViewCell {
    
    var delegate: ProfileSegmentDelegate?
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func segmentSelected(_ sender: Any) {
        delegate?.segmentSelected(index: segmentedControl.selectedSegmentIndex)
    }
    
}
