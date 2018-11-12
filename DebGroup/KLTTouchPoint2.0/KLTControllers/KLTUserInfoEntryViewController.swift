//
//  KLTUserInfoEntryViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 7/19/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

class KLTUserInfoEntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: -Vars
    var profileDictionary: [Int: Int]?
    var fromLogin:Bool?
    
    //MARK: -IBOutlets
    @IBOutlet weak var pickerStack: UIStackView!
    @IBOutlet weak var segmentStack: UIStackView!
    @IBOutlet weak var segmentLabel: UILabel!
    @IBOutlet weak var bandwidthLimitSwitch: UISwitch!
    @IBOutlet weak var typeFieldsContainer: UIView!
    @IBOutlet weak var topLevelSegmentedControl: KLTProfileSegmentedControl!
    @IBOutlet var dynamicView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: -IBActions
    @IBAction func cancelPressed(_ sender: Any) {
        
        if((KLTManager.sharedInstance.keychain["token"]) != nil){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.performSegue(withIdentifier: "unwindSegue", sender: self)
        }
        
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        var tagsOnly = [Int]()
        for tag in self.profileDictionary!{
            tagsOnly.append(tag.value)
        }
        print(  "PROF \(    tagsOnly)")
        
        if !fromLogin! {
            KLTManager.sharedInstance.saveProfile(profile: tagsOnly, completion: { success in
                if success {
                    debugPrint("User profile saved")
                    KLTManager.sharedInstance.currentUser?.profileDictionary = self.profileDictionary!
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        else {
            let request = KLTUserRequests.init()
            request.saveProfilewithGuid(profile: tagsOnly, completion: { (success, error) in
                if success {
                    debugPrint("User profile saved")
                    self.performSegue(withIdentifier: "profileToPassword", sender: nil)
                }
                else {
                    self.showErrorAlert(message: "Could not complete operation at this time. Please check your internet connection and try again.")
                }
            })
        }
        
        if bandwidthLimitSwitch.isOn {
            UserDefaults.standard.set(true, forKey: "sizeLimit")
        }
        else {
            UserDefaults.standard.set(false, forKey: "sizeLimit")
        }
        
    }

    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        pickerStack.arrangedSubviews.forEach({ $0.removeFromSuperview()})
        let theIndex = sender.selectedSegmentIndex
        let data = KLTManager.sharedInstance.businessUnitsData?.data![theIndex]
        topLevelSegmentedControl.currentSegmentTagID = data!["TagID"].int
        //        if let _ = self.profileDictionary {
        self.profileDictionary![2006] = data!["TagID"].int
        //        }
        _ = self.buildPicker(data:data!)
    }

    //MARK: -View funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        if (KLTManager.sharedInstance.currentUser?.roleID == 3){
            pickerStack.isUserInteractionEnabled = false
        }
        if  UserDefaults.standard.object(forKey: "sizeLimit") != nil {
            bandwidthLimitSwitch.isOn = UserDefaults.standard.bool(forKey: "sizeLimit")
        }
        else {
            bandwidthLimitSwitch.isOn = false
        }
        
        if !fromLogin!{

            self.profileDictionary = KLTManager.sharedInstance.currentUser?.profileDictionary
            reset()
        }
        else {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            let request = KLTMediaRequests.init()
            request.getBusinessData(completion: { (json, error) in
                if error == nil {
                    self.profileDictionary = [Int:Int]()
                    self.reset()
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
    
    //MARK: -Funcs
    public class func create() -> KLTUserInfoEntryViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        return main as! KLTUserInfoEntryViewController
    }
    
    func reset() {
        topLevelSegmentedControl.removeAllSegments()
        for (index,level) in (KLTManager.sharedInstance.businessUnitsData?.data!.enumerated())! {
            topLevelSegmentedControl.insertSegment(withTitle: String(describing: level.1["Name"]), at: index, animated: false)
            topLevelSegmentedControl.segmentIDs.append(level.1["TagID"].int!)
        }
        self.loadPickers()
        dynamicView.frame = typeFieldsContainer.frame
        self.typeFieldsContainer.addSubview(dynamicView)
        
        
//        if let _ = self.profileDictionary {
        if( self.profileDictionary?.count == 0 || self.profileDictionary == nil){
            let data = KLTManager.sharedInstance.businessUnitsData?.data![0]
            self.profileDictionary = [Int:Int]()
            self.profileDictionary![2006] = data!["TagID"].int
        }
//        }
       
    }

    func loadPickers(){
        pickerStack.arrangedSubviews.forEach({ $0.removeFromSuperview()})
        if KLTManager.sharedInstance.currentUser?.roleID == 3 {
            segmentStack.isHidden = true
            topLevelSegmentedControl.currentSegmentTagID = KLTManager.sharedInstance.businessUnitsData?.data![0]["TagID"].int
            debugPrint("The segment has been defaulted to tagID \(String(describing: topLevelSegmentedControl.currentSegmentTagID))")
            
            _ =  self.buildPicker(data: (KLTManager.sharedInstance.businessUnitsData?.data![0])!)
        }
        else{
            //            if let _ = self.profileDictionary {
            if (self.profileDictionary![2006] != nil){
                topLevelSegmentedControl.currentSegmentTagID = self.profileDictionary![2006]
                
                let data = KLTManager.sharedInstance.businessUnitsData?.data!.filter{$0.1["TagID"] == JSON(self.profileDictionary![2006]!)}[0].1
                topLevelSegmentedControl.selectedSegmentIndex = topLevelSegmentedControl.segmentIDs.index(of: self.profileDictionary![2006]!)!
                
                _ =  self.buildPicker(data: data!)
            }
            else{
                debugPrint("There is no default segment")
            }
            //            }
            
        }
    }
    
    private func buildPicker(data:JSON) -> KLTProfilePicker{
        let newPicker = KLTProfilePicker(frame:CGRect(x: 0, y: 0, width: self.pickerStack.frame.size.width, height: 100))
        if data["Tags"][0].count > 0{
            newPicker.delegate = self
            newPicker.dataSource = self
            newPicker.ID = data["TagID"].int
            newPicker.data = data
            let newPickerLabel = UILabel()
            newPickerLabel.font = UIFont.systemFont(ofSize: 11)
            newPicker.label = newPickerLabel
            newPicker.label?.text = data["SubLabel"].string
            pickerStack.addArrangedSubview(newPickerLabel)
            pickerStack.addArrangedSubview(newPicker)
            newPicker.heightAnchor.constraint(equalToConstant: 100)
            let newPickerType = data["Tags"][0]["TypeID"]
            var newPickerTypeSelection: Int?
            //            if let _ = self.profileDictionary {
            newPickerTypeSelection  = self.profileDictionary![newPickerType.int!]
            //            }
            if let _  = newPickerTypeSelection{
                let dataDistill =  data["Tags"].filter{$0.1["TagID"] == JSON(newPickerTypeSelection!)}
                if(dataDistill.count > 0){
                    newPicker.child = buildPicker(data:dataDistill[0].1)
                    let ind = (data["Tags"].arrayValue.index{$0["TagID"] == JSON(newPickerTypeSelection!)}!)
                    newPicker.selectRow(ind, inComponent: 0, animated: true)
                }else{
                    debugPrint("FOUND AN INVALID VALUE")
                    newPicker.child = buildPicker(data: data["Tags"][0])
                    newPicker.selectRow(0, inComponent: 0, animated: true)
                }
            }else{
                print("I am a new picker of type \(newPickerType)")
                newPicker.child = buildPicker(data: data["Tags"][0])
                newPicker.selectRow(0, inComponent: 0, animated: true)
            }
            return newPicker
        }else{
            let amm = 6 - pickerStack.subviews.count
            for _ in 0...amm{
                let nw = UIView(frame:CGRect(x: 0, y: 0, width: self.pickerStack.frame.size.width, height: 100))
                nw.backgroundColor = UIColor.white
                pickerStack.addArrangedSubview(nw)
            }
        }
        return newPicker
    }
    //MARK: -Delegations
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let kltPicker = pickerView as! KLTProfilePicker
        return kltPicker.data["Tags"].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let kp = pickerView as! KLTProfilePicker
        return (kp.data["Tags"].arrayValue[row]["Name"].string)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let kltPickerView = pickerView as! KLTProfilePicker
        if(kltPickerView.data["Tags"].count > 0 ){
                self.profileDictionary![kltPickerView.data["Tags"][row]["TypeID"].int!] = kltPickerView.data["Tags"][row]["TagID"].int
            kltPickerView.label?.text = kltPickerView.data["Name"].string
            kltPickerView.child?.data = kltPickerView.data["Tags"][row]
        }else{
            print("I do not have subitems")
            kltPickerView.child?.data = kltPickerView.data["Tags"][0]
            kltPickerView.label?.text = ""
        }
        kltPickerView.child?.reloadAllComponents()
        
        if ((kltPickerView.child?.child) != nil) {
            self.pickerView(kltPickerView.child!, didSelectRow: 0, inComponent: 0)
        }
        self.loadPickers()
    }
}
