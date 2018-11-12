//
//  KLTScrollingMenuCollectionViewController.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 12/11/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import AlamofireImage

protocol ScrollingMenuCollectionViewDelegate:class {
    func didSelectBrand(brand: Tag)
    func didSelectMultipleBrands(brands: [Tag])
}

class KLTScrollingMenuCollectionViewController: UICollectionViewController, ScrollingMenuCellDelegate {
    
    let reuseIdentifier = "Cell"
    var shownBrands     : [Tag] = Array()
    var unfilteredBrands: [Tag] = Array()
    weak var delegate: ScrollingMenuCollectionViewDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for brand in KLTManager.sharedInstance.kltBrandsData {
            if brand.isParent == true {
                shownBrands.append(brand)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shownBrands.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! KLTScrollingMenuCollectionViewCell
        cell.delegate = self
        cell.expandButton.tag = indexPath.row
        
        let brand = shownBrands[indexPath.row]
        let isDownloaded = kltMediaBase!.isTagThumbnailDownloaded(tag: brand)
        var url: URL?
        if isDownloaded {
            url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: "thumbnail_\(brand.iconMediaID!).jpg")
        }
        else {
            url = URL.init(string: brand.iconURL!)
        }
        
        cell.imageView.af_setImage(withURL: url!,filter: DynamicImageFilter.init("TemplateImageFilter", filter: { (image) -> Image in
            return image.withRenderingMode(.alwaysTemplate)
            }))
        
        cell.expandButton.isHidden = true
        cell.filterImage.isHidden = true
        cell.expandButton.setBackgroundImage(UIImage.init(named: "plus"), for: .normal)
       // cell.expandButton.setImage(UIImage.init(named: "plus"), for: .normal)
        
        if let subbrandIDs = brand.brandTags {
            var unfilteredCount = 0
            for brandID in subbrandIDs {
                for brand in shownBrands {
                    if brand.tagID == brandID {
                         cell.expandButton.setBackgroundImage(UIImage.init(named: "minus"), for: .normal)
                      //  cell.expandButton.setImage(UIImage.init(named: "minus"), for: .normal)
                    }
                }
                for brand in KLTManager.sharedInstance.kltBrandsData {
                    if brand.tagID! == brandID { //the brand is in the in the current subbrands
                        if unfilteredBrands.contains(brand) {
                            unfilteredCount = unfilteredCount + 1
                        }
                    }
                }
            }
            if unfilteredCount < subbrandIDs.count && unfilteredCount > 0 {
                cell.filterImage.isHidden = false
            }
            cell.expandButton.isHidden = false
        }
        
        if let bgColor = brand.backgroundColor {
            cell.backgroundColor = bgColor
        }
        cell.tintColor = .white
        
        for br in unfilteredBrands {
            if br == brand {
                cell.backgroundColor = .white
                cell.tintColor = .black
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let allBrands = KLTManager.sharedInstance.kltBrandsData
        let currentBrand = shownBrands[indexPath.row]
        
        if currentBrand.containsSubbrandIDs { //parent brand selected. Select or unselect subrands
            
            var subbrands: [Tag] = Array()

            if unfilteredBrands.contains(currentBrand) {
                unfilteredBrands.remove(at: unfilteredBrands.index(of: currentBrand)!)
                for brand in allBrands {
                    if currentBrand.brandTags!.contains(brand.tagID!) {
                        if unfilteredBrands.contains(brand) {
                            unfilteredBrands.remove(at: unfilteredBrands.index(of: brand)!)
                            subbrands.append(brand)
                        }
                    }
                }
            }
            else {
                unfilteredBrands.append(currentBrand)
                for brand in allBrands {
                    if currentBrand.brandTags!.contains(brand.tagID!) {
                        if !unfilteredBrands.contains(brand) {
                            unfilteredBrands.append(brand)
                            subbrands.append(brand)
                        }
                    }
                }
                
            }
            self.delegate?.didSelectMultipleBrands(brands: subbrands)
        }
        else {// subbrand selected, select or unselect parent brand
            
            if unfilteredBrands.contains(currentBrand) {
                unfilteredBrands.remove(at: unfilteredBrands.index(of: currentBrand)!)
            }
            else {
                unfilteredBrands.append(currentBrand)
            }
            
            var unfilteredbrandcount = 0
            brandloop: for brand in shownBrands {
                if brand.containsSubbrandIDs {
                    for brandID in brand.brandTags! {
                        for subbrand in allBrands {
                            if subbrand.tagID! == brandID {
                                if unfilteredBrands.contains(subbrand) {
                                    unfilteredbrandcount = unfilteredbrandcount + 1
                                }
                            }
                        }
                    }
                    if unfilteredbrandcount == brand.brandTags!.count {
                        unfilteredbrandcount = 0
                        if !unfilteredBrands.contains(brand) {
                            unfilteredBrands.append(brand)
                            break brandloop
                        }
                    }
                    else {
                        unfilteredbrandcount = 0
                        if unfilteredBrands.contains(brand) {
                            unfilteredBrands.remove(at: unfilteredBrands.index(of: brand)!)
                            break brandloop
                        }
                    }
                }
            }
            
            self.delegate?.didSelectBrand(brand: shownBrands[indexPath.row])
        }
        
        collectionView.reloadData()
    }
    
    func expandbuttonPressed(_ sender: Any) {
        
        let btn = sender as! UIButton
        let index = btn.tag
        
        if let subTags = shownBrands[index].brandTags {
            if shownBrands[index].isParent == true {
                for tagID in subTags.reversed() {
                    for brand in KLTManager.sharedInstance.kltBrandsData {
                        if brand.isParent == false {
                            if tagID == brand.tagID {
                                if shownBrands.contains(brand) {
                                    shownBrands.remove(at: shownBrands.index(of: brand)!)
                                }
                                else {
                                    shownBrands.insert(brand, at: index + 1)
                                }
                            }
                        }
                    }
                }
            }
        }
        collectionView?.reloadData()
    }

}
