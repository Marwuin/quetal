//
//  Finder.swift
//  OpenTab
//
//  Created by Raul Silva on 6/22/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class Finder: UIViewController, scrollingMenuDelegate, UITableViewDelegate, UITableViewDataSource, overviewItemDelegate, slotMachineMenuDelegate, UICollectionViewDelegate, UICollectionViewDataSource,iconDelegate  {
    
    func didSelectIcon(item: Item) {
        self.selectedItem = item
          performSegue(withIdentifier: "ItemDetailViewControllerSegue", sender: index)
    }
    
    
    func didSelectItem(index: Int) {
        categoryFilter = CategoriesData.getData()[index].id
        self.filterData()
        itemsTable.reloadData()
        collectionView.reloadData()
    }
    //MARK: - Vars
    var selectedItem:Item?
    var brandFilters = [Int]()
    var categoryFilter = Int()
    
    var filteredData = [Item]()
    //MARK: - IBOutlets
    @IBOutlet weak var viewStyle: UISegmentedControl!
    
    
    
    @IBAction func iconSegmentSelected(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        switch viewStyle.selectedSegmentIndex
        {
        case 0:
            collectionView.isHidden = true
            itemsTable.isHidden = false
        case 1:
            collectionView.isHidden = false
            itemsTable.isHidden = true
        default:
            break;
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var itemsTable: UITableView!
    @IBOutlet weak var categoryPicker: SlotMachineMenu!
    @IBOutlet weak var scrollingMenuOne: ScrollingMenu!
    //MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  filteredData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OverviewTableViewCellIdentifier", for: indexPath) as! OverviewTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.overviewTitle.text =  filteredData[indexPath.row].name
        cell.overviewBrief.text = filteredData[indexPath.row].description
        cell.myItem = filteredData[indexPath.row]
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ItemDetailViewControllerSegue", sender: indexPath)
    }
    //MARK: - Funcs
    private func filterData(){
        filteredData = [Item]()
        // var firstLevel = [Item]()
        for item in itemsData{
            for brandID in brandFilters{
                if(item.brands.filter{$0 == brandID}.count > 0){
                    if(item.marketIDs.filter{$0 == categoryFilter}.count > 0){
                        filteredData.append(item)
                        break
                    }
                    break
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     let cell = collectionView.cellForItem(at: indexPath) as! IconCollectionViewCell
        cell.overlay.isHidden = !cell.overlay.isHidden
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  filteredData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //http://lorempixel.com/200/200/
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCollectionViewCellIdentifier", for: indexPath) as! IconCollectionViewCell
        cell.myItem?.delegate = cell
                cell.delegate = self
        cell.overlay.isHidden = !self.filteredData[indexPath.row].selected
        cell.myItem = self.filteredData[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
        
    }
    
    func selectionMade(button: UIButton) {
        let ind = scrollingMenuOne.scrollView.subviews.index(of: button)! + 1
        if(self.brandFilters.filter {$0 == ind}.count > 0){
            brandFilters = self.brandFilters.filter {$0 != ind}
        }else{
            brandFilters.append(ind)
        }
        self.filterData()
        itemsTable.reloadData()
        collectionView.reloadData()
    }
    //MARK: - View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.isHidden = false
        
        //Define Layout here
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        //Get device width
        let width = UIScreen.main.bounds.width
        
        //set section inset as per your requirement.
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        //set cell item size here
        layout.itemSize = CGSize(width: width / 3.0, height: width / 2.2)
        
        //set Minimum spacing between 2 items
        layout.minimumInteritemSpacing = 0
        
        //set minimum vertical line spacing here between two lines in collectionview
        layout.minimumLineSpacing = 0
        
        //apply defined layout to collectionview
        collectionView!.collectionViewLayout = layout
        
        itemsTable.isHidden = true
        self.title = "Documents"
        categoryPicker.delegate = self
        itemsTable.register(UINib(nibName: "OverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "OverviewTableViewCellIdentifier")
        let nib = UINib(nibName: "IconCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "iconCollectionViewCellIdentifier")
        
        self.itemsTable.delegate = self
        self.itemsTable.dataSource = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        categoryPicker.pickerData = CategoriesData.getData()
        brandFilters = []
        for brand in categoryPicker.pickerData{
            brandFilters.append(brand.id)
        }
        
        let pickerSelectionIndex = categoryPicker.picker.selectedRow(inComponent: 0)
        categoryFilter = CategoriesData.getData()[pickerSelectionIndex].id
        
        scrollingMenuOne.delegate = self
        
        itemsTable.rowHeight = UITableViewAutomaticDimension
        itemsTable.estimatedRowHeight = 240
        self.filterData()
        
        itemsTable.reloadData()
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ItemDetailViewControllerSegue"){
          let itemDetailView = segue.destination as! ItemDetailViewController
            itemDetailView.item = self.selectedItem
//            let senderIndex = sender as! Int
//            itemDetailView.item = filteredData[senderIndex]
        }
    }
    //MARK: - Delegation
    func didAddItemToCollection(item: Item) {
        debugPrint("did add")
    }
    
    func didRemoveItemFromCollection(item: Item) {
        debugPrint("did remove")
    }
    
    func didUpdateItemCount(amount: Int) {
        debugPrint("I now have \( amount ) items")
    }
    //
}

