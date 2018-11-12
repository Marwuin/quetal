//
//  KLTBadgedNavBarButton.swift
//  OpenTab
//
//  Created by Raul Silva on 8/19/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol kltBadgedButtonDelegate:class {
    func didSelectBadgedButton(sender:UIButton)
}

class KLTBadgedNavBarButton: UIBarButtonItem {
    weak var delegate:kltBadgedButtonDelegate?
    private let badge = UILabel(frame: CGRect(x: 20, y: 5, width: 20, height: 20))
    private let buttonComponent = UIButton(type: UIButtonType.custom)
    
    override init() {
        super .init()
        buttonComponent.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        buttonComponent.setImage(#imageLiteral(resourceName: "envelope"), for: UIControlState.normal)
        badge.layer.cornerRadius = badge.frame.size.width/2
        badge.clipsToBounds = true
        badge.backgroundColor = UIColor(red: 249.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)//UIColor.red
        badge.textColor = UIColor.black//UIColor.white
        badge.font = UIFont(name: "HelveticaNeue", size: 12)
        badge.textAlignment = .center
        buttonComponent.addSubview(badge)
        buttonComponent.addTarget(self, action:#selector(buttonSelected(sender:)), for: .touchUpInside)
        self.customView = buttonComponent
        self.updateCount(value: 0)
    }
    
    func updateCount(value:Int){
        if(value < 1){
            self.badge.isHidden = true
            buttonComponent.isEnabled = false
        }else{
              self.badge.isHidden = false
            self.badge.text = String(value)
            buttonComponent.isEnabled = true
        }
    }
    
    @objc private func buttonSelected(sender:UIButton!){
        DispatchQueue.main.async {
            let vc = KLTMailbagViewController.create()
            UIViewController.top?.navigationController?.pushViewController(vc, animated: true)
//            self.delegate?.didSelectBadgedButton(sender: sender)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
