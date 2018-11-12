//
//  KLTPofileViewController.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 11/30/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Pickerdata: Equatable { //Data contained for each business unit picker
    static func ==(lhs: Pickerdata, rhs: Pickerdata) -> Bool {
        let areEqual = lhs.tagID == rhs.tagID &&
            lhs.data == rhs.data && lhs.text == rhs.text && lhs.subText == rhs.subText && lhs.typeID == rhs.typeID
        return areEqual
    }
    var tagID: Int?
    var typeID: Int?
    var data: BusinessUnit?
    var text: String?
    var subText: String?
}

class KLTProfileViewController: UIViewController {
    
    let divisionType = 2006
    var roleID: Int?
    
    var profileDictionary: [Int: Int]?
    var fromLogin:Bool = false // Is from login screen
    var pickerDataArr: Array<Pickerdata> = Array() // Contains data for all pickers
    var currentPickerData: Pickerdata? //contains data for current picker
    var currentSublevelData: BusinessUnit?
    var hideSegments = true
    var unitdata: Array<BusinessUnit>?
    
    @IBOutlet weak var overallStackView: UIStackView! //Stackview containing all components
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customPickerView: UIView! //View that contains the picker and done button
    @IBOutlet weak var picker: UIPickerView! //Business data picker
    @IBOutlet weak var pickerTitle: UILabel! //Title in picker view
    @IBOutlet weak var bandwidthSwitch: UISwitch! //Switch for downloading over recommended bandwith
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    public class func create() -> KLTProfileViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        return main as! KLTProfileViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let roleID = KLTManager.sharedInstance.currentUser?.roleID {
            self.roleID = roleID
        }
        else {
            if let roleID = UserDefaults.standard.object(forKey: "roleID") {
                self.roleID = Int(roleID as! String)
            }
        }
        
        
        if self.roleID == 3 && !fromLogin {tableView.isUserInteractionEnabled = false}
        
        //Read from user defaults and set bandwith switch
        if  UserDefaults.standard.object(forKey: "sizeLimit") != nil {
            bandwidthSwitch.isOn = UserDefaults.standard.bool(forKey: "sizeLimit")
        }
        else { bandwidthSwitch.isOn = false }
        
        customPickerView.isHidden = true
        tableView.tableFooterView = UIView()
        self.getData() //Get business unit data
        
        if !fromLogin {
            for btn in self.closeView.subviews {
                btn.removeFromSuperview()
            }
            self.overallStackView.removeArrangedSubview(closeView)
        }
    }
   
   

}

extension KLTProfileViewController: ProfileSegmentDelegate {
    //MARK: - Functions
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getData() {
        if !fromLogin {
            //If not from login we already have the business unit data
            self.profileDictionary = KLTManager.sharedInstance.currentUser?.profileDictionary
            reset() //This method sets items on screen
        }
        else {
            // We are coming from the login screen. Download business unit data
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            let request = KLTMediaRequests.init()
            request.getBusinessData(completion: { (json, error) in
                if error == nil {
                    self.profileDictionary = [Int:Int]() // clear out profile dictionary
                    self.reset() //This method sets items on screen
                }
                else {
                    self.showErrorAlert(message: "Unable to load data. Please try again")
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
    func reset() {
        self.unitdata = Array()
        for unit in KLTManager.sharedInstance.businessUnitsData!.data!.arrayValue {
            let bu = BusinessUnit.init(json: unit)
            self.unitdata?.append(bu)
        }
        self.loadPickers()
        
        if (self.profileDictionary?.count == 0 || self.profileDictionary == nil) {
            self.profileDictionary = [Int:Int]()
            if let data = self.unitdata {
                self.profileDictionary![divisionType] = data[0].tagID! //default to corporate or first item in segment
            }
        }
    }
    
    func loadPickers() {
        pickerDataArr = Array()
        if self.roleID == 3 { //Distributor
            hideSegments = true
            if let data = self.unitdata {
                if let sublevels = data[0].tags { //if data contains sublevels continue
                    if sublevels.count > 0{
                        self.buildPickerData(data: data[0])
                    } else {self.tableView.reloadData()}
                } else {self.tableView.reloadData()}
            }
            else {
                self.tableView.reloadData()
            }
        }
        else { //employee
            hideSegments = false
            if  self.profileDictionary![divisionType] != nil {
                let data = self.unitdata!.filter{$0.tagID == self.profileDictionary![divisionType]!}[0]
                if let sublevels = data.tags { //if data contains sublevels continue
                    if sublevels.count > 0 {
                        self.buildPickerData(data: data)
                    } else {self.tableView.reloadData()}
                } else {self.tableView.reloadData()}
            }
            else{
                debugPrint("There is no default segment or segment hasnt been selected")
                self.tableView.reloadData()
            }
        }
    }
    
    func buildPickerData(data: BusinessUnit) {
        
        var subtext: String?
        
        if let tags = data.tags {
            for tag in tags {
                for value in profileDictionary!.values {
                    if value == tag.tagID {
                        subtext = tag.name!
                        let pickerData = Pickerdata.init(tagID: data.tagID!, typeID:data.typeID!, data: data, text: data.sublabel, subText: subtext)
                        self.pickerDataArr.append(pickerData)
                        
                        if let sublevels = tag.tags { //if data contains sublevels continue
                            if sublevels.count > 0 {
                                buildPickerData(data: tag)
                            }
                        }
                    }
                }
            }
        }
        
        let pickerData = Pickerdata.init(tagID: data.tagID!, typeID:data.typeID!, data: data, text: data.sublabel, subText: subtext)
        if !pickerDataArr.contains(pickerData) { // we havent added this data to the array
            self.pickerDataArr.append(pickerData)
        }
        tableView.reloadData()
    }
    
    func segmentSelected(index: Int) {
        pickerDataArr = Array()
        let data = self.unitdata![index]
        self.profileDictionary = [Int:Int]() //segment changed. Lets reset the profileDict
        self.profileDictionary![divisionType] = data.tagID!
        self.loadPickers()
        self.currentSublevelData = data //added to fix issue where user can skip this screen on registration
    }
    
    @IBAction func pickerDonePressed(_ sender: Any) {
        self.rowSelected(row: picker.selectedRow(inComponent: 0))
        UIView.animate(withDuration: 0.3) {
            self.customPickerView.frame = CGRect.init(x: self.customPickerView.frame.origin.x, y: self.view.frame.size.height, width: self.customPickerView.frame.size.width, height: self.customPickerView.frame.size.height)
        }

        if let sublevel = currentSublevelData {
            self.removeSublevelsFromArray(unitData: sublevel)
            if let tags = sublevel.tags {
                if tags.count > 0 {
                    self.buildPickerData(data: sublevel)
                } else {tableView.reloadData()}
            } else {tableView.reloadData()}
        } else {tableView.reloadData()}
    

    }
    
    func removeSublevelsFromArray(unitData: BusinessUnit) {
        for data in pickerDataArr {
            if data.typeID == unitData.typeID {
                let index = pickerDataArr.index(of: data)
                pickerDataArr.remove(at: index!)
                
                if let dict = self.profileDictionary {
                    for (key, value) in dict {
                        if value == data.typeID {
                            self.profileDictionary!.removeValue(forKey: key)
                        }
                    }
                }
            
                if let sublevel = data.data {
                    if let tags = sublevel.tags {
                        for tag in tags {
                            removeSublevelsFromArray(unitData: tag)
                        }
                    }
                }
            }
        }
    }
    
    func showPicker(pickerData: Pickerdata) {
        customPickerView.frame = CGRect.init(x: customPickerView.frame.origin.x, y: view.frame.size.height, width: customPickerView.frame.size.width, height: customPickerView.frame.size.height)
        customPickerView.isHidden = false
        pickerTitle.text = pickerData.text!
        currentPickerData = pickerData
        picker.reloadAllComponents()
        
        
        if let data = pickerData.data {
            if let tags = data.tags {
                for tag in tags {
                    for value in profileDictionary!.values {
                        if value == tag.tagID {
                            let index = tags.index(of: tag)
                            if let i = index {
                                picker.selectRow(i, inComponent: 0, animated: true)
                            }
                        }
                    }
                }
            }
        }
        
        
        UIView.animate(withDuration: 0.3) {
            self.customPickerView.frame = CGRect.init(x: self.customPickerView.frame.origin.x, y: self.view.frame.size.height - self.customPickerView.frame.size.height, width: self.customPickerView.frame.size.width, height: self.customPickerView.frame.size.height)
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if let sublevel = currentSublevelData {
            if let tags = sublevel.tags {
                if tags.count > 0 {
                    self.showErrorAlert(message: "Please complete the profile\nbefore continuing")
                    return
                }
                else {
                    print("done filling out form")
                }
            }
        }
        
        
        
        var tagsOnly = [Int]()
        for tag in self.profileDictionary!{
            tagsOnly.append(tag.value)
        }
        print("Profile Dictionary Tags: \(tagsOnly)")
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        if !fromLogin {
            KLTManager.sharedInstance.saveProfile(profile: tagsOnly, completion: { success in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                if success {
                    debugPrint("User profile saved")
                    KLTManager.sharedInstance.currentUser?.profileDictionary = self.profileDictionary!
                    //                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.showErrorAlert(message: "Could not complete operation at this time. Please check your internet connection and try again.")
                }
            })
        }
        else {
            let request = KLTUserRequests.init()
            request.saveProfilewithGuid(profile: tagsOnly, completion: { (success, error) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                if success {
                    debugPrint("User profile saved")
                    self.performSegue(withIdentifier: "profileToPassword", sender: nil)
                }
                else {
                    self.showErrorAlert(message: "Could not complete operation at this time. Please check your internet connection and try again.")
                }
            })
        }
        
        if bandwidthSwitch.isOn {
            UserDefaults.standard.set(true, forKey: "sizeLimit")
        }
        else {
            UserDefaults.standard.set(false, forKey: "sizeLimit")
        }
    }
}

extension KLTProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - TableView Delegate and DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hideSegments { return pickerDataArr.count }
        else { return pickerDataArr.count + 1 }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hideSegments == false && indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileSegmentedCell", for: indexPath) as! ProfileSegmentedTableViewCell
            cell.segmentedControl.removeAllSegments()
            cell.delegate = self
            cell.selectionStyle = .none
            
            var segmentIds: [Int] = Array()

            if let data = self.unitdata {
                for (index, unit) in data.enumerated() {
                    cell.segmentedControl.insertSegment(withTitle:unit.name!, at: index, animated: false)
                    segmentIds.append(unit.tagID!)
                }
            }
            
            if let dict = self.profileDictionary {
                if let selectedindex = dict[divisionType] {
                    cell.segmentedControl.selectedSegmentIndex = segmentIds.index(of: selectedindex)!
                }
            }
            return cell
        }
        else {
            
            var cellIndex = indexPath.row
            
            if hideSegments == false {
                cellIndex = indexPath.row - 1
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! UserProfileTableViewCell
            
            if pickerDataArr.count > 0 {
                
                if let text = pickerDataArr[cellIndex].text {
                    
                    cell.descriptionLabel.text = text
                    cell.descriptionLabel.isHidden = true
                    
                    cell.mainLabel.attributedText = NSAttributedString.init(string: text, attributes: [NSAttributedStringKey.foregroundColor:UIColor.init(red: 17/255, green: 108/255, blue: 175/255, alpha: 0.7)])
                    


                    print(text)
                }
                
                if let subtext = pickerDataArr[cellIndex].subText {
                    cell.descriptionLabel.isHidden = false
                    
                    cell.mainLabel.attributedText = NSAttributedString.init(string: subtext, attributes: [NSAttributedStringKey.foregroundColor:UIColor.init(red: 17/255, green: 108/255, blue: 175/255, alpha: 0.7)])
                    print(subtext)
                }
            }
            if tableView.isUserInteractionEnabled == false {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath)
        if cell!.selectionStyle == .none {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hideSegments == false {
            self.showPicker(pickerData: pickerDataArr[indexPath.row - 1])
        }
        else {
            self.showPicker(pickerData: pickerDataArr[indexPath.row])
        }
    }
    
}

extension KLTProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let arr = currentPickerData?.data!.tags! {
            return arr.count
        }
        else { return 0 }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.rowSelected(row: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if let pickerData = currentPickerData {
            if let data = pickerData.data {
                if let title = data.tags![row].name {
                    return NSAttributedString.init(string: title, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
                    
                } else { return nil }
            } else { return nil }
        } else { return nil }
    }
    
    func rowSelected(row: Int) {
        if let pickerData = currentPickerData {
            if let data = pickerData.data {
                
                if data.tags!.count > 0 {
                    if let _ = self.profileDictionary {
                        if let id = data.tags![row].typeID {
                            self.profileDictionary![id] = data.tags![row].tagID!
                        }
                    }
                }
                
                if let title = data.tags![row].name {
                    let index = pickerDataArr.index(of: currentPickerData!)
                    var data = pickerDataArr[index!]
                    pickerDataArr.remove(at: index!)
                    data.subText = title
                    currentPickerData = data
                    
                    if let _ = data.data {
                        if let _ = data.data!.tags {
                            if data.data!.tags!.count > 0 {
                                self.currentSublevelData = data.data!.tags![row]
                            }
                        }
                    }
                    pickerDataArr.insert(data, at: index!)
               }
            }
        }
    }
}
