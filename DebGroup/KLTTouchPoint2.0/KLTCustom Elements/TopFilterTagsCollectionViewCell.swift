//
//  TopFilterTagsCollectionViewCell.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/17/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol topFilterCellDelegate {
    func didSelectTagCell(tagID: Int)
    func didDeselectTagCell(tagID: Int)

}

class TopFilterTagsCollectionViewCell: UICollectionViewCell {
    
    var tagID:Int?
    var celltag:Tag?
    var isOnFinder: Bool?
    var delegate: topFilterCellDelegate?
    
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        //colorTagNoSelected
        self.backgroundColor = UIColor.init(red: 27/255, green: 120/255, blue: 182/255, alpha: 1)
    }
    //UIColor.init(red: 27/255, green: 120/255, blue: 182/255, alpha: 0.6)
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.masksToBounds = true
                self.layer.cornerRadius = 10
                self.backgroundColor = .white
                self.label.textColor = UIColor.init(red: 22/255, green: 60/255, blue: 103/255, alpha: 1.0)
            }
            else {
//                if celltag!.isUserTag! {
//                    self.backgroundColor = UIColor.init(red: 89/255, green: 195/255, blue: 248/255, alpha: 1)
//                }
//                else {
                //colorTagNoSelected
                    self.backgroundColor = UIColor.init(red: 27/255, green: 120/255, blue: 182/255, alpha: 1)
//                }
                self.label.textColor = .white
            }
        }
        
    }
    
    
    
    @IBAction func tagPressed(_ sender: UIButton) {
        if self.isSelected {
            self.isSelected = false
            
            if self.isOnFinder! {
                KLTManager.sharedInstance.selectedTags.remove(at: KLTManager.sharedInstance.selectedTags.index(of: tagID!)!)
            }
            else {
                self.delegate?.didDeselectTagCell(tagID: tagID!)
            }
        }
        else {
            self.isSelected = true
            
            if self.isOnFinder! {
                KLTManager.sharedInstance.selectedTags.append(tagID!)
            }
            else {
                self.delegate?.didSelectTagCell(tagID: tagID!)
            }
        }
    }
    
  
}
