//
//  LSQEditProfileViewController.swift
//
//  Created by Charles Mastin on 10/25/16.
//

import Foundation
import UIKit
import SwiftyJSON
import Kingfisher

class LSQEditProfileViewController: UITableViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var tableData = [[String:Any?]]()
    var data: JSON = LSQPatientManager.sharedInstance.json!
    var vcParent: LSQProfilePersonalContainerViewController? = nil
    var imageSize: CGFloat = 132.0
    var capturedImage: UIImage? = nil // represents anything captured, and what we should upload if not cleared
    var allFields: [[String: AnyObject]] = []
    var lastFocusedField: UITextField? = nil
    var dirty: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)

        self.tableView.register(UINib(nibName: "CellProfilePhoto", bundle: nil), forCellReuseIdentifier: "CellProfilePhoto")
        self.tableView.register(UINib(nibName: "CellFormInput", bundle: nil), forCellReuseIdentifier: "CellFormInput")
        self.tableView.register(UINib(nibName: "CellFormSelect", bundle: nil), forCellReuseIdentifier: "CellFormSelect")
        self.tableView.register(UINib(nibName: "CellFormCheckbox", bundle: nil), forCellReuseIdentifier: "CellFormCheckbox")
        self.tableView.register(UINib(nibName: "CellFormDatePicker", bundle: nil), forCellReuseIdentifier: "CellFormDatePicker")
        self.tableView.register(UINib(nibName: "CellFormHeightPicker", bundle: nil), forCellReuseIdentifier: "CellFormHeightPicker")
        self.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.tableView.register(LSQCellEmptyCollection.self, forCellReuseIdentifier: "CellEmptyCollection")
        self.tableView.register(LSQCellPrivacyRestrictedItem.self, forCellReuseIdentifier: "CellPrivacyRestrictedItem")
        
        let profileInstance: LSQModelProfile = LSQModelProfile()
        
        // TODO: photo
        let profileFields: [LSQModelFieldC] = [
            profileInstance.firstName,
            profileInstance.middleName,
            profileInstance.lastName,
            profileInstance.suffix,
            profileInstance.birthdate,
            profileInstance.organDonor,
//            profileInstance.searchable
        ]
        
        let demographicsFields: [LSQModelFieldC] = [
            profileInstance.demographicsPrivacy,
            profileInstance.gender,
            profileInstance.ethnicity
        ]
        
        let biometricsFields: [LSQModelFieldC] = [
            profileInstance.biometricsPrivacy,
            profileInstance.hairColor,
            profileInstance.eyeColor,
            profileInstance.height,
            profileInstance.weight,
            profileInstance.bloodType,
            profileInstance.bpSystolic,
            profileInstance.bpDiastolic,
            profileInstance.pulse
        ]
        
        let discoverabilityFields: [LSQModelFieldC] = [
            profileInstance.searchable
        ]
        
        for (index, f) in profileFields.enumerated() {
            self.allFields.append([
                "section": 1 as AnyObject,
                "row": index as AnyObject,
                "field": f
            ])
        }
        for (index, f) in demographicsFields.enumerated() {
            self.allFields.append([
                "section": 2 as AnyObject,
                "row": index as AnyObject,
                "field": f
            ])
        }
        for (index, f) in biometricsFields.enumerated() {
            self.allFields.append([
                "section": 3 as AnyObject,
                "row": index as AnyObject,
                "field": f
            ])
        }
        
        for (index, f) in discoverabilityFields.enumerated() {
            self.allFields.append([
                "section": 6 as AnyObject,
                "row": index as AnyObject,
                "field": f
                ])
        }
        
        // really this is like a mish mash of model meta data and so on, blablablabla
        // to be DRY(ish) we need to define things in the least amount of locations, mmmkay
        
        // putting the getValues up in this constructor of config data is super syncrhonous, but then again, so should that API
        self.tableData = [
            [
                "header": "Photo",
                "id": "photo"
            ],
            [
                "header": "Profile",
                "id": "profile",
                "fields": profileFields
            ],
            [
                "header": "Demographics",
                "id": "demographics",
                "fields": demographicsFields
            ],
            [
                "header": "Biometrics & Vitals",
                "id": "biometrics",
                "fields": biometricsFields
            ],
            [
                "header": "Addresses",
                "id": "addresses",
                "collectionName": LSQModelPatientResidence().collectionName
            ],
            [
                "header": "Spoken Languages",
                "id": "languages",
                "collectionName": LSQModelPatientLanguage().collectionName
            ],
            [
                "header": "Discoverability",
                "id": "discoverability",
                "fields": discoverabilityFields
            ],
        ]
        
        self.addObservers()
        
        // TODO: if we are born on JC birthday, mask out the date so it becomes required, aka legacy web setups/ lol no thanks
        
    }
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.form.field.change,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.dirty = true
                // TODO: slick rick 1 line reducer lol broa
                var allTheFields: [LSQModelFieldC] = []
                for obj in self.allFields {
                    allTheFields.append((obj["field"] as? LSQModelFieldC)!)
                }
                
                let attribute: String = (notification.userInfo!["id"] as? String)!
                let value: AnyObject = notification.userInfo!["value"]! as AnyObject
                
                // if we are weight, convert to kg
                if attribute == "weight" {
                    // probably need to put this deep in the util, because of the whole validation bit on input
                    //
                }
                
                // immutible son
                self.data["profile"] = LSQModelUtils.bindToJson(
                    allTheFields,
                    json: self.data["profile"],
                    attribute: attribute,
                    value: value
                )
                
                if self.vcParent != nil {
                    self.vcParent?.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                //print(self.data["profile"]["middle_name"].string!)
                
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.replaceCollection,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.data[(notification.userInfo!["collection_id"] as? String)!] = JSON(notification.userInfo!["value"]!)
                self.tableView.reloadData()
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.imageCaptured,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.dirty = true
                self.capturedImage = (notification.userInfo!["image"] as? UIImage)!
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.fade)
                if self.vcParent != nil {
                    self.vcParent?.navigationItem.rightBarButtonItem?.isEnabled = true
                }
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
    
    // table town usa sucka
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let title = self.tableData[section]["header"] as? String {
            return title
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let id = self.tableData[section]["id"] as? String {
            if id == "discoverability" {
                return "A Discoverable profile allows licensed medical professionals (like 911-responders) to search for LifeStickers in the vicinity of an address. It also enables family, friends, and care providers to connect with you on HealthNotifier."
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // WTF
        // http://stackoverflow.com/questions/18880341/why-is-there-extra-padding-at-the-top-of-my-uitableview-with-style-uitableviewst
        // let key = tableData[section]
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        var height = UITableViewAutomaticDimension
        
        if section == 0, let header = tableView.headerView(forSection: section) {
            if let label = header.textLabel {
                // get padding below label
                let bottomPadding = header.frame.height - label.frame.origin.y - label.frame.height
                // use it as top padding
                height = label.frame.height + (2 * bottomPadding)
            }
        }
        
        return height
    }
    
    /*
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
    }
    */
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = tableData[section]
        if key["id"] as? String == "photo" {
            return 1
        }
        if key["id"] as? String == "profile" {
            return (key["fields"] as? [LSQModelFieldC])!.count
        }
        if key["id"] as? String == "discoverability" {
            return (key["fields"] as? [LSQModelFieldC])!.count
        }
        if key["id"] as? String == "demographics" {
            return (key["fields"] as? [LSQModelFieldC])!.count
        }
        if key["id"] as? String == "biometrics" {
            return (key["fields"] as? [LSQModelFieldC])!.count
        }
        if key["id"] as? String == "languages" {
            return self.getNumRowsInSection(section)
        }
        if key["id"] as? String == "addresses" {
            return self.getNumRowsInSection(section)
        }
        return 1
    }
    
    func getNumRowsInSection(_ section: Int) -> Int {
        let key = self.tableData[section]
        var numRows: Int = 1
        if let collection = self.data[(key["id"] as? String)!].array {
            // YEA SON!!!!! finally fixed
            numRows = 0
            if collection.count > 0 {
                numRows = collection.count
            }
        }
        // edit mode always on
        numRows += 1
        return numRows
    }
    
    // datepicker lololol
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let key = self.tableData[indexPath.section]
        
        if key["id"] as? String == "photo" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellProfilePhoto", for: indexPath) as! LSQProfileVitalsTableViewCell
            cell.backgroundColor = LSQ.appearance.color.stolenBlue
            cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.width/2.0, 0, tableView.bounds.width/2.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.profilePhoto!.contentMode = UIViewContentMode.scaleAspectFill
            
            if self.capturedImage != nil {
                cell.profilePhoto?.image = self.capturedImage
            } else {
                //cell.imageView?.frame = CGRectMake(0.0, 0.0, self.imageSize, self.imageSize)
                let placeholder = UIImage(named: "selfie_image")
                // let photoUrl: String = "\(LSQAPI.sharedInstance.api_root)profiles/\(self.data["profile"]["uuid"].string!)/profile-photo"
                let photoUrl: String = self.data["profile"]["photo_url"].string!
                cell.profilePhoto?.kf.setImage(
                    with: URL(string: "\(photoUrl)?width=\(Int(self.imageSize * 2))&height=\(Int(self.imageSize * 2))"),
                    placeholder: placeholder,
                    options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)]
                )
            }
            
            // http://stackoverflow.com/questions/29173116/swift-mask-of-circle-layer-over-uiview
            let innerFrame = CGRect(x: 0, y: 0, width: self.imageSize - 2, height: self.imageSize - 2)
            let maskLayer = CAShapeLayer()
            let circlePath = UIBezierPath(roundedRect: innerFrame, cornerRadius: innerFrame.width)
            maskLayer.path = circlePath.cgPath
            maskLayer.fillColor = LSQ.appearance.color.blue.cgColor
            
            let strokeLayer = CAShapeLayer()
            strokeLayer.path = circlePath.cgPath
            strokeLayer.fillColor = UIColor.clear.cgColor
            strokeLayer.strokeColor = LSQ.appearance.color.white.cgColor
            strokeLayer.lineWidth = 2
            
            // add the layer
            cell.profilePhoto!.layer.addSublayer(maskLayer)
            cell.profilePhoto!.layer.mask = maskLayer
            cell.profilePhoto!.layer.addSublayer(strokeLayer)
            
            
            cell.profilePhoto!.isUserInteractionEnabled = true
            
            // tap handler son
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            // tap.delegate = self
            cell.profilePhoto!.addGestureRecognizer(tap)
            
            return cell
            
        }
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "cell_default")
        
        cell.textLabel?.text = "Attribute"
        cell.detailTextLabel?.text = ""
        // default all the editable attributes and so on and so forth
        if key["fields"] != nil {
            let field = (key["fields"] as? [LSQModelFieldC])![indexPath.row]
            var initialValue: String = ""
            
            if field.formControl == "input" {
                if self.data["profile"][field.property].exists() && self.data["profile"][field.property] != JSON.null {
                    if field.dataType == "number" {
                        initialValue = String(describing: self.data["profile"][field.property].number!)
                        // if we're the height masked attribute, lolzones
                        if field.property == "weight" {
                            initialValue = String(LSQ.formatter.weightToImperial(self.data["profile"][field.property].double!))
                        }
                    } else {
                        initialValue = self.data["profile"][field.property].string!
                    }
                    
                }
                
                cell = Forms.generateDefaultInputCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required)
                // now hand yo keyboard limitations son
                (cell as! LSQCellFormInput).input?.keyboardType = field.keyboard
                (cell as! LSQCellFormInput).input?.delegate = self
                // DO THE mclovin on the kind of capitalization and all that shizz ma nizz
            }
            if field.formControl == "select" {
                if self.data["profile"][field.property].exists() && self.data["profile"][field.property] != JSON.null {
                    if field.dataType == "number" {
                        initialValue = String(describing: self.data["profile"][field.property].number!)
                    } else {
                        initialValue = self.data["profile"][field.property].string!
                    }
                }
                cell = Forms.generateDefaultSelectCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required, values: field.values)
            }
            if field.formControl == "checkbox" {
                // initial value son
                // or default
                cell = Forms.generateDefaultCheckboxCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: self.data["profile"][field.property].bool!, required: field.required)
            }
            if field.formControl == "datepicker" {
                // initial value son
                // or default
                if let v = self.data["profile"][field.property].string {
                    if v != "0001-01-01" {
                        initialValue = v
                    } else {
                        // "null" out on da json so we "MUST" fill it, HACK MY BROTHER
                        self.data["profile"][field.property].string = ""
                    }
                }
                cell = Forms.generateDefaultDatePickerCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required)
            }
            if field.formControl == "heightpicker" {
                if let v = self.data["profile"][field.property].number {
                    initialValue = LSQ.formatter.heightToImperial(Int(v))
                }
                cell = Forms.generateDefaultHeightPickerCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required)
            }
        }
        
        // TAKE 2 BROLO
        let collectionId: String = (key["id"] as? String)!
        if collectionId == "languages" || collectionId == "addresses" {
            let collection = self.data[collectionId].arrayValue
            if collection.indices.contains(indexPath.row) {
                let row = collection[indexPath.row]
                if row["error"].exists() {
                    cell = Forms.generatePrivacyRestrictedCell(tableView, indexPath: indexPath)
                } else {
                    let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla")
                    cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
                    // a regular content cell
                    if let title = row["title"].string {
                        cell.textLabel?.text = title
                    }
                    if let description = row["description"].string {
                        cell.detailTextLabel?.text = description
                    }
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    return cell
                }
            } else {
                cell = Forms.generateAddCollectionItemCell(tableView, indexPath: indexPath, collectionId: collectionId)
                if collectionId == "languages" {
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Add Language"
                }
                if collectionId == "addresses" {
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Add Address"
                }
            }
        }
        
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.lastFocusedField != nil {
            self.lastFocusedField?.resignFirstResponder()
        }
        let key: String = (self.tableData[indexPath.section]["id"] as? String)!
        let cell = self.tableView.cellForRow(at: indexPath)
        
        if key == "photo" {
            return
        }
        
        if cell is LSQCellAddCollectionItem {
            NotificationCenter.default.post(
                name: LSQ.notification.show.collectionItemForm,
                object: self.parent,
                userInfo: [
                    // this is the Add mode, aka no collectionItem
                    // not the collectionitem.id the "id" aka name of the collection
                    "collectionId": (cell as? LSQCellAddCollectionItem)!.collectionId!
                ]
            )
            return
        }
        // raw profile attributes son
        if cell is LSQCellFormSelect {
            // THIS IS FUNbecause, all the properties are IN PROFILE SON
            let field = (self.tableData[indexPath.section]["fields"] as? [LSQModelFieldC])![indexPath.row]
            var value: String = ""
            if self.data["profile"][field.property] != JSON.null {
                if field.dataType == "number" {
                    value = String(describing: self.data["profile"][field.property].number!)
                } else {
                    value = (self.data["profile"][field.property].string!)
                }
            }
            
            NotificationCenter.default.post(
                name: LSQ.notification.show.formSelect,
                object: self.parent,
                userInfo: [
                    "id": (cell as? LSQCellFormSelect)!.id,
                    "title": field.label,
                    "value": value,
                    "values": (cell as? LSQCellFormSelect)!.values
                ]
            )
            return
        }
        
        if cell is LSQCellFormDatePicker {
            // THIS IS FUNbecause, all the properties are IN PROFILE SON
            let field = (self.tableData[indexPath.section]["fields"] as? [LSQModelFieldC])![indexPath.row]
            var userInfo: [String: AnyObject] = [
                "id": (cell as? LSQCellFormDatePicker)!.id as AnyObject,
                "title": field.label as AnyObject
            ]
            // convert that to a whatchat
            if let v = self.data["profile"][field.property].string {
                if v != "" && v != "0001-01-01" {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let subStr = v.substring(to: v.index(v.startIndex, offsetBy: 10))
                    userInfo["value"] = dateFormatter.date(from: subStr) as AnyObject?
                }
            }
            
            NotificationCenter.default.post(
                name: LSQ.notification.show.formDatePicker,
                object: self.parent,
                userInfo: userInfo
            )
            return
        }
        
        if cell is LSQCellFormHeightPicker {
            let field = (self.tableData[indexPath.section]["fields"] as? [LSQModelFieldC])![indexPath.row]
            var userInfo: [String: AnyObject] = [
                "id": (cell as? LSQCellFormHeightPicker)!.id as AnyObject,
                "title": field.label as AnyObject
            ]
            
            if let v = self.data["profile"][field.property].number {
                userInfo["value"] = Int(v) as AnyObject?
            }
            
            // serialize existing height from CM son, this is a bit sketchy since we're now losing precision, WTF AMERICANS
            NotificationCenter.default.post(
                name: LSQ.notification.show.formHeightPicker,
                object: self.parent,
                userInfo: userInfo
            )
            return
        }

        
        if cell is LSQCellFormCheckbox {
            return
        }
        
        if cell is LSQCellFormInput {
            return
        }
        
        // collection items
        if cell is LSQCellEmptyCollection {
            // sorry
        } else if cell is LSQCellPrivacyRestrictedItem {
            // try again
        } else {
            
            // this form is only edit son
            NotificationCenter.default.post(
                name: LSQ.notification.show.collectionItemForm,
                object: self.parent,
                userInfo: [
                    // this is the Edit mode, w/ collectionItem
                    "collectionItem": self.data[key][indexPath.row].object,
                    "collectionId": key
                ]
            )
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let key: String = (self.tableData[indexPath.section]["id"] as? String)!
        if key == "languages" || key == "addresses" {
            let collection = self.data[key].arrayValue
            if collection.indices.contains(indexPath.row) {
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let key: String = (self.tableData[indexPath.section]["id"] as? String)!
        let collectionName: String = (self.tableData[indexPath.section]["collectionName"] as? String)!
        if collectionName != "" && editingStyle == .delete {
            var collectionItem: JSON = self.data[key][indexPath.row]
            collectionItem["_destroy"].bool = true
            // we can temp hack our way through with updateCollection, yea yea yea son
            // we could reasonably easily pass in an additional argumet for "delete" mode on this, so we don't have to duplicate all the network stuffs
            // TODO: DRY THIS UP
            LSQAPI.sharedInstance.updateCollection(
                self.data["profile"]["uuid"].string!,
                collection_name: collectionName,
                data: (collectionItem.object as AnyObject),
                success: { response in
                    // TODO: this is broken!!, meh
                    // locally ditch the row, and reload the table, lolzors r us
                    self.data[key].arrayObject?.remove(at: indexPath.row)
                    //var indexPaths: [NSIndexPath] = []
                    //self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                    self.tableView.reloadData() // only in the select range, son
                    
                    // delete analytics on that guy son
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
            
            // TODO: work the UI transition state, etc
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let key: String = (self.tableData[indexPath.section]["id"] as? String)!
        if key == "photo" {
            return self.imageSize + 66.0 // LOLZONE
        }
        return 56.0
    }
    
    // text delegates son
    
    // helper to find field amongst our sections, lol bro
    // this will back fill into the other and become a generic base class features son
    // after we sort out some deets son
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = true
        
        if let instance: LSQCellFormInput = (textField.superview?.superview) as? LSQCellFormInput {
            // find in the fields array, get the index and go one more yea son
            for (index, obj) in self.allFields.enumerated() {
                if (obj["field"] as? LSQModelFieldC)!.property == instance.id {
                    // next field
                    if self.allFields.indices.contains(index+1) {
                        let nextIndexPath: IndexPath = IndexPath(
                            row: (self.allFields[index+1]["row"] as? Int)!,
                            section: (self.allFields[index+1]["section"] as? Int)!
                        )
                        if let nextField: LSQModelFieldC = self.allFields[index+1]["field"] as? LSQModelFieldC {
                            if nextField.formControl == "input" {
                                let cell: UITableViewCell = self.tableView.cellForRow(at: nextIndexPath)!
                                (cell as! LSQCellFormInput).input?.becomeFirstResponder()
                                return true
                            }
                            if nextField.formControl != "checkbox" {
                                textField.resignFirstResponder()
                                self.tableView.selectRow(at: nextIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.middle)
                                self.tableView(self.tableView, didSelectRowAt: nextIndexPath)
                                return false
                            }
                        }
                    } else {
                        // END OF THE ROAD SON
                        // let's do the submit town
                        if index == self.allFields.count - 1 {
                            textField.resignFirstResponder()
                            // self.handleDone()
                        }
                    }
                }
            }
        }
        
        return shouldReturn
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // DRY UP THE ACCESS CODE, so we can say GO and to the submit on the last text item yea son
        self.lastFocusedField = textField
        textField.returnKeyType = UIReturnKeyType.next
        
        // make it GO, only if we're the last index
        if let instance: LSQCellFormInput = (textField.superview?.superview) as? LSQCellFormInput {
            // find in the fields array, get the index and go one more yea son
            for (index, obj) in self.allFields.enumerated() {
                if (obj["field"] as? LSQModelFieldC)!.property == instance.id {
                    if self.allFields.indices.contains(index+1) {
                        
                        // is our nextField a checkbox
                        /*
                        if let nextField: LSQModelFieldC = next as? LSQModelFieldC {
                            if nextField.formControl == "checkbox" {
                                // textField.returnKeyType = UIReturnKeyType.Default
                            }
                        }
                        */
                        
                    } else {
                        if index == self.allFields.count - 1 {
                            textField.returnKeyType = UIReturnKeyType.done
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    func validateForm() -> Bool {
        var allTheFields: [LSQModelFieldC] = []
        for obj in self.allFields {
            allTheFields.append((obj["field"] as? LSQModelFieldC)!)
        }
        
        let errors:[[String:AnyObject]] = LSQModelUtils.validateForm(allTheFields, json: self.data["profile"])
        
        // also, require the whole, must have at least one address son
        // this is sketchy, w/e
        print("DISABLE RESIDENCE CHECK")
        /*
        if self.data["addresses"].arrayValue.count == 0 {
            errors.append([
                "message": "Please input at least 1 residence" as AnyObject,
                "field": "" as AnyObject // uggg can't be nil, but it is nil, lame swift
            ])
        }
        */
        if errors.count > 0 {
            var messages: [String] = []
            for (_, value) in errors.enumerated() {
                messages.append(value["message"] as! String)
            }
            
            let alert: UIAlertController = UIAlertController(
                title: "Validation Errors",
                message: messages.joined(separator: "\n") ,
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }

    func onSave() -> Bool {
        // we are eager, vs waiting for the profile to fully persist, which we should do and then use async messaging
        if self.validateForm() {
            var profileData = self.data["profile"]
            LSQAPI.sharedInstance.updateProfile(self.data["profile"]["uuid"].string!, json: profileData.object as AnyObject)
            
            let user = LSQUser.currentUser
            
            NotificationCenter.default.post(
                name: LSQ.notification.analytics.event,
                object: nil,
                userInfo: [
                    "event": "Patient Edit",
                    "attributes": [
                        "Scope": "profile",
                        "AccountId": user.uuid!,
                        "Provider": user.provider,
                        "PatientId": self.data["profile"]["uuid"].string!
                    ]
                ]
            )
            
            return true
        }
        return false
    }
    
    func getValidatedProfileToSave() -> JSON {
        // TODO: check in the practice for this kind of aborting return
        if self.validateForm() {
            return self.data["profile"]
        }
        return false
    }
    
    func handleTap(_ sender: UITapGestureRecognizer?) {
        // we could bake that bread into the first event lol
        NotificationCenter.default.post(
            name: LSQ.notification.action.chooseCaptureMethod,
            object: self,
            userInfo: [
                // if less than 2, just do the thing directly, lol
                // "methods": ["photo", "library"],// this should be the default son
                "selfie": true // prefere
            ]
        )
    }
}
