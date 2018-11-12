//
//  KLTTagsPopUpViewController.swift
//  OpenTab
//
//  Created by Sameer Siddiqui on 8/17/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

class KLTTagsPopUpViewController: UIViewController {

    var topFIlterTagsCollection: TopFilterTagsCollectionView!
    var associatedItem: Item!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tagsContainter: UIView!
    @IBOutlet weak var createTagsButton: UIButton!
    @IBOutlet weak var createTagsTextField: UITextField!
    
    public class func create() -> KLTTagsPopUpViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        return main as! KLTTagsPopUpViewController
    }
    
    class func showPopupModal(with item: Item) {
        let vc = KLTTagsPopUpViewController.create()
        vc.modalPresentationStyle = .overCurrentContext
        vc.associatedItem = item
        top?.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTagsCollectionToContainer()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createTagsButtonPressed(_ sender: Any) {

        if !(createTagsTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            let request = KLTMediaRequests.init()
            request.createTag(tagName: createTagsTextField.text!, completion: { (tagID, success, error) in
                
                if success {
                    let json = JSON(["Name" : self.createTagsTextField.text!, "TagID" : tagID!, "TypeID" : 3000, "IsUserTag" : true])
                    //typeID 3000 is hardcoded as a user defined typeid
                    
                    print("got tag id with id: \(tagID!)")
                    let tag = Tag.init(json:json)
                    KLTManager.sharedInstance.kltTagsData.append(tag)
                    self.topFIlterTagsCollection.reload()
                    self.createTagsTextField.text = ""
                    
                    
                    let tagPool = KLTManager.sharedInstance.kltTagsData.filter{$0.isUserTag == true}
                    let index = tagPool.index(of: tag)
                    

                    
                    let cell = self.topFIlterTagsCollection.collectionView(self.topFIlterTagsCollection.collectionView, cellForItemAt: IndexPath(item: index!, section: 0)) as! TopFilterTagsCollectionViewCell
                    
                    cell.tagPressed(cell.tagButton!)
                    
                    self.topFIlterTagsCollection.reload()

                
                }
                else {
                  self.showErrorAlert(message: "Could not create a tag at this time.\nPlease try again")
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                self.createTagsTextField.resignFirstResponder()
                
            })
            
           
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
    
    override public var prefersStatusBarHidden: Bool {
        return hideStatus
    }
}


extension KLTTagsPopUpViewController: TopFilterTagsDelegate {
    func addTagsCollectionToContainer() {
        topFIlterTagsCollection = TopFilterTagsCollectionView.instanceFromNib()
        topFIlterTagsCollection.currentItem = associatedItem
        topFIlterTagsCollection.userDefinedTagsOnly = true
        topFIlterTagsCollection.delegate = self
        tagsContainter.addSubview(topFIlterTagsCollection)
        topFIlterTagsCollection.translatesAutoresizingMaskIntoConstraints = false
        topFIlterTagsCollection.topAnchor.constraint(equalTo: tagsContainter.topAnchor).isActive = true
        topFIlterTagsCollection.bottomAnchor.constraint(equalTo: tagsContainter.bottomAnchor).isActive = true
        topFIlterTagsCollection.leftAnchor.constraint(equalTo: tagsContainter.leftAnchor).isActive = true
        topFIlterTagsCollection.rightAnchor.constraint(equalTo: tagsContainter.rightAnchor).isActive = true
    }
    
    func topFilterDoneButtonPressed() {
    
//        self.dismiss(animated: true, completion: nil)
    }
    
    func didSelectTags() {
        
    }
    
    func topFilterDoneWithTagIDs(tagIDs: [Int]) {

        for item in  KLTManager.sharedInstance.kltItemsData{//For each item…
            if item.id == associatedItem.id! {
                item.tags?.append(contentsOf: tagIDs)
            }
        }
        
        let request = KLTMediaRequests.init()
        request.tagMedia(tags: tagIDs, mediaId: associatedItem.id!) { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.showErrorAlert(message: "Could not tag the media item.\nPlease try again.")
            }
        }
    }
}


