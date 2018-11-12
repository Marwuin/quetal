//
//  ViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 6/22/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class ViewController: UIViewController, scrollingMenuDelegate, UITableViewDelegate, UITableViewDataSource, overviewItemDelegate, slotMachineMenuDelegate {
    func didSelectItem(index: Int) {
        categoryFilter = CategoriesData.getData()[index].id
        self.filterData()
        itemsTable.reloadData()
    }
    //MARK: - Vars
    var brandFilters = [Int]()
    var categoryFilter = Int()
    var itemsData = ItemsData.getData()
    var filteredData = [Item]()
    //MARK: - IBOutlets
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
    
    func selectionMade(button: UIButton) {
        let ind = scrollingMenuOne.scrollView.subviews.index(of: button)! + 1
        if(self.brandFilters.filter {$0 == ind}.count > 0){
            brandFilters = self.brandFilters.filter {$0 != ind}
        }else{
            brandFilters.append(ind)
        }
        self.filterData()
        itemsTable.reloadData()
    }
    //MARK: - View Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Documents"
        categoryPicker.delegate = self
        itemsTable.register(UINib(nibName: "OverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "OverviewTableViewCellIdentifier")
        self.itemsTable.delegate = self
        self.itemsTable.dataSource = self
        categoryPicker.pickerData = CategoriesData.getData()
        brandFilters = []
        for brand in categoryPicker.pickerData{
            brandFilters.append(brand.id)
        }
        
        let pickerSelectionIndex = categoryPicker.picker.selectedRow(inComponent: 0)
        categoryFilter = CategoriesData.getData()[pickerSelectionIndex].id
        
        scrollingMenuOne.delegate = self
        self.filterData()
        itemsTable.rowHeight = UITableViewAutomaticDimension
        itemsTable.estimatedRowHeight = 240
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ItemDetailViewControllerSegue"){
            let itemDetailView = segue.destination as! ItemDetailViewController
            let senderIndex = (sender as! NSIndexPath).row
            
            itemDetailView.item = filteredData[senderIndex]
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

