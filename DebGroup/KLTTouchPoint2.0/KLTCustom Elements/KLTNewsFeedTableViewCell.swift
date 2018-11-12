//
//  KLTNewsFeedTableViewCell.swift
//  KLTTouchPoint2.0
//
//  Created by Sameer Siddiqui on 3/7/18.
//  Copyright © 2018 Raul Silva. All rights reserved.
//

import UIKit

class KLTNewsFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.newsImage.image = UIImage.init(named: "walkthrough1")
        self.newsTitle.text = "Here's a headline for TouchPoint that is currently being used by Abbvie Pharmacuticles"
        self.newsDescription.text = "Here is a description of the article that TouchPoint is using yada Yada Yada lorem ipsum dolores grant"
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
