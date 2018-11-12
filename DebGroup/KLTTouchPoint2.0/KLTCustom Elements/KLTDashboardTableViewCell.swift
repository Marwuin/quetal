//
//  KLTDashboardTableViewCell.swift
//  OpenTab
//
//  Created by Raul Silva on 7/12/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol KLTdashboardTableCellDelegate:class {
    func didSelectDashboardTableItem(tagID: Int?, item: Item?)
}
class KLTDashboardTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, dashboardIconDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: -Vars
    weak var delegate:KLTdashboardTableCellDelegate?
    var itemOffset = 0.0
    var items = [Item]()
    var tags = [Tag]()
    //MARK: -IBOutlets
    @IBOutlet weak var itemsCollection: UICollectionView!
    
    
    //MARKL -View funcs
    override func awakeFromNib() {
        super.awakeFromNib()
        itemsCollection.register(UINib(nibName: "KLTDashboardCollectionViewCell", bundle: frameworkBundle), forCellWithReuseIdentifier: "dashboardViewCellIdentifier")
        itemsCollection.delegate = self
        itemsCollection.dataSource = self
    }
    
    override func layoutSubviews() {
        itemsCollection.reloadData()
    }
    
    //MARK: -Funcs
    func didSelectDashboardItemToView(tagID: Int?, item: Item?) {
         self.delegate?.didSelectDashboardTableItem(tagID: tagID, item: item)
    }

    //MARK: -Collection funcs
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(self.items.count, self.tags.count)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dashboardViewCellIdentifier", for: indexPath) as! KLTDashboardCollectionViewCell
        if(items.count != 0){//This must be an items row, let's treat it as such…
            if(indexPath.row < (items.count)){
                
                let isDownloaded = kltMediaBase!.isThumbnailDownloaded(item: items[indexPath.row])
                var url: URL?
                if isDownloaded {
                    url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: "thumbnail_\(items[indexPath.row].id!).jpg")
                    cell.thumbnail.af_setImage(withURL:  url!, placeholderImage: UIImage.init(named: "brokenLink"), filter: nil, progress: nil, progressQueue: .main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: { (response) in
                    })
                }
                else {
                    if let _ = items[indexPath.row].thumbnail{
                        url = URL.init(string: items[indexPath.row].thumbnail!)
                        cell.thumbnail.af_setImage(withURL:  url!, placeholderImage: UIImage.init(named: "brokenLink"), filter: nil, progress: nil, progressQueue: .main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: { (response) in
                        })
                    }
                    else {
                        cell.thumbnail.image = UIImage.init(named: "brokenLink")
                    }
                    
                }
                
               
                cell.delegate = self
                cell.label.text = "\(items[indexPath.row].title!)"
                cell.itemID = items[indexPath.row].id
                cell.item = items[indexPath.row]
            }
        }
        else {//This must me a library row, let's treat it as such…
            if indexPath.row < (tags.count) {
                if  tags[indexPath.row].thumbnail != nil {
                    let imgString = tags[indexPath.row].thumbnail!
                    
                    
                    let isDownloaded = kltMediaBase!.isTagThumbnailDownloaded(tag: tags[indexPath.row])
                    var url: URL?
                    if isDownloaded {
                        url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: "thumbnail_\(tags[indexPath.row].thumbMediaID!).jpg")
                    }
                    else {
                        url = URL.init(string: imgString)
                    }
                    
                    cell.thumbnail.af_setImage(withURL:  url!, placeholderImage: UIImage.init(named: "brokenLink"), filter: nil, progress: nil, progressQueue: .main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: { (response) in
                        
                        
                    })
                }
                else {
                  cell.thumbnail.image = #imageLiteral(resourceName: "brokenLink")
                }
            
                
                cell.tagID = tags[indexPath.row].tagID
                cell.label.text = "\(tags[indexPath.row].name!)"
                cell.delegate = self
            }
        }
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  CGSize(width: itemThumbnailWidth, height: itemThumbnailHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
