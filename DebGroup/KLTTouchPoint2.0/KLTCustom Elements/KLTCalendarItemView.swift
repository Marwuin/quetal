//
//  KLTCalendarItemView.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 9/12/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol calendarItemDelegate:class{
    func didSelectCalendarItem(tagID:Int)
}

class KLTCalendarItemView: UIView {
    weak var delegate:calendarItemDelegate?
    var tagID:Int?
    @IBAction func calendarItemSelected(_ sender: UIButton) {
        if(tagID != nil){
            self.delegate?.didSelectCalendarItem(tagID: tagID!)
        }else{
            debugPrint("No tag id to search by")
        }
    }
    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var title: UILabel!
}
