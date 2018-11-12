//
//  CalendarViewController.swift
//  KLTOpenTab
//
//  Created by Raul Silva on 8/29/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

class KLTCalendarViewController: UIViewController, UIScrollViewDelegate, scrollingMenuDelegate, calendarItemDelegate {
    //MARK: -Vars
    private var senderID:Int?
    var brandFilters = [Int]()
    private var months = [Month]()
    private var calendarData: [Tag] = KLTManager.sharedInstance.kltCalendarData
    //MARK: -Private Vars
    private var calendar = NSCalendar.current
    //CONSTANTS
    private var monthLabelWidth = 70
    private var calendarItemWidth = 100
    private var calendarItemSpacing = 10
    //MARK: -IBOutlets
    @IBOutlet weak var dividersView: UIScrollView!
    @IBOutlet weak var brandsScrollingMenu: KLTScrollingMenu!
    @IBOutlet weak var calendarItems: KLTCalendarItemsScrollView!
    @IBOutlet weak var calendarMonths: KLTCalendarMonthsScrollView!
    //MARK: -View funcs
    override func viewDidLoad() {

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
       monthLabelWidth = Int(calendarItems.frame.size.height / 12)

        //calendarItemSpacing = 0
        //calendarItemWidth = Int(calendarItems.frame.size.width / CGFloat(calendarData.count))
        months = [Month]()
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        calendarData = KLTManager.sharedInstance.kltCalendarData
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        for i in -5...6{
            let newMonth = Month()
            var newMonthDate = Calendar.current.date(byAdding: .month, value: i, to: Date())
            newMonthDate = newMonthDate?.startOfMonth()
            newMonth.number = calendar.component(.month, from: newMonthDate!)
            newMonth.label  = dateFormatter.string(from: newMonthDate!)
            newMonth.date = newMonthDate
            months.append(newMonth)
        }
        self.calendarItems.delegate = self
        self.calendarMonths.delegate = self
        self.brandsScrollingMenu.delegate = self
        self.createMonthLabels()
        self.addDividers()
        self.addCalendarItems()
        calendarItems.flashScrollIndicators()
        
        
        var offset = calendarItems.contentOffset
        offset.x = offset.x + 230
        calendarItems.setContentOffset(offset, animated: false)

    }

    override public var prefersStatusBarHidden: Bool {
        return hideStatus
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "calendarToSearchSegue") {
            let searchView = segue.destination as! KLTFinder
            let backItem = UIBarButtonItem()
            if let _ = sender as? UIBarButtonItem{
                searchView.prefilterTagId = nil
            } else {
                searchView.prefilterTagId = self.senderID
            }
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
        
        if segue.identifier == "calendarEmbed" {
            let scrollingmenu = segue.destination as! KLTScrollingMenuCollectionViewController
            scrollingmenu.delegate = self
        }
    }
    //MARK: -Delegation
    func didSelectCalendarItem(tagID: Int) {
        self.senderID = tagID
        performSegue(withIdentifier: "calendarToSearchSegue", sender: self)
    }
    
    func didSelectItemFromScrollingMenu(button: UIButton) {
        let ind = button.tag//scrollingMenuOne.scrollView.subviews.index(of: button)! + 1
        
        if(self.brandFilters.filter {$0 == ind}.count > 0){
            brandFilters = self.brandFilters.filter {$0 != ind}
        }else{
            brandFilters.append(ind)
        }
        brandFilters.sort()
        self.addCalendarItems()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.calendarItems {
            self.synchronizeScrollView(self.calendarMonths, toScrollView: self.calendarItems)
        }
        else if scrollView == self.calendarMonths {
            //  self.synchronizeScrollView(self.calendarItems, toScrollView: self.calendarMonths)
        }
    }
    //Funcs
    private func synchronizeScrollView(_ scrollViewToScroll: UIScrollView, toScrollView scrolledView: UIScrollView) {
        var offset = scrollViewToScroll.contentOffset
        offset.y = scrolledView.contentOffset.y
        scrollViewToScroll.setContentOffset(offset, animated: false)
        dividersView.setContentOffset(offset, animated: false)
    }
    
    func addCalendarItems(){
        for view in calendarItems.subviews{
            if(view .isKind(of: KLTCalendarItemView.self)){
                view.removeFromSuperview()
            }
        }
       // self.calendarItems.subviews.forEach { $0.removeFromSuperview() }
        let firstMonthDate = months[0].date
        let lastMonthDate = months.last?.date
        for calItem in calendarData{
            if calItem.calStart! < firstMonthDate! || calItem.calStart! > lastMonthDate! {
                continue
            }
            self.addCalendarItem(calItem:calItem)
        }
        self.calendarItems.contentSize = CGSize(
                                                width: Int(self.calendarItems.subviews.count * (calendarItemWidth + calendarItemSpacing)) + (calendarItemWidth),
                                                height: monthLabelWidth * (months.count))
        
        
        
    }
    private func addCalendarItem(calItem:Tag){
        let fetchColor = KLTManager.sharedInstance.kltBrandsData.filter{$0.tagID == calItem.brandTags![0] }[0].backgroundColor
        let itemEndMonth = calendar.component(.month, from: calItem.calEnd!)
        let itemStartMonth = calendar.component(.month, from: calItem.calStart!)
        let numberOfMontsForItem = itemEndMonth - itemStartMonth + 1
        let rowHeight:Int = Int(self.calendarMonths.contentSize.height) / months.count
        let firstMonthInView = calendar.startOfDay(for: months[0].date!)
        let itemStartDate = calendar.startOfDay(for: calItem.calStart!)
        let monthsSinceBeginingOfDisplayCalendar = CGFloat((calendar.dateComponents([.month], from: firstMonthInView, to: itemStartDate).month)!)
        let itemSubviewIndexInCalendarView = self.calendarItems.subviews.count
        if(calItem.brandTags != nil){
            var foundItem = false
            for brand in  calItem.brandTags!{
                if (!brandFilters.contains(brand)) {
                    foundItem = true
                    continue
                }
            }
            if (foundItem){
                if  let newItem =  frameworkBundle?.loadNibNamed("KLTCalendarItemView", owner: self, options: nil)?.first as? KLTCalendarItemView {
                    if let myURL = calItem.thumbnail {
                        let url = URL(string: myURL)
                        let placeholderImage = #imageLiteral(resourceName: "brokenLink")
                        newItem.thumb.af_setImage(withURL: url!, placeholderImage: placeholderImage)
                    }
                    newItem.title.text = calItem.name
                    newItem.backgroundColor = fetchColor
                    newItem.tagID = calItem.tagID
                    newItem.delegate = self

                    newItem.frame.size.width = CGFloat(calendarItemWidth)
                    newItem.frame.size.height = CGFloat( rowHeight * numberOfMontsForItem)
                    newItem.frame.origin.y = (CGFloat(Int(calendarMonths.contentSize.height) / months.count) * monthsSinceBeginingOfDisplayCalendar)
                    newItem.frame.origin.x = CGFloat(itemSubviewIndexInCalendarView * (calendarItemWidth + calendarItemSpacing )) + CGFloat(calendarMonths.frame.size.width)
                    newItem.clipsToBounds = true
                    newItem.alpha = 0
                    self.calendarItems.addSubview(newItem)
                    UIView.animate(withDuration: 0.3, animations: {
                        newItem.alpha = 1.0
                    })
                }
            }
        }
    }
    
    private func addDividers(){
        self.dividersView.subviews.forEach { $0.removeFromSuperview() }
        for i in 0...months.count{
            let newLine = UIView(frame: CGRect(x: -500,
                                               y: i * (Int(calendarMonths.contentSize.height) / 12),
                                               width: ((calendarData.count + 2) * (calendarItemSpacing + calendarItemWidth))+500,
                                               height: 1))
            newLine.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            dividersView.addSubview(newLine)
        }
    }
    
    private func createMonthLabels(){
        self.calendarMonths.subviews.forEach { $0.removeFromSuperview() }
        for (index,month) in (months.enumerated()){
            if  let newLabel =  frameworkBundle?.loadNibNamed("KLTCalendarMonthLabel", owner: self, options: nil)?.first as? KLTCalendarMonthLabel {
                newLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
                newLabel.frame.size.width = 50
                newLabel.frame.size.height = CGFloat(monthLabelWidth)
                newLabel.frame.origin.y = CGFloat(index * monthLabelWidth)
                newLabel.frame.origin.x = 0
                newLabel.labelName.text = month.label
                self.calendarMonths.addSubview(newLabel)
            }
        }
        self.calendarMonths.contentSize = CGSize(width: Int(self.calendarMonths.bounds.size.width), height: monthLabelWidth * (months.count))
    }
}

extension KLTCalendarViewController: ScrollingMenuCollectionViewDelegate {
    func didSelectBrand(brand: Tag) {
        
        let ind = brand.tagID!
        if (self.brandFilters.filter {$0 == ind}.count > 0){
            brandFilters = self.brandFilters.filter {$0 != ind}
        }
        else{
            brandFilters.append(ind)
        }
        brandFilters.sort()
        self.addCalendarItems()
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
        }
        self.addCalendarItems()
    }
}
