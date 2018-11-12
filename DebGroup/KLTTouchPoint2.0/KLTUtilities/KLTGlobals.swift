//
//  Globals.swift
//  OpenTab
//
//  Created by Raul Silva on 7/5/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import Foundation
import UIKit

let frameworkBundleIdentifier = "com.keylimetie.KLTTouchpoint2.0"
let frameworkBundle = Bundle(identifier: frameworkBundleIdentifier)

var currentService = frameworkBundle!.object(forInfoDictionaryKey: "KLT_URL") as! String

var hideStatus = false
var kltMediaBase: KLTMediaBase?
let kltGlobalDisabledTransparency:CGFloat =  0.3

let itemThumbnailWidth = UIScreen.main.bounds.width/3
let itemThumbnailHeight = UIScreen.main.bounds.width/2.2

let openTabLightBlue = UIColor.init(red: 17/255, green: 108/255, blue: 175/255, alpha: 1.0)

let cbSelectedStateButtonTint = openTabLightBlue
let cbDeselectedStateButtonTint = UIColor.white

let buttonTextAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue):UIFont(name: "HelveticaNeue-Bold", size: 18)!, NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue):UIColor.white]

let filterTextAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue):UIFont(name: "HelveticaNeue", size: 15)!, NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue):UIColor.white]

let iPadfilterTextAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue):UIFont(name: "HelveticaNeue", size: 17)!, NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue):UIColor.white]

let filterTagTextAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue):UIFont(name: "HelveticaNeue", size: 12)!, NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue):UIColor.white]


