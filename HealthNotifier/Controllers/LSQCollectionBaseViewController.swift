//
//  LSQCollectionBaseViewController.swift
//
//  Created by Charles Mastin on 12/8/16.
//

import Foundation
import UIKit
import SwiftyJSON

// UINavigationControllerDelegate???
class LSQCollectionBaseViewController : UITableViewController {
    // do all the common things - contacts, medical, emergency are pure collection views
    // core variables
    var data: JSON = JSON.null // TODO: best practice
    var editMode: Bool = false
    var showAddCell: Bool = true
    var imageSize: CGFloat = 44.0
    var dataConfig: [[String:String]] = []
    
    // should mix this in via an extension
    var observationQueue: [AnyObject] = []
    
    // https://stackoverflow.com/questions/2528073/get-height-of-uitableview-without-scroll-bars/2528123#2528123
    var tableViewHeight: CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // override dat stuffs
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        
        self.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.tableView.register(LSQCellPrivacyRestrictedItem.self, forCellReuseIdentifier: "CellPrivacyRestrictedItem")
        self.tableView.register(LSQCellEmptyCollection.self, forCellReuseIdentifier: "CellEmptyCollection")
        
        self.addObservers()
        
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.tableView.backgroundColor = UIColor.clear
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        if LSQAppearanceManager.sharedInstance.cellSeparatorColor != nil {
            self.tableView.separatorColor = LSQAppearanceManager.sharedInstance.cellSeparatorColor
        }
        /*
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            //self.tableView.backgroundColor = LSQ.appearance.color.newTeal
            self.tableView.separatorColor = UIColor.white.withAlphaComponent(0.0)
        }
         */
        // of course, invoked externally you bastard, so frustrating
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // presumably safe at this point
        // but actually not? or not accurrate
        // too soon my brother
        // self.broadcastSize()
        // FOR OUR TERRIBLE HACK USE, we could "delay" calling this even more
        // and ensure our embedded containers have some realistic height
        // and maybe we animate the parent container constraint?
        // of course, invoked externally you bastard, so frustrating
    }
    
    func configureTable() {
        print("configureTable")
        // NON OP
        self.dataConfig = []
        self.tableView.reloadData()
        self.broadcastSize()
    }
    
    // TODO: RETIRE THIS
    func handleEditingChange() -> Void {
        if self.editMode {
            
        } else {
            
        }
        self.tableView.reloadData()
        self.broadcastSize()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataConfig.count
    }
    
    func broadcastSize(){
        print("broadcastSize")
        let h: Int = Int(self.tableViewHeight)
        print("height of \(h)")
        // careful, we manually invoke this, don't want to create some infinite loops of layout balls
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: LSQ.notification.hacks.containerSizeUpdate,
                object: self,
                userInfo: [
                    "height": h
                ]
            )
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataConfig[section]["name"]!
    }
    
    // https://stackoverflow.com/questions/30240594/change-the-sections-header-background-color-in-uitableview-using-an-array-of-hea
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key: String = self.dataConfig[section]["key"]!
        var numRows: Int = 1 // the empty cell placeholder
        
        // default case
        if self.dataConfig[section]["cell"]! == "default" ||
            self.dataConfig[section]["cell"]! == "document" {
            if self.editMode {
                numRows = 0
            }
            if let collection = self.data[key].array {
                if collection.count > 0 {
                    numRows = collection.count
                }
            }
            if self.editMode {
                // + Add Cell
                if self.showAddCell {
                    numRows += 1
                }
            }
        }
        // plugins and so on
        if key == "emergency-actions" {
            // we have 1, for notify
        }
        if key == "emergency-promo" {
            // we have 1, for the text bits
            // we could do 2 one to "dismiss"
        }
        
        return numRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.dataConfig[indexPath.section]["cell"]! == "default" ||
            self.dataConfig[indexPath.section]["cell"]! == "document" {
        
            let key: String = self.dataConfig[indexPath.section]["key"]!
            var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla")
            cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
            
            let collection = self.data[key].arrayValue
            if collection.indices.contains(indexPath.row) {
                let row = collection[indexPath.row]
                if row["error"].exists() {
                    cell = Forms.generatePrivacyRestrictedCell(tableView, indexPath: indexPath)
                } else {
                    
                    // DEFAULT CELL
                    if let title = row["title"].string {
                        cell.textLabel?.text = title
                    }
                    if let description = row["description"].string {
                        cell.detailTextLabel?.text = description
                    }
                    
                    /*
 
                    */
                    
                    // DD CELLS and images - WORST CODE EVER
                    if key == "directives" {
                        if let category = row["category"].string {
                            let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("directive", attribute: nil, value: category)
                            cell.textLabel?.text = formattedDonkey
                        }
                        // pull the title, and the category
                        // values from the category but whatever fml
                        // this is because we need to move the name of the title, description attributes into a summary object
                    }
                    if key == "documents" {
                        var title: String = ""
                        if let category = row["category"].string {
                            let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("document", attribute: nil, value: category)
                            title = formattedDonkey
                        }
                        if let tit = row["title"].string {
                            if tit != "" {
                                title = "\(title): (\(tit))"
                            }
                        }
                        cell.textLabel?.text = title
                        let placeholder = UIImage(named: "selfie_image")
                        cell.imageView!.contentMode = UIViewContentMode.scaleAspectFill
                        let url: String = "\(self.data[key][indexPath.row]["thumbnail_url"].string!)?width=\(Int(self.imageSize * 2))&height=\(Int(self.imageSize * 2))"
                        cell.imageView!.kf.setImage(
                            with: URL(string: url),
                            placeholder: placeholder,
                            options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)]
                        )
                    }
                    
                    if key == "medications" && self.data[key][indexPath.row]["alert"].boolValue {
                        cell.accessoryType = UITableViewCellAccessoryType.detailButton
                    }
                    
                    // customize in da power of attorney and next of kin to the description my brosef bra
                    if key == "emergency" || key == "contacts" {
                        var description: String = ""
                        if let d = row["description"].string {
                            description = d
                        }
                        // power of attorney
                        if let kong = row["power_of_attorney"].bool {
                            if kong {
                                description += ", Power of Attorney"
                            }
                        }
                        
                        // next of kin, blablabla
                        if let kong = row["next_of_kin"].bool {
                            if kong {
                                description += ", Next of Kin"
                            }
                        }
                        cell.detailTextLabel?.text = description
                    }
                    
                    if self.dataConfig[indexPath.section]["observePress"] == "yes" {
                        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                        cell.selectionStyle = UITableViewCellSelectionStyle.default
                        print("holla dem nuts son")
                        if LSQOnboardingManager.sharedInstance.active {
                            // tone it white son
                            // COULD BE TOO AGGRESSIVE THOUGH BRO
                            cell.tintColor = UIColor.red
                        }
                    } else {
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                    }
                    
                    if self.editMode {
                        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                        cell.selectionStyle = UITableViewCellSelectionStyle.default
                        print("mezoooon")
                        if LSQOnboardingManager.sharedInstance.active {
                            // tone it white son
                            // COULD BE TOO AGGRESSIVE THOUGH BRO
                            cell.tintColor = UIColor.white
                            
                            let image = UIImage(named:"disclosure_arrow")?.withRenderingMode(.alwaysTemplate)
                            
                            let checkmark  = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width)!, height:(image?.size.height)!));
                            checkmark.image = image
                            cell.accessoryView = checkmark
                            
                        }
                    }
                    
                    // last minute color theming bro brizzle
                    if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
                        cell.backgroundColor = UIColor.clear
                        cell.detailTextLabel?.textColor = UIColor.black.withAlphaComponent(0.4)
                        cell.textLabel?.textColor = UIColor.black.withAlphaComponent(0.8)
                    }
                    
                }
            } else {
                if self.editMode {
                    if self.showAddCell {
                        cell = Forms.generateAddCollectionItemCell(tableView, indexPath: indexPath, collectionId: key)
                        // TEMP DOWN DOWN - UBER GHETTO MANUAL VS using the actual collection definition, bro
                        if key == "emergency" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Contact"
                        }
                        if key == "directives" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Advance Directive"
                        }
                        if key == "documents" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Document"
                        }
                        if key == "medications" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Medication"
                        }
                        if key == "allergies" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Allergy"
                        }
                        if key == "conditions" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Condition"
                        }
                        if key == "procedures" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Procedure or Device"
                        }
                        if key == "immunizations" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Immunization"
                        }
                        if key == "insurances" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Insurance Policy"
                        }
                        if key == "care_providers" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Physician"
                        }
                        if key == "hospitals" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Hospital"
                        }
                        if key == "pharmacies" {
                            (cell as? LSQCellAddCollectionItem)?.labelText = "Add Pharmacy"
                        }
                    }
                } else {
                    cell = Forms.generateEmptyCollectionCell(tableView, indexPath: indexPath)
                }
            }
            
            return cell
            
        }
        
        // plugins and such
        // if I really cared, I would do this in the superclass that required said plugins, lol
        if self.dataConfig[indexPath.section]["key"]! == "emergency-actions" {
            let cell: UITableViewCell = Forms.generateAddCollectionItemCell(tableView, indexPath: indexPath, collectionId: "notify-contacts")
            (cell as? LSQCellAddCollectionItem)?.labelText = "Message Contacts"
            return cell
        }

        if self.dataConfig[indexPath.section]["key"]! == "emergency-promo" {
            // blip beep bap badaap
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cp_special")
            cell.textLabel?.numberOfLines = 0
            let inputText: String = "Your emergency contacts will be notified and provided with your GPS location (if available) each time your LifeSticker is scanned. Their contact information can be viewed by health care professionals. You can message all of your contacts: send status updates or request assistance in times of need."
            cell.textLabel?.text = inputText
            cell.textLabel?.sizeToFit()
            cell.textLabel?.font = cell.textLabel?.font.withSize(14.0)
            // cell.textLabel?.font = UIFont(name: cell.textLabel?.font.fontName, size: CGFloat(14.0))
            cell.textLabel?.textColor = LSQ.appearance.color.gray0
            cell.selectionStyle = .none
            return cell
        }

        
        // generic compiler case, returning cell so it doesn't choke
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla")
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.editMode {
            let key: String = self.dataConfig[indexPath.section]["key"]!
            let collection = self.data[key].arrayValue
            if collection.indices.contains(indexPath.row) {
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let key: String = self.dataConfig[indexPath.section]["key"]!
        let collectionName: String = self.dataConfig[indexPath.section]["collectionName"]!
        if editingStyle == .delete {
            if key == "documents" || key == "directives" {
                // TODO: hook dat common delete son buns
                let collectionItem: JSON = self.data[key][indexPath.row]
                self.confirmDocumentDelete(collectionItem)
            } else {
                print("Launch some Modal confirmer swamp sauce")
                var collectionItem: JSON = self.data[key][indexPath.row]
                collectionItem["_destroy"].bool = true
                // we can temp hack our way through with updateCollection, yea yea yea son
                // we could reasonably easily pass in an additional argumet for "delete" mode on this, so we don't have to duplicate all the network stuffs
                LSQAPI.sharedInstance.updateCollection(
                    self.data["profile"]["uuid"].string!,
                    collection_name: collectionName,
                    data: (collectionItem.object as AnyObject),
                    success: { response in
                        // THIS IS HEAVY AND EXPENSIVE
                        LSQPatientManager.sharedInstance.fetch()
                        let user = LSQUser.currentUser
                        
                        NotificationCenter.default.post(
                            name: LSQ.notification.analytics.event,
                            object: nil,
                            userInfo: [
                                "event": "Patient Edit",
                                "attributes": [
                                    "Scope": collectionName,
                                    "Action": "delete",
                                    "AccountId": user.uuid!,
                                    "Provider": user.provider,
                                    "PatientId": self.data["profile"]["uuid"].string!
                                ]
                            ]
                        )
                        
                    },
                    failure: { response in
                        let alert: UIAlertController = UIAlertController(
                            title: "Server Error",
                            message: "Unable to delete item",
                            preferredStyle: .alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                            // TODO: focus first problem child?
                        })
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                )
            }
            // TODO: work the UI transition state, etc
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key: String = self.dataConfig[indexPath.section]["key"]!
        let cell = self.tableView.cellForRow(at: indexPath)
        
        // are we in a plugin cell, if so bomb out
        if self.dataConfig[indexPath.section]["key"]! == "emergency-promo" {
            return
        }
        
        if cell is LSQCellAddCollectionItem {
            if key == "emergency-actions" {
                if (cell as? LSQCellAddCollectionItem)?.collectionId == "notify-contacts" {
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.messageContacts,
                        object: self,
                        userInfo: nil
                        // do we need to send on the patient model or patientid, blabalablabla here?
                    )
                    return
                }
            }
            
            if key == "directives" || key == "documents" {
                let index1 = key.characters.index(key.endIndex, offsetBy: -1)
                let substring1 = key.substring(to: index1)
                
                // this is a little different, because we're moving through a flow back to some form of editing, blablablabalblablabal
                NotificationCenter.default.post(
                    name: LSQ.notification.show.documentForm,
                    object: self.parent, // what is the parent view controller sonny bunss, blablablablablabalbalablabla
                    userInfo: ["mode": substring1] // chop of the (s)
                )
                return
            } else {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.collectionItemForm,
                    object: self.parent,
                    userInfo: [
                        // this is the Add mode, aka no collectionItem
                        // not the collectionitem.id the "id" aka name of the collection
                        "collectionId": (cell as? LSQCellAddCollectionItem)!.collectionId!
                    ]
                )
            }
            return
        }
        
        if cell is LSQCellEmptyCollection {
            // sorry
        } else if cell is LSQCellPrivacyRestrictedItem {
            // try again
        } else {
            
            if self.editMode {
                
                if key == "directives" || key == "documents" {
                    let index1 = key.characters.index(key.endIndex, offsetBy: -1)
                    let substring1 = key.substring(to: index1)
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.documentForm,
                        object: self.parent,
                        userInfo: [
                            "mode": substring1,
                            "documentInstance": self.data[key][indexPath.row].object
                        ]
                    )
                    return
                }
                
                NotificationCenter.default.post(
                    name: LSQ.notification.show.collectionItemForm,
                    object: self.parent,
                    userInfo: [
                        // this is the Edit mode, w/ collectionItem
                        "collectionItem": self.data[key][indexPath.row].object,
                        "collectionId": key
                    ]
                )
                
            } else {
                
                // only if we have details son, aka peep dat in the config yea son
                if self.dataConfig[indexPath.section]["observePress"] == "yes" {
                    if key == "directives" || key == "documents" {
                        NotificationCenter.default.post(
                            name: LSQ.notification.show.document,
                            object: self,
                            userInfo: [
                                "URL": "\(LSQAPI.sharedInstance.api_root)documents/\((self.data[key][indexPath.row]["uuid"].string)!)/#file-0" // TODO: complete mega super hack here
                            ]
                        )
                        return
                    }
                    
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.patientFragment,
                        object: self,
                        userInfo: [
                            "patient_id": self.data["profile"]["uuid"].string!,
                            "type": key,
                            "data": self.data[key][indexPath.row].object,
                            "editMode": self.editMode // this attribute is pointless
                        ]
                    )
                }
                
                
            }
            
            
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let config: [String: AnyObject] = self.dataConfig[indexPath.section] as [String : AnyObject]
        if config["key"]! as? String == "emergency-promo" {
            return 154.0
        }
        return 44.0
    }
    
    func addObservers() {
        
        self.observationQueue = []
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.loaded.patient2,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if notification.userInfo!["uuid"] as? String == self.data["profile"]["uuid"].string! {
                    self.data = LSQPatientManager.sharedInstance.json!
                    self.tableView.reloadData()
                    // endless loop son
                    self.broadcastSize()
                    
                }
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.replaceCollection,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                
                // filter those pesky health_attributes_by_type my brosef
                let collectionId: String = (notification.userInfo!["collection_id"] as? String)!
                var json: JSON = JSON(notification.userInfo!["value"]!)
                if collectionId == "conditions" || collectionId == "procedures" || collectionId == "immunizations" {
                    // filter that shit son, blablabla ballsack chop the last character off
                    // BE CAREFUL IN CASE WE CHANGE THIS IN THE FUTURE SON
                    let attr: String = collectionId.substring(to: collectionId.characters.index(collectionId.endIndex, offsetBy: -1))
                    let collection:[JSON] = json.arrayValue
                    var matches:[JSON] = []
                    for item in collection {
                        if item["health_event_type"].string == attr {
                            matches.append(item)
                        }
                    }
                    json = JSON(matches)
                }
                
                self.data[collectionId] = json
                // attempt to hacknsleep™
                if LSQOnboardingManager.sharedInstance.active {
                    // questionable, but should work to avoid infinite loop
                    LSQPatientManager.sharedInstance.fetchWithCallbacks(success: {_ in
                        NotificationCenter.default.post(
                            name: LSQ.notification.loaded.patient3,
                            object: self,
                            userInfo: nil
                        )
                    }, failure: {_ in})
                }
                self.tableView.reloadData()
                self.broadcastSize()
            }
        )
        
    }
    
    func removeObservers() {
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    // TODO: this perhaps needs to be moved to viewDidUnload or something not sure of the entire context it can be rendered visually
    deinit {
        self.removeObservers()
    }

    func confirmDocumentDelete(_ item: JSON) {
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        let alert: UIAlertController = UIAlertController(
            title: "Delete Document",
            message: "",
            preferredStyle: preferredStyle)
        
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            
            let user: LSQUser = LSQUser.currentUser
            
            LSQAPI.sharedInstance.deleteDocument(
                item["uuid"].string!,
                success: { response in
                    NotificationCenter.default.post(name: LSQ.notification.analytics.event, object: nil, userInfo:[
                        "event": "Document Delete",
                        "attributes": [
                            "AccountId": user.uuid!,// huh wut?
                            "Provider": user.provider, // huh wut?
                            "PatientId": self.data["profile"]["uuid"].string!,
                            "DocumentId": item["uuid"].string!
                        ]
                    ])
                    LSQPatientManager.sharedInstance.fetch()
                },
                failure: { response in
                    let alert: UIAlertController = UIAlertController(
                        title: "Server Error",
                        message: "Unable to delete document",
                        preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                        // TODO: focus first problem child?
                    })
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            )
            
            
        })
        alert.addAction(deleteAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            // nothing here
        })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
