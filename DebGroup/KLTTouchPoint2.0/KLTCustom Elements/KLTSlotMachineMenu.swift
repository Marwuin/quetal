//
//  KLTSlotMachineMenu.swift
//  OpenTab
//
//  Created by Raul Silva on 7/6/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

// A single selection, scrolling menu
// uses a UIPicker control turned on it's side

import UIKit

protocol slotMachineMenuDelegate:class{
    func didSelectSlotMachineItem(index: Int)
}

class KLTSlotMachineMenu: UIView, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return  pickerData.count
    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

 
    func hideMySelection(){
        let slotmachineselection = self.picker.selectedRow(inComponent: 0)
        let label = self.picker.view(forRow: slotmachineselection, forComponent: 0)?.subviews[0] as? UILabel
            label?.alpha = 0.5
    }
    func showMySelection(){
        let slotmachineselection = self.picker.selectedRow(inComponent: 0)
        let label = self.picker.view(forRow: slotmachineselection, forComponent: 0)?.subviews[0] as? UILabel
        label?.alpha = 1
    }
    //MARK: -Vars
    weak var delegate:slotMachineMenuDelegate?
    var picker = UIPickerView()
    let cellWidth = 70
    var cellHeight = 0
    let margin = 5
    var pickerData:[Tag]!
   
    //MARK: -View funcs
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = false
        cellHeight = Int(self.frame.size.height)
    }
    @objc func pickerTapped(_: Any){
       self.showMySelection()
        self.delegate?.didSelectSlotMachineItem(index: picker.selectedRow(inComponent: 0))
    }
    
    override func layoutSubviews() {
        picker.transform = CGAffineTransform(rotationAngle: CGFloat(Double(-90) * (Double.pi / 180)))

//        if UIDevice().screenType == .iPhone5 {
//            picker.frame = CGRect(x: Int(self.frame.size.width)/2, y: -200 - Int(self.frame.size.height), width:Int(self.frame.size.height) , height: Int(self.frame.size.width + 200))
//        }
//        else {
            picker.frame = CGRect(x: Int(self.frame.size.width)/2 - 2000, y:0, width:4000 , height: Int(self.frame.height))
//        picker.frame = CGRect.init(x: self.frame.size.width/2 - 200, y: 0, width: self.frame.size.width + 400 , height: self.frame.size.height)
//        picker.backgroundColor = .green

//                }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickerTapped(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        picker.addGestureRecognizer(tap)
        
     


        self.addSubview(picker)
    }
  
    //MARK: -PickerView
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_: Any) -> Int {
        return  pickerData.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectSlotMachineItem(index: row)
    }
    
    internal func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth, height:cellHeight))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight ))
        label.text = pickerData[row].name
        
         label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.840523839, green: 0.8828389049, blue: 0.947265327, alpha: 1)
        view.addSubview(label)
        view.transform = CGAffineTransform(rotationAngle: CGFloat(Double(90) * (Double.pi / 180)))
        return view
    }
    
    internal func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(cellWidth)
    }
}
