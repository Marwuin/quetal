//
//  TopFilterTagsCollectionView.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/17/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol TopFilterTagsDelegate {
    func topFilterDoneButtonPressed()
    func topFilterDoneWithTagIDs(tagIDs:[Int])
    func didSelectTags()
}

class TopFilterTagsCollectionView: UIView, topFilterCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIButton!
    
    var delegate: TopFilterTagsDelegate?
    var filterTagAttributes: [NSAttributedStringKey: Any]?
    var userDefinedTagsOnly = false
    var fromFinder = false
    var currentItem: Item?
    
    var selectedCreatedTags: [Int] = []
    
    class func instanceFromNib() -> TopFilterTagsCollectionView {
        return UINib(nibName: "TopFilterTagsCollectionView", bundle: frameworkBundle).instantiate(withOwner: nil, options: nil)[0] as! TopFilterTagsCollectionView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.reload()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(UINib.init(nibName: "   ` TopFilterTagsCollectionViewCell", bundle: frameworkBundle), forCellWithReuseIdentifier: "topTagsCell")
        //colorTagNoSelected
        self.backgroundColor = UIColor.init(red: 27/255, green: 120/255, blue: 182/255, alpha: 0.6)
        collectionView.backgroundColor = .clear
        
        let layout = AlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.horizontalAlignment = .left
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 0, right: 10)
        collectionView.collectionViewLayout = layout
        
        doneButton.backgroundColor = UIColor.init(red: 22/255, green: 60/255, blue: 103/255, alpha: 1.0)
        doneButton.setAttributedTitle(NSAttributedString.init(string: "Done", attributes: filterTextAttributes), for: .normal)
        if  UIDevice().screenType == .unknown {
            filterTagAttributes = iPadfilterTextAttributes
        }
        else {
            filterTagAttributes = filterTagTextAttributes
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.delegate?.topFilterDoneButtonPressed()
        self.delegate?.didSelectTags()
        self.delegate?.topFilterDoneWithTagIDs(tagIDs: selectedCreatedTags)
    }
    
    func reload() {
        self.collectionView.reloadData()
    }
    
    func didSelectTagCell(tagID: Int) {
        selectedCreatedTags.append(tagID)
    }
    
    func didDeselectTagCell(tagID: Int) {
        if selectedCreatedTags.count > 0 {
            //weve selected tags and havent sent them to the server
            selectedCreatedTags.remove(at: selectedCreatedTags.index(of: tagID)!)
        }
        else {
            //weve already sent to the server and are now deselecting tags
            ///Send to the server the fact that its unselected
            
            if let _ = currentItem {
                if currentItem!.tags!.contains(tagID) {
                    currentItem!.tags!.remove(at: currentItem!.tags!.index(of: tagID)!)
                }
            }
        }
    }
}

extension TopFilterTagsCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.userDefinedTagsOnly){
            let indexes = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == true}
            return indexes.count
        }else{
            return KLTManager.sharedInstance.kltTagsData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //TagPool is used to restric the tags to be displayed only to those that match the user defined type
        var tagPool = [Tag]()
        
        if self.userDefinedTagsOnly {
           tagPool = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == true}
        }
        else
        {
            let userTags = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == true}
            tagPool = tagPool + userTags
            let nonUserTags = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == false}
            tagPool =  tagPool + nonUserTags
            //tagPool = tagPool.sorted(by: {$0.isUserTag! && !$1.isUserTag!}) //Sort array with user tags first
        }
        let tag = tagPool[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topTagsCell", for: indexPath) as! TopFilterTagsCollectionViewCell
        
        cell.celltag = tag
        cell.isOnFinder = fromFinder
        cell.tagID = tag.tagID
        cell.delegate = self
        cell.label.attributedText = NSAttributedString.init(string: tag.name!, attributes: filterTagAttributes)
        
        if tag.isUserTag == true {
            //celeste
            cell.backgroundColor = UIColor.init(red: 89/255, green: 195/255, blue: 248/255, alpha: 1)
        }
        
        if KLTManager.sharedInstance.selectedTags.contains(tag.tagID!) {
            cell.isSelected = true
        }
        
        if let item = currentItem {
            for itemTag in item.tags! {
                if itemTag == tag.tagID! {
                    cell.isSelected = true
                }
            }
        }
        
        if selectedCreatedTags.contains(tag.tagID!) {
            cell.isSelected = true
        }
        
        let myString: NSString = tag.name! as NSString
        
        let size: CGSize = myString.size(withAttributes: filterTagAttributes)
        cell.label.sizeThatFits(size)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        var tagPool = [Tag]()
        
        if self.userDefinedTagsOnly {
            tagPool = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == true}
        }
        else{
            let userTags = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == true}
            tagPool = tagPool + userTags
            let nonUserTags = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == false}
            tagPool =  tagPool + nonUserTags
        }
        
        let tag = tagPool[indexPath.row]
        
        
        if let tag = tag.name {
            let myString: NSString = tag as NSString
            var size: CGSize = myString.size(withAttributes: filterTagAttributes)
            size.width = size.width + 10
            size.height = size.height + 10
            return size
        }
        return CGSize(width: 0, height: 0)
    }
    
}
