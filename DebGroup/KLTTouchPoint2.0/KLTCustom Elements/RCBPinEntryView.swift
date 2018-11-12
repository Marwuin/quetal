//
//  CBPinEntryView.swift
//  Pods
//
//  Created by Chris Byatt on 18/03/2017.
//
//

import UIKit

protocol RCBPinEntryViewDelegate {
    func pinEntryValueDidChangeTo(_: String)
}

open class RCBPinEntryView: UIView {
    var delegate:RCBPinEntryViewDelegate?
    
    let length: Int = 4
    
    let entryBackgroundColour: UIColor = UIColor.white
    
    let entryBorderWidth: CGFloat = 1
    
    let entryDefaultBorderColour: UIColor = UIColor.darkGray
    
    let entryBorderColour: UIColor = UIColor(red: 69/255, green: 78/255, blue: 86/255, alpha: 1.0)
    
    let entryErrorColour: UIColor = UIColor.red
    
    let entryCornerRadius: CGFloat = 3.0
    
    let entryTextColour: UIColor = UIColor.gray
    
    let entryFont: UIFont = UIFont.systemFont(ofSize: 24)
    
    private var stackView: UIStackView?
     var textField: UITextField!
    
    fileprivate var errorMode: Bool = false
    
    fileprivate var entryButtons: [UIButton] = [UIButton]()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    override open func prepareForInterfaceBuilder() {
        commonInit()
    }
    
    
    private func commonInit() {
        setupStackView()
        setupTextField()
        
        createButtons()
    }
    
    private func setupStackView() {
        stackView = UIStackView(frame: bounds)
        stackView!.alignment = .fill
        stackView!.axis = .horizontal
        stackView!.distribution = .fillEqually
        stackView!.spacing = 10
        
        self.addSubview(stackView!)
    }
    
    private func setupTextField() {
        textField = UITextField(frame: bounds)
        textField.delegate = self
        textField.keyboardType = .numberPad
        textField.keyboardAppearance = .dark
        
        self.addSubview(textField)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.isHidden = true
        textField.becomeFirstResponder()
    }
    
    private func createButtons() {
        for i in 0..<length {
            let button = UIButton()
            button.backgroundColor = UIColor.white
            button.setTitleColor(entryTextColour, for: .normal)
            button.titleLabel!.font = entryFont
            
            button.layer.cornerRadius = entryCornerRadius
            button.layer.borderColor = entryDefaultBorderColour.cgColor
            button.layer.borderWidth = entryBorderWidth
            
            button.tag = i + 1
            
            button.addTarget(self, action: #selector(didPressCodeButton(_:)), for: .touchUpInside)
            
            entryButtons.append(button)
            stackView?.addArrangedSubview(button)
        }
    }
    
    @objc private func didPressCodeButton(_ sender: UIButton) {
        errorMode = false
        
        let entryIndex = textField.text!.count + 1
        for button in entryButtons {
            button.layer.borderColor = entryBorderColour.cgColor
            
            if button.tag == entryIndex {
                button.layer.borderColor = entryBorderColour.cgColor
            } else {
                button.layer.borderColor = entryDefaultBorderColour.cgColor
            }
        }
        
        textField.becomeFirstResponder()
    }
    
    open func toggleError() {
        if !errorMode {
            for button in entryButtons {
                button.layer.borderColor = entryBorderColour.cgColor
                button.layer.borderWidth = entryBorderWidth
            }
        } else {
            for button in entryButtons {
                button.layer.borderColor = entryBorderColour.cgColor
            }
        }
        
        errorMode = !errorMode
    }
    
    open func getPinAsInt() -> Int? {
        if let intOutput = Int(textField.text!) {
            return intOutput
        }
        
        return nil
    }
    
    open func getPinAsString() -> String {
        return textField.text!
    }
}

extension RCBPinEntryView: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.delegate?.pinEntryValueDidChangeTo(self.getPinAsString())
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorMode = false
        for button in entryButtons {
            button.layer.borderColor = entryBorderColour.cgColor
        }
        
        let deleting = (range.location == textField.text!.count - 1 && range.length == 1 && string == "")
        
        if string.count > 0 && !Scanner(string: string).scanInt(nil) {
            return false
        }
        
        let oldLength = textField.text!.count
        let replacementLength = string.count
        let rangeLength = range.length
        
        let newLength = oldLength - rangeLength + replacementLength
        
        if !deleting {
            for button in entryButtons {
                if button.tag == newLength {
                    button.layer.borderColor = entryDefaultBorderColour.cgColor
                    UIView.setAnimationsEnabled(false)
                    button.setTitle(string, for: .normal)
                    UIView.setAnimationsEnabled(true)
                } else if button.tag == newLength + 1 {
                    button.layer.borderColor = entryBorderColour.cgColor
                } else {
                    button.layer.borderColor = entryDefaultBorderColour.cgColor
                }
            }
        } else {
            for button in entryButtons {
                if button.tag == oldLength {
                    button.layer.borderColor = entryBorderColour.cgColor
                    UIView.setAnimationsEnabled(false)
                    button.setTitle("", for: .normal)
                    UIView.setAnimationsEnabled(true)
                } else {
                    button.layer.borderColor = entryDefaultBorderColour.cgColor
                }
            }
        }
        
        return newLength <= length
    }
}
