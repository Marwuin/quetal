//
//  KLTFinder.swift
//  OpenTab
//
//  Created by Raul Silva on 6/22/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import ENMBadgedBarButtonItem
import AlamofireImage
import SwiftyJSON

class KLTFinder: UIViewController, scrollingMenuDelegate, slotMachineMenuDelegate, UICollectionViewDelegate, UICollectionViewDataSource, iconDelegate, UICollectionViewDelegateFlowLayout, AVPlayerViewControllerDelegate, kltBadgedButtonDelegate, KLTDownloadManagerDelegate, ScrollingMenuCollectionViewDelegate  {

    //MARK: -Vars
    var slotmachineLabel:UILabel?
    var selectedItem:Item?
    var prefilterTagId:Int?
    var oldContentOffset: CGPoint = .zero
    var lastScrollViewContentOffset: CGFloat?
    var favFilter = false
    var selectMode = false
    var allCategories = false
    var topFIlterTagsCollection: TopFilterTagsCollectionView!


    fileprivate var brandFilters = [Int]()
    fileprivate var categoryFilter = Int()
    fileprivate var filteredItemsIDArray = [Int]()
    
    let topConstraintRange = (CGFloat(60)..<CGFloat(240))
    let topFilterHeightAnimationDuration = 0.7
    let topFilterTextAnimationDuration   = 0.3
    let defaultTopFilterButtonText = "Select tags to filter your search"
    
    var mailbagButton = KLTBadgedNavBarButton()
    
    //MARK: -IBOUtlets
    
    @IBOutlet weak var slotContainerView: UIView!
    @IBOutlet weak var brandsScroller: UIView!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var topFilter: UIView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var topFilterHeight: NSLayoutConstraint!
    @IBOutlet weak var viewStyle: UISegmentedControl!
    @IBOutlet weak var favIndicator: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryPicker: KLTSlotMachineMenu!
    @IBOutlet weak var scrollingMenuOne: KLTScrollingMenu!
    @IBOutlet weak var fabButton: UIButton!
    @IBOutlet weak var topFilterMainButton: UIButton!

    //MARK: -Class funcs
    public class func create() -> KLTFinder {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        return main as! KLTFinder
    }
    
    //MARK: -View funcs
    
    override func viewDidAppear(_ animated: Bool) {

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          self.refreshCollectionView()
        if prefilterTagId != nil {
            KLTManager.sharedInstance.selectedTags = [prefilterTagId!]
            self.didSelectTags()
        }
        else {
            KLTManager.sharedInstance.selectedTags = []
//            if let user =  KLTManager.sharedInstance.currentUser {
//                user.selectedTags = []
//            }
            
        }
        topFIlterTagsCollection.reload()
    }

    @objc func appMovedToBackground() {
        self.spinnerView.isHidden = false
        self.spinner.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KLTDownloadManager.sharedInstance.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshCollectionView),
                                               name: NSNotification.Name(rawValue: "mailbagChange"),
                                               object: nil)
        collectionView.isHidden = false
        
        self.updateMailbagButton()
        self.setupTopFilter()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: width / 3, height: width / 2.2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        
        categoryPicker.delegate = self
        
        let nib = UINib(nibName: "KLTIconCollectionViewCell", bundle: frameworkBundle)
        collectionView.register(nib, forCellWithReuseIdentifier: "iconCollectionViewCellIdentifier")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        categoryPicker.pickerData = KLTManager.sharedInstance.kltCategoriesData
        
        brandFilters = []
        for brand in KLTManager.sharedInstance.kltBrandsData{
            brandFilters.append(brand.tagID!)
        }
        
        let pickerSelectionIndex = categoryPicker.picker.selectedRow(inComponent: 0)
//        categoryFilter = KLTManager.sharedInstance.kltCategoriesData[pickerSelectionIndex].tagID!
        scrollingMenuOne.delegate = self
        
        if self.favFilter {
            self.favIndicator.alpha = 1
        }
        else {
            self.favIndicator.alpha = kltGlobalDisabledTransparency
        }
        
        if self.prefilterTagId != nil {
            let tags = KLTManager.sharedInstance.kltTagsData
            let preTag = tags.filter{$0.tagID == prefilterTagId }
            if preTag.count > 0{
                KLTManager.sharedInstance.selectedTags = [preTag[0].tagID!]
            }
        }
        else{
            KLTManager.sharedInstance.selectedTags = []

//            if let user = KLTManager.sharedInstance.currentUser {
//                user.selectedTags = []
//            }
        }
        
        self.filterData()

        
        mailbagButton = KLTBadgedNavBarButton()
        self.mailbagButton.delegate = self
        
        self.selectedButtonSet()
        self.refreshCollectionView()
        
        self.allButton.alpha = kltGlobalDisabledTransparency
        
        //autoselect center item in picker
        for tag in KLTManager.sharedInstance.kltCategoriesData {
            if tag.isCenter == true {
                let index = KLTManager.sharedInstance.kltCategoriesData.index(of: tag)
                self.categoryPicker.picker.selectRow(index!, inComponent: 0, animated: false)
                self.categoryPicker.pickerView(self.categoryPicker.picker, didSelectRow: index!, inComponent: 0)
            }
        }
        let notificationCenter = NotificationCenter.default
 
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        

        self.spinnerView.isHidden = true
        self.spinner.stopAnimating()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatus
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ItemDetailViewControllerSegue" {
            let itemDetailView = segue.destination as! KLTItemDetailViewController
            itemDetailView.myName = self.selectedItem?.title
            itemDetailView.item = self.selectedItem
        }
        if segue.identifier == "finderToProduct" {
            let productDetailView = segue.destination as! KLTProductViewController
            productDetailView.item = self.selectedItem
        }
        if segue.identifier == "scrollingMenuEmbed" {
            let scrollingmenu = segue.destination as! KLTScrollingMenuCollectionViewController
            scrollingmenu.delegate = self
        }
        
    }
}

//MARK: - IBActions
extension KLTFinder {
    
    @IBAction func fabPressed(_ sender: UIButton) {
        self.favFilter = !self.favFilter
        if self.favFilter {
            self.favIndicator.alpha = 1
        }
        else{
            self.favIndicator.alpha = kltGlobalDisabledTransparency
        }
        self.filterData()
    }
    
    @IBAction func allPressed(_ sender: UIButton) {
        self.toggleAllCats()
    }
    
}

//MARK: - Funcs
extension KLTFinder {
    
    func selectedButtonSet(){
        let selectButton = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.plain, target: self, action: #selector(selectPressed))
        selectButton.width = 60
        self.navigationItem.setRightBarButtonItems([ selectButton, mailbagButton], animated: false)
    }
    
    func cancelButtonSet(){
        let selectButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPressed))
        selectButton.width = 60
        self.navigationItem.setRightBarButtonItems([ selectButton, mailbagButton], animated: false)
    }
    
    @objc func cancelPressed(){
        self.selectMode = false
        self.selectedButtonSet()
        self.collectionView.reloadData()
    }
    
    @objc func selectPressed(){
        self.selectMode = true
        self.cancelButtonSet()
        self.collectionView.reloadData()
    }
    
    func toggleAllCats() {
        allCategories = !allCategories
        if allCategories {
            self.allButton.isUserInteractionEnabled = false
            self.allButton.alpha = 1
            self.categoryPicker.hideMySelection()
        }
        else{
            self.allButton.isUserInteractionEnabled = true
            self.allButton.alpha = kltGlobalDisabledTransparency
            self.categoryPicker.showMySelection()
        }
        self.filterData()
    }
    
    fileprivate func filterData() {
        
        filteredItemsIDArray = [Int]()
        
        for item in  KLTManager.sharedInstance.kltItemsData{ //For each item…
            
            if item.tags != nil {//Prevent crash from nul tags attribute from json
                
                if (item.isFavorite! || !self.favFilter) {//Is it a fav and is fav filter on?…
                    
                    if ((item.tags?.contains(categoryFilter))! || allCategories) {//Does it match the selected category?
//                        var containsBrand: Bool = false
                        
                        for brandID in self.brandFilters {//…for each of the selected brands…
                            
                            if (item.tags?.contains(brandID))! {//&& !containsBrand{//Does the item match the brand?
                                
//                                containsBrand = true
//                                if let user = KLTManager.sharedInstance.currentUser {
                                    if KLTManager.sharedInstance.selectedTags.count > 0 {//Do we need to further filter by selected tags?
                                        
                                        for tagFilter in KLTManager.sharedInstance.selectedTags{
                                            
                                            if ((item.tags?.contains(tagFilter))!){
                                                filteredItemsIDArray.append(item.id!)
                                                filteredItemsIDArray = filteredItemsIDArray.unique()
                                                
                                            }
                                        }
                                        
                                    }
                                    else {//There are no selected tags so just show our item
                                        filteredItemsIDArray.append(item.id!)
                                        filteredItemsIDArray = filteredItemsIDArray.unique()
                                        
                                        break
                                    }
//                                }
                               
                            }
                        }
                        
                    }
                }
            }
        }
        
        filteredItemsIDArray.sort()
        
        self.sendFilteringToAnalytics()
        self.collectionView.reloadData()
    }
    
    private func sendFilteringToAnalytics(){
        var details = [[String:Int]]()
        for detail in KLTManager.sharedInstance.selectedTags{
            details.append(["ValueTypeID":1001,"ValueInt":detail])
        }
        KLTAnalytics.eventFired(type: KLTAnalytics.EventTypes.filter, eventDetails: JSON(details))
    }
    
    @objc fileprivate func refreshCollectionView(){
        collectionView.reloadData()
        self.updateMailbagButton()
    }
    
    fileprivate func updateMailbagButton(){
        mailbagButton.updateCount(value: KLTManager.sharedInstance.mailbagItems.count)
    }
    
}

//MARK: -Collection View
extension KLTFinder {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  filteredItemsIDArray.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemThumbnailWidth, height: itemThumbnailHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCollectionViewCellIdentifier", for: indexPath) as! KLTIconCollectionViewCell
        cell.myItem = KLTManager.sharedInstance.kltItemsData.filter{$0.id == filteredItemsIDArray[indexPath.item]}[0]
        cell.overlay.isHidden = !KLTManager.sharedInstance.currentUser!.selectedItems.contains((cell.myItem?.id)!)

        if(KLTManager.sharedInstance.currentUser!.favItems.contains((cell.myItem?.id)!)){
            (cell.fabButton.tintColor = cbSelectedStateButtonTint)
            (cell.fabButton.setImage(#imageLiteral(resourceName: "fav"), for: UIControlState.normal))
        }
        else{
            (cell.fabButton.tintColor = cbDeselectedStateButtonTint)
            (cell.fabButton.setImage(#imageLiteral(resourceName: "unfav"), for: UIControlState.normal))
        }
        
        if(KLTManager.sharedInstance.mailbagItems.contains((cell.myItem?.id)!)){
            (cell.mailbagButton.tintColor = UIColor(red: 249/255, green: 199/255, blue: 87/255, alpha: 1))
            cell.mailbagButton.setImage(#imageLiteral(resourceName: "envelopeSelected"), for: UIControlState.normal)
        }
        else{
            ( cell.mailbagButton.tintColor = cbDeselectedStateButtonTint)
            cell.mailbagButton.setImage(#imageLiteral(resourceName: "envelope"), for: UIControlState.normal)
        }
        
        
        if let urlString = cell.myItem?.thumbnail{
            let isDownloaded = kltMediaBase!.isThumbnailDownloaded(item: cell.myItem!)
            var url: URL?
            if isDownloaded {
                url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: "thumbnail_\(cell.myItem!.id!).jpg")
            }
            else {
                url = URL.init(string: urlString)
            }
            let placeholderImage = #imageLiteral(resourceName: "brokenLink")
            cell.icon.af_setImage(withURL: url!, placeholderImage: placeholderImage)
        }else{
            cell.icon?.image = #imageLiteral(resourceName: "brokenLink")
        }
        
        cell.container.frame.size = cell.frame.size
        cell.icon.frame.size = cell.frame.size
        cell.label.text =   cell.myItem!.title
        cell.nameLabel.text = "\(cell.myItem!.title!)"
        cell.label.frame.size.width = cell.frame.size.width - 16
        cell.delegate = self
        if self.selectMode{
            cell.overlay.isHidden = false
            cell.overlayDidMoveOntop()
        }
        return cell
    }
}

//MARK: - Delegation

extension KLTFinder {
    
    func didSelectBrand(brand: Tag) {
        let ind = brand.tagID!
        if (self.brandFilters.filter {$0 == ind}.count > 0){
            brandFilters = self.brandFilters.filter {$0 != ind}
        }
        else{
            brandFilters.append(ind)
        }
        brandFilters.sort()
        self.filterData()
        collectionView.reloadData()
    }
    
    func didSelectMultipleBrands(brands: [Tag]) {
        for brand in brands {
            let ind = brand.tagID!
            if (self.brandFilters.filter {$0 == ind}.count > 0){
                brandFilters = self.brandFilters.filter {$0 != ind}
            }
            else{
                brandFilters.append(ind)
            }
            brandFilters.sort()
            self.filterData()
        }
        collectionView.reloadData()

//        brandFilters.sort()
//        self.filterData()
//        collectionView.reloadData()
    }
    
    func didDownloadData() {
                self.spinnerView.isHidden = true
                self.spinner.stopAnimating()
    }
    
    func didSelectBadgedButton(sender: UIButton) {
    }
    
    func didSelectToViewDocument(item: Item) {
        KLTAnalytics.eventFired(type: KLTAnalytics.EventTypes.viewItem, valueTypeID: 1000, value: (item.id)!)
        self.selectedItem = item
        switch item.itemType {
        case .pdf?:
            performSegue(withIdentifier: "ItemDetailViewControllerSegue", sender: index)
        case .video?:
            let player = KLTVideoPlayer.init()
            player.playVideo(with: item)
        case .product?:
            performSegue(withIdentifier: "finderToProduct", sender: index)
        default:
            debugPrint("No matching media type found")
        }
    }
    
    func didSelectSlotMachineItem(index: Int) {
        if allCategories {
            self.toggleAllCats()
            self.categoryPicker.alpha = 1
        }
        categoryFilter = KLTManager.sharedInstance.kltCategoriesData[index].tagID!
        self.filterData()
    }
    
    func didSelectItemFromScrollingMenu(button: UIButton) {
        let ind = button.tag//scrollingMenuOne.scrollView.subviews.index(of: button)! + 1
        
        if (self.brandFilters.filter {$0 == ind}.count > 0){
            brandFilters = self.brandFilters.filter {$0 != ind}
        }
        else{
            brandFilters.append(ind)
        }
        brandFilters.sort()
        self.filterData()
        collectionView.reloadData()
    }
}

//MARK: - Top filter
extension KLTFinder: TopFilterTagsDelegate {
    
    func setupTopFilter() {
        topFilterHeight.constant = topConstraintRange.lowerBound
        topFIlterTagsCollection = TopFilterTagsCollectionView.instanceFromNib()
        topFIlterTagsCollection.delegate = self
        topFIlterTagsCollection.fromFinder = true
        topFilter.addSubview(topFIlterTagsCollection)
        topFIlterTagsCollection.translatesAutoresizingMaskIntoConstraints = false
        topFIlterTagsCollection.topAnchor.constraint(equalTo: topFilter.topAnchor, constant: 10).isActive = true
        topFIlterTagsCollection.bottomAnchor.constraint(equalTo: topFilter.bottomAnchor, constant: -10).isActive = true
        topFIlterTagsCollection.leftAnchor.constraint(equalTo: topFilter.leftAnchor, constant: 8).isActive = true
        topFIlterTagsCollection.rightAnchor.constraint(equalTo: topFilter.rightAnchor, constant: -8).isActive = true
        topFIlterTagsCollection.alpha = 0
        
        topFilterButtonSetup(button: self.topFilterMainButton, text: defaultTopFilterButtonText, imageName: "tagSearch")
    }
    
    func topFilterButtonSetup(button: UIButton, text: String, imageName: String) {
        button.contentHorizontalAlignment = .left
        button.setAttributedTitle(NSAttributedString.init(string: text, attributes: filterTextAttributes), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 18,bottom: 0,right: 0)
        button.setImage(UIImage(named:imageName), for: .normal)
        button.setImage(UIImage(named:imageName), for: .highlighted)
        button.imageEdgeInsets = UIEdgeInsets(top: 6,left: 8,bottom: 6,right: 0)
        button.backgroundColor = UIColor.init(red: 27/255, green: 120/255, blue: 182/255, alpha: 0.6)
    }
    
    func changeFilterHeight(isExpanded: Bool) {
        topFilterHeight.constant = isExpanded ? topConstraintRange.lowerBound : topConstraintRange.upperBound
        animateTopFilterHeight()
        animateTopFilterViews(isExpanded: isExpanded)
    }
    
    func animateTopFilterHeight() {
        UIView.animate(withDuration: topFilterHeightAnimationDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveLinear, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func animateTopFilterViews(isExpanded: Bool) {
        let mainAlpha: CGFloat = isExpanded ? 0 : 1
        let oppositeAlpha: CGFloat = isExpanded ? 1 : 0
        var mainButtonText = String()
        
        if (KLTManager.sharedInstance.selectedTags.isEmpty) {
            mainButtonText = defaultTopFilterButtonText
        }
        else {
            var mainButtonText = ""
            for tag in KLTManager.sharedInstance.kltTagsData{
                
                mainButtonText = mainButtonText + tag.name! + ", "
            }
        }
        
        if !isExpanded {
            self.topFIlterTagsCollection.isHidden = isExpanded
        }
        
        UIView.transition(with: self.topFilterMainButton, duration: topFilterTextAnimationDuration, options: .transitionCrossDissolve, animations: {
            self.topFilterMainButton.setAttributedTitle(NSAttributedString.init(string: mainButtonText, attributes: filterTextAttributes), for: .normal)
            self.topFilterMainButton.alpha = oppositeAlpha
            self.topFIlterTagsCollection.alpha = mainAlpha
        }) {
            (completion) in
            self.topFIlterTagsCollection.isHidden = isExpanded
        }
    }
    
    @IBAction func topFilterMainButtonPressed(_ sender: Any) {
        if topFilterHeight.constant > 100 {
            self.changeFilterHeight(isExpanded: true)
        }
        else {
            self.changeFilterHeight(isExpanded: false)
        }
    }
    
    func topFilterDoneButtonPressed() {
        self.changeFilterHeight(isExpanded: true)
    }
    
    func topFilterDoneWithTagIDs(tagIDs: [Int]) {
        
    }
    
    func didSelectTags() {
        var composedString = ""
        for (index,tagID) in KLTManager.sharedInstance.selectedTags.enumerated(){
            let tagArray = KLTManager.sharedInstance.kltTagsData.filter{$0.tagID! == tagID}
            if (tagArray.count > 0){
            composedString.append(tagArray[0].name!)
            if(index < KLTManager.sharedInstance.selectedTags.count-1){
                composedString.append(", ")
            }
            }else{
                 composedString = defaultTopFilterButtonText
            }
        }
        if composedString == "" {
            composedString = defaultTopFilterButtonText
        }
        self.topFilterMainButton.setAttributedTitle(NSAttributedString.init(string: composedString, attributes: filterTextAttributes), for: .normal)
        
        self.filterData()
    }
}
