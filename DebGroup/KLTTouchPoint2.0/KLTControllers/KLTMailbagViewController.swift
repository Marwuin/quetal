//
//  MailbagViewController.swift
//  OpenTab
//
//  Created by Raul Silva on 7/7/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit
import Contacts
import MultiAutoCompleteTextSwift

class KLTMailbagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, mailbagItemDelegate {
    //MARK: -Vars
    var callerItem:Item?
    var autoCompleteNames = [String]()
    let store = CNContactStore()
    //MARK: -IBOutlets
    @IBOutlet weak var sendCopySwitch: UISwitch!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sendToField: MultiAutoCompleteTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: -IBActions
    @IBAction func cancelPressed(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if(self.messageField.text == ""){
            self.showErrorAlert(message: "Please fill out the \"Message:\" and \"Send to:\" boxes before sending.")
        }else{
            let shareObject = KLTMediaShareRequests()
            var arrayOfRecipients = self.sendToField.text?.components(separatedBy: ",")
            if sendCopySwitch.isOn {
                if let email = KLTManager.sharedInstance.currentUser?.email {
                    arrayOfRecipients?.append(email)
                }
            }
            shareObject.shareMedia(recipients: arrayOfRecipients!,message: self.messageField.text, ItemIDs: KLTManager.sharedInstance.mailbagItems, completion: {success,error in
                if(success){self.navigationController?.popViewController(animated: true)
                    debugPrint("Items shared succesfully")
                    KLTManager.sharedInstance.mailbagItems = [Int]()
                    self.updateCountLabel()
                    self.dismiss(animated: true, completion: nil)
                    
                }else{
                    debugPrint("Something went wrong: \(String(describing: error))")
                }
            })
        }
    }
    //MARK: -View Funcs
    
    class func create() -> KLTMailbagViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self))
        return main as! KLTMailbagViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "bagToDocument"){
            let itemDetailView = segue.destination as! KLTItemDetailViewController
            itemDetailView.myName = callerItem?.title
            itemDetailView.item = callerItem!
        }
    }
    override public var prefersStatusBarHidden: Bool {
        return hideStatus
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "KLTMailbagTableViewCell", bundle: frameworkBundle), forCellReuseIdentifier: "MailbagCellIdentifier")
        
        
        self.updateCountLabel()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        tableView.reloadData()
        
        let vc = self.parent
        if vc is UINavigationController {
            self.topStack.removeArrangedSubview(cancelButton)
            cancelButton.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sendToField.autoCompleteTableView?.frame.origin.y = self.sendToField.frame.origin.y + self.sendToField.frame.size.height
        self.sendToField.autoCompleteTableView?.frame.size.width = self.sendToField.frame.size.width
        self.sendToField.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Bold", size: 18)!
        self.sendToField.autoCompleteWordTokenizers = [", "," "]
        self.messageField.layer.borderWidth = 1
        self.messageField.layer.cornerRadius = 10
        self.messageField.layer.borderColor = #colorLiteral(red: 0.8469936252, green: 0.8470956683, blue: 0.8469588161, alpha: 1).cgColor
        
        
        self.getContacts()
        
    }
    //MARKL -Funcs
    
    private func getContacts(){
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    
                }
                return
            }
            var contacts = [CNContact]()
            let request = CNContactFetchRequest(keysToFetch: [CNContactEmailAddressesKey as NSString, CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
            do {
                try self.store.enumerateContacts(with: request) { contact, stop in
                    contacts.append(contact)
                }
            } catch {
                print(error)
            }
            
            let formatter = CNContactFormatter()
            formatter.style = .fullName
            for contact in contacts {
                let arrEmail = contact.emailAddresses as [CNLabeledValue]
                for email in arrEmail{
                    self.self.autoCompleteNames.append( email.value as String)
                }
            }
            self.sendToField.autoCompleteStrings = self.autoCompleteNames
        }
    }
    private func itemToggled(item: Item, state: Bool) {
        print("ITEM TOGGLED")
    }
    private func updateCountLabel(){
        switch KLTManager.sharedInstance.mailbagItems.count {
        case 0:
            self.titleLabel.text = "There are no items in your outbox"
        case 1:
            self.titleLabel.text = "There is \(KLTManager.sharedInstance.mailbagItems.count) item in your outbox"
        default:
            self.titleLabel.text = "There are \(KLTManager.sharedInstance.mailbagItems.count) items in your outbox"
        }
    }
    //MARK: -Contacts
    func itemDocumentViewSelected(item: Item) {
        callerItem = item
        performSegue(withIdentifier: "bagToDocument", sender: index)
    }
    
    func removeRowAtIndex(index aIndex:Int) {
        var tRemove:Array<NSIndexPath> = Array()
        let tIndexPath:NSIndexPath =  NSIndexPath(item: aIndex, section: 0)
        tRemove.append(tIndexPath)
        let tRemoveIndexSet:NSMutableIndexSet = NSMutableIndexSet()
        tRemoveIndexSet.add(aIndex)
        KLTManager.sharedInstance.mailbagItems.remove(at: aIndex)
        tableView.deleteRows(at: tRemove as [IndexPath], with: .left)
        self.updateCountLabel()
    }
    
    //MARK: -TableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return KLTManager.sharedInstance.mailbagItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailbagCellIdentifier", for: indexPath) as! KLTMailbagTableViewCell
        cell.item = KLTManager.sharedInstance.kltItemsData.filter{$0.id == KLTManager.sharedInstance.mailbagItems[indexPath.row]}[0]
        cell.backgroundColor = UIColor.clear
        cell.delegate = self
        cell.titleLabel.text = cell.item? .title
        
        let isDownloaded = kltMediaBase!.isThumbnailDownloaded(item: cell.item!)
        var url: URL?
        if isDownloaded {
            url = KLTDownloadManager.sharedInstance.urlFromDocDirectory(itemLocation: "thumbnail_\(cell.item!.id!).jpg")
        }
        else {
            url = URL.init(string: cell.item!.thumbnail!)
        }
        
        cell.thumbnail.af_setImage(withURL:  url!, placeholderImage: UIImage.init(named: "brokenLink"), filter: nil, progress: nil, progressQueue: .main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: { (response) in
        })
        
        
        return cell
    }
}
