//
//  KLTScrollingMenu.swift
//  OpenTab
//
//  Created by Raul Silva on 7/6/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

// A simple scroll view to select one of many icons to use
// as data filtering criteria

import UIKit
import AlamofireImage

protocol scrollingMenuDelegate:class {
    func didSelectItemFromScrollingMenu(button:UIButton)
}

class KLTScrollingMenu: UIView, UIScrollViewDelegate {
    //MARK: -Vars
    weak var delegate:scrollingMenuDelegate?
    var scrollView = UIScrollView()
    var radius = 0
    //let selectedAlpha:CGFloat = 0.8
    let deselectedAlphga:CGFloat = kltGlobalDisabledTransparency
    let width = (UIScreen.main.bounds.size.width / CGFloat(KLTManager.sharedInstance.kltBrandsData.count))
    //MARK: -View Funcs
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     //   self.createMenu()
    }
    override func layoutSubviews() {
        var mySpace = (UIScreen.main.bounds.size.width / CGFloat(KLTManager.sharedInstance.kltBrandsData.count))
        if(mySpace < width){
            mySpace = width
        }
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 100)
        if(UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight){
            scrollView.contentSize = CGSize(
                width: ((width + mySpace) *  (CGFloat(KLTManager.sharedInstance.kltBrandsData.count))) + (mySpace / 2),
                height: width)
        }else{
            scrollView.contentSize = CGSize(
                width: width * CGFloat(KLTManager.sharedInstance.kltBrandsData.count),
                height: width)
        }
        
        for (index,button) in scrollView.subviews.enumerated() {
            button.frame = CGRect(
                x: (mySpace) * CGFloat(index) ,
                y: 0.0,
                width: (UIScreen.main.bounds.size.width) / CGFloat(KLTManager.sharedInstance.kltBrandsData.count),
                height: self.scrollView.frame.size.height)
            
            
        }
    }
    //MARK: -Funcs
    @objc func buttonClicked(sender:UIButton!){
        
        if sender.isSelected {
            // sender.alpha = deselectedAlphga
            sender.tintColor = UIColor.darkGray
            sender.backgroundColor = UIColor.clear
            sender.isSelected = false
        } else {
            //  sender.alpha = selectedAlpha
            sender.tintColor = UIColor.white
            let sb = sender as! KLTTopCategoryButton
            sender.backgroundColor =  sb.bgColor
            sender.isSelected = true
        }
        self.delegate?.didSelectItemFromScrollingMenu(button: sender)
    }
    private func loadButtons(){
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        var mySpace = (UIScreen.main.bounds.size.width / CGFloat(KLTManager.sharedInstance.kltBrandsData.count)) - CGFloat(width)
        if(mySpace < 0){
            mySpace = width
        }
        for (index,brandData) in KLTManager.sharedInstance.kltBrandsData.enumerated(){
            let button = KLTTopCategoryButton()
            print(brandData)
            if let tagID = brandData.tagID {
                button.tag = tagID
            }
            button.isSelected = true
            button.layer.borderColor = UIColor.white.cgColor
            button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
            // button.alpha = selectedAlpha
            if(brandData.iconURL == nil){
                button.setTitle("\(brandData.name!)", for: UIControlState.normal)
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight(rawValue: 2))
            }
            else{
                let isDownloaded = kltMediaBase!.isTagThumbnailDownloaded(tag: KLTManager.sharedInstance.kltBrandsData[index])
                var url: URL?
                if isDownloaded {
                    url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: "thumbnail_\(KLTManager.sharedInstance.kltBrandsData[index].iconMediaID!).jpg")
                }
                else {
                    url = URL.init(string: KLTManager.sharedInstance.kltBrandsData[index].iconURL!)
                }
                button.af_setImage(for: .normal, url:url!, filter: DynamicImageFilter.init("TemplateImageFilter", filter: { (image) -> Image in
                    return image.withRenderingMode(.alwaysTemplate)
                }))
                if let bgColor = brandData.backgroundColor{
                    button.bgColor = bgColor
                    button.backgroundColor = button.bgColor
                }
                
                
                button.layer.cornerRadius = CGFloat(radius)
                button.tintColor = UIColor.white
                if let brandBGColor = brandData.backgroundColor{
                    button.setTitleColor(brandBGColor, for: UIControlState.normal)
                    
                }
                
            }
            scrollView.backgroundColor = UIColor.white //UIColor(red: 20.0/255.0, green: 59.0/255.0, blue: 105.0/255.0, alpha: 1.0)
            scrollView.addSubview(button)
            self.isUserInteractionEnabled = true
            scrollView.delegate = self
        }
    }
    private func createMenu(){
        self.loadButtons()
        self.addSubview(scrollView)
    }
}

