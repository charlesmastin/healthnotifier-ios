//
//  LSQEditCollectionItemViewController.swift
//
//  Created by Charles Mastin on 10/28/16.
//

import Foundation
import UIKit
import SwiftyJSON
import Contacts
import ContactsUI
import EZLoadingActivity

class LSQEditCollectionItemViewController: UITableViewController, UINavigationControllerDelegate, UITextFieldDelegate, CNContactPickerDelegate {
    
    @IBAction func handleDone() {
        // proof of concept to be dry'd up
        if self.validateForm() {
            EZLoadingActivity.show("", disableUI: false)
            LSQAPI.sharedInstance.updateCollection(
                self.patientUuid,
                collection_name: self.collectionName,
                data: self.collectionItem!.object as AnyObject,
                success: { response in
                    // OMH SON
                    EZLoadingActivity.hide(true, animated: true)
                    
                    NotificationCenter.default.post(
                        name: LSQ.notification.hacks.replaceCollection,
                        object: self,
                        userInfo: [
                            "uuid": self.patientUuid,
                            "value": response,
                            "collection_id": self.collectionId!,
                            "collection_name": self.collectionName
                        ]
                    )
                    
                    let user = LSQUser.currentUser
                    var action: String = "update"
                    if self.modeCreate {
                        action = "create"
                    }
                    NotificationCenter.default.post(
                        name: LSQ.notification.analytics.event,
                        object: nil,
                        userInfo: [
                            "event": "Patient Edit",
                            "attributes": [
                                "Scope": self.collectionName,
                                "Action": action,
                                "AccountId": user.uuid!,
                                "Provider": user.provider,
                                "PatientId": self.patientUuid
                            ]
                        ]
                    )

                    self.close()
                    
                },
                failure: { response in
                    EZLoadingActivity.hide(false, animated: true)
                    var message: String = "Unkown Server Error"
                    if response.data != nil {
                        let json: JSON = JSON(response.result)
                        if let m = json["message"].string {
                            message = m
                        }
                    }
                    let alert: UIAlertController = UIAlertController(
                        title: "Error",
                        message: message,
                        preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    })
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            )
        }
    }
    
    func validateForm() -> Bool {
        // THIS SON, is the concrete implementation of things
        // we fetch the context specific data
        // send to the library
        // and display validation errors (w/ or w/o a helper)
        let errors:[[String:AnyObject]] = LSQModelUtils.validateForm(self.fields, json: (self.collectionItem)!)
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
                // TODO: focus first problem child?
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
            return false
        }
        return true
    }
    
    var collectionId: String? = nil
    var collectionItem: JSON? = nil
    var collectionName: String = ""
    
    // 
    var lastFocusedField: UITextField? = nil
    
    // OH MY SON
    var modeCreate: Bool = false
    var patientUuid: String = ""
    
    // this allows us to position additional "sections" and do plugins for special cases
    var tableConfig: [[String: AnyObject]] = []
    
    // our actual internal data structure son
    var data: [String: AnyObject] = [:]
    
    var fields: [LSQModelFieldC] = []
    var visibleFields: [LSQModelFieldC] = []
    
    var observationQueue: [AnyObject] = []
    
    var dirty: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LSQAppearanceManager.sharedInstance.underlinedInputs = false

        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        
        self.tableView.register(UINib(nibName: "CellFormInput", bundle: nil), forCellReuseIdentifier: "CellFormInput")
        self.tableView.register(UINib(nibName: "CellFormSelect", bundle: nil), forCellReuseIdentifier: "CellFormSelect")
        self.tableView.register(UINib(nibName: "CellFormCheckbox", bundle: nil), forCellReuseIdentifier: "CellFormCheckbox")
        self.tableView.register(UINib(nibName: "CellFormAutocomplete", bundle: nil), forCellReuseIdentifier: "CellFormAutocomplete")
        self.tableView.register(UINib(nibName: "CellFormDatePicker", bundle: nil), forCellReuseIdentifier: "CellFormDatePicker")
        
        // our generic cell "button" yo
        
        self.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")

        
        // validation on "BACK" son
        // unable to do "back" full on w/e
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.onCancel))
        // hook gestures
        
        self.addObservers()
        
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.tableView.backgroundColor = UIColor.clear
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        if LSQAppearanceManager.sharedInstance.cellSeparatorColor != nil {
            self.tableView.separatorColor = LSQAppearanceManager.sharedInstance.cellSeparatorColor
        }
    }
    
    func onCancel() {
        if self.dirty {
            // block it
            let alert: UIAlertController = UIAlertController(
                title: "You Have Unsaved Changes",
                message: "",
                preferredStyle: .alert)
            
            let pauseAction: UIAlertAction = UIAlertAction(title:"Disregard Changes", style: UIAlertActionStyle.default, handler: { action in
                self.close()
            })
            let cancelAction: UIAlertAction = UIAlertAction(title:"Continue Editing", style: UIAlertActionStyle.cancel, handler: { action in
            })
            alert.addAction(pauseAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.close()
        }
    }
    
    func addObservers() {
        self.observationQueue = []
        // THIS IS A plugin for the medication -> dose relationship
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.form.field.change,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // are we a therapy
                self.dirty = true

                if notification.userInfo!["id"] as? String == "therapy" {
                    LSQAPI.sharedInstance.getMedicationDose((notification.userInfo!["value"] as? String)!)
                }
                self.collectionItem = LSQModelUtils.bindToJson(
                    self.fields,
                    json: self.collectionItem!,
                    attribute: (notification.userInfo!["id"] as? String)!,
                    value: notification.userInfo!["value"]! as AnyObject
                )
                
                // if it was country, do a re-render just because yea yea??
                if (notification.userInfo!["id"] as? String) == "country" {
                    self.configureVisibleFields()
                    self.tableView.reloadData()
                }
                // meh
                if (notification.userInfo!["id"] as? String) == "lifesquare_location_type" {
                    self.configureVisibleFields()
                    self.tableView.reloadData()
                }
                
                
             }
        )
        // dose handler
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.loaded.medicationDose,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.pluginPopulateDose(notification.userInfo!["results"]! as AnyObject)
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
    
    // listen for value changes, and do "plugins ON things"
    // medication.theraphy -> query up demo dose values SON - find da first match on da result, transform data, and populate results
    
    func doubleSecretInit(_ data: JSON? = nil) {        
        self.fields = []
        self.visibleFields = []
        self.tableConfig = []
        // FML this is the entire schema - aka model definition
        
        // whatever, we can refactor how this is called, but naturally, we're invoking this from only one place in the global notification handler
        
        // what are the umm, per attribute defaults and so on, we'll do that "hard-coded" in the meta definitions,
        // lol, so much fun, seems like we need this coming out of our API
        // but that would be asking too much
        
        // TODO: DRY UP ALL THE COMMON STUFF HERE IF POSSIBLE
        
        if self.collectionId == "languages" {
            self.title = "Language"
            let collectionInstance = LSQModelPatientLanguage()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.code,
                collectionInstance.proficiency
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
        }
        
        if self.collectionId == "addresses" {
            self.title = "Address"
            let collectionInstance = LSQModelPatientResidence()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.address1,
                collectionInstance.address2,
                collectionInstance.city,
                collectionInstance.state,
                collectionInstance.stateSelect,// a well-formed version based on country selection
                collectionInstance.zip,
                collectionInstance.country,
                collectionInstance.residenceType,
                collectionInstance.lifesquareLocation,
                collectionInstance.lifesquareLocationOther, // TODO: conditionally show this son, a lil tricky
                collectionInstance.mailingAddress,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
            // use a bulk process on the server to set all addresses entered in the last 2 years to US, because, that's all it can be
            // we don't want to have an incomplete record when going to "edit" this and just needing to pick a country, lame 
            // handle the state initial state lol ololololololol FML FML FML FML
            //
            //
            // if country is not US,
            //
        }
        
        if self.collectionId == "medications" {
            self.title = "Medication"
            let collectionInstance = LSQModelPatientTherapy()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.medication,
                collectionInstance.dose,
                collectionInstance.frequency,
                collectionInstance.quantity,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            } else {
                // oh my attempt to hijack in the value yea son
                if let therapy = self.collectionItem?["therapy"].string {
                    if therapy != "" {
                        LSQAPI.sharedInstance.getMedicationDose(therapy)
                    }
                }
                // also set the value though son
            }
        }
        
        if self.collectionId == "allergies" {
            self.title = "Allergy"
            let collectionInstance = LSQModelPatientAllergy()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.allergen,
                collectionInstance.reaction,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
        }
        
        if self.collectionId == "immunizations" {
            self.title = "Immunization"
            let collectionInstance = LSQModelPatientImmunization()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.healthEvent,
                collectionInstance.startDate,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
        }
        
        if self.collectionId == "conditions" {
            self.title = "Condition"
            let collectionInstance = LSQModelPatientCondition()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.healthEvent,
                collectionInstance.startDate,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
        }
        
        if self.collectionId == "procedures" {
            self.title = "Procedure or Device"
            let collectionInstance = LSQModelPatientProcedure()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.healthEvent,
                collectionInstance.startDate,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
        }
        
        // TODO: pregancy
        
        if self.collectionId == "emergency" {
            self.title = "Emergency Contact"
            let collectionInstance = LSQModelPatientContact()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.firstName,
                collectionInstance.lastName,
                collectionInstance.relationship,
                collectionInstance.phone,
                collectionInstance.email,
                collectionInstance.notificationPostscan,
                collectionInstance.powerOfAttorney,
                collectionInstance.nextOfKin,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
                // TODO: use the improved model attribute defaults support lol failzors town
                // self.collectionItem!["privacy"].string = "public"
                self.collectionItem!["notification_postscan"].bool = true
            }
            if self.modeCreate {
                self.tableConfig.append([
                    "id": "importcontact" as AnyObject,
                    "header": "" as AnyObject
                ])
            }
        }
        
        if self.collectionId == "insurances" {
            self.title = "Insurance Policy"
            let collectionInstance = LSQModelPatientInsurance()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                //collectionInstance.photoFront,
                //collectionInstance.photoBack,
                collectionInstance.orgName,
                collectionInstance.phone,
                collectionInstance.policyCode,
                collectionInstance.groupCode,
                collectionInstance.firstName,
                collectionInstance.lastName,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
        }
        
        if self.collectionId == "care_providers" {
            self.title = "Physician"
            let collectionInstance = LSQModelPatientCareProvider()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.firstName,
                collectionInstance.lastName,
                collectionInstance.phone,
                collectionInstance.specialization,
                collectionInstance.facilityName,
                collectionInstance.address1,
                collectionInstance.address2,
                collectionInstance.city,
                collectionInstance.state,
                collectionInstance.stateSelect,
                collectionInstance.zip,
                collectionInstance.country,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
        }
        
        if self.collectionId == "hospitals" {
            self.title = "Hospital"
            let collectionInstance = LSQModelPatientMedicalFacility()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.name,
                collectionInstance.phone,
                collectionInstance.address1,
                collectionInstance.city,
                collectionInstance.state,
                collectionInstance.stateSelect,
                collectionInstance.zip,
                collectionInstance.country,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
        }
        
        if self.collectionId == "pharmacies" {
            self.title = "Pharmacy"
            let collectionInstance = LSQModelPatientPharmacy()
            self.collectionName = collectionInstance.collectionName
            self.fields = [
                collectionInstance.name,
                collectionInstance.phone,
                collectionInstance.address1,
                collectionInstance.city,
                collectionInstance.state,
                collectionInstance.stateSelect,
                collectionInstance.zip,
                collectionInstance.country,
                collectionInstance.privacy
            ]
            if self.collectionItem == nil {
                self.collectionItem = collectionInstance.getDefaultJson()
            }
        }
        
        // "pre" items are already pushed above son
        // do the common things, like push the fields, and the delete if we're in edit mode son
        self.tableConfig.append([
            "id": "form" as AnyObject,
            "header": "" as AnyObject
        ])
        if !self.modeCreate {
            self.tableConfig.append([
                "id": "delete" as AnyObject,
                "header": "" as AnyObject
            ])
        }
        // or any "post" items on a per collection basis, yea son
        self.configureVisibleFields()
        
        self.tableView.reloadData()
        
    }
    
    func configureVisibleFields() -> Void {
        // ALWAYS START WITH A FRESH "SLICE" SON
        self.visibleFields = self.fields
        
        // COUNTRY STATE PLUGIN
        if self.collectionId == "addresses" ||
            self.collectionId == "pharmacies" ||
            self.collectionId == "hospitals" ||
            self.collectionId == "care_providers" {
        
            // if I was so inclined I would make a lookup for the index of the field id, yo
            // however I like to ride dangerously
            // have an interation that finds the index of bla, so I can you know,
            // re-order fields without crapping my pants
            var index1: Int = 0 // index of raw state
            var index2: Int = 0 // index of state select
            let len: Int = self.fields.count - 1
            if self.collectionId == "addresses" {
                index1 = 3
                index2 = 4
            }
            if self.collectionId == "pharmacies" || self.collectionId == "hospitals" {
                index1 = 4
                index2 = 5
            }
            if self.collectionId == "care_providers" {
                index1 = 8
                index2 = 9
            }
            // YUNOHASSPLICE?
            if self.collectionItem?["country"].string == "US" {
                let slice1: ArraySlice<LSQModelFieldC> = self.fields[0...(index1-1)]
                let slice2: ArraySlice<LSQModelFieldC> = self.fields[index2...len]
                self.visibleFields = Array(slice1 + slice2)
            } else {
                let slice1: ArraySlice<LSQModelFieldC> = self.fields[0...index1]
                let slice2: ArraySlice<LSQModelFieldC> = self.fields[(index2+1)...len]
                self.visibleFields = Array(slice1 + slice2)
            }
        }
        
        // specific lifesquare location visibility plugin
        // big note, the "index" hacking has to consider the length has changed
        // becaused we already hid one of the preceding items for state
        if self.collectionId == "addresses" {
            // TODO: or never
            // meh, let's take a risk, and assume the front work is already complete, so we can "splice"
            // based on 1 less item and index
            // let index1: Int = 7 // index type
            let index: Int = 8 // index type other
            let len: Int = self.visibleFields.count - 1
            // database enum is janky town panky town, my bad
            if self.collectionItem?["lifesquare_location_type"].string == "Other" {
                // show it - non OP
            } else {
                // hide it
                let slice1: ArraySlice<LSQModelFieldC> = self.visibleFields[0...(index-1)]
                let slice2: ArraySlice<LSQModelFieldC> = self.visibleFields[(index+1)...len]
                self.visibleFields = Array(slice1 + slice2)
            }
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableConfig.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let config: [String: AnyObject] = self.tableConfig[section]
        if config["id"]! as? String == "form" {
            return self.visibleFields.count
        }
        if config["id"]! as? String == "delete" {
            return 1
        }
        // plugins and such, bwaaa bwaaa
        if config["id"]! as? String == "importcontact" {
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell_default")

        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            cell.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.black.withAlphaComponent(0.8)
            cell.detailTextLabel?.textColor = UIColor.black.withAlphaComponent(0.6)
        }
        
        let config: [String: AnyObject] = self.tableConfig[indexPath.section]
        if config["id"]! as? String == "form" {
        
        }
        if config["id"]! as? String == "importcontact" {
            cell = Forms.generateAddCollectionItemCell(tableView, indexPath: indexPath, collectionId: "importcontact")
            (cell as? LSQCellAddCollectionItem)?.labelText = "Import From Contacts on Phone"
            // create dat cell SON BUNS
            // cell.detailTextLabel?.text = "Import From Contacts"
            // cell.detailTextLabel?.textColor = UIColor.redColor()
            return cell
        }
        if config["id"]! as? String == "delete" {
            cell.detailTextLabel?.text = "Delete"
            // TODO: bro
            cell.detailTextLabel?.textColor = UIColor.red
            return cell
        }
        
        // pass onwards if we're essentially in da form son
        
        let field = self.visibleFields[indexPath.row]
        
        cell.textLabel?.text = field.label
        cell.detailTextLabel?.text = ""

        var initialValue: String = ""
        
        // no key in json, let's try not to crash
        if !(self.collectionItem?[field.property].exists())! {
            return cell
        }
        
        if field.formControl == "input" {
            if self.collectionItem != nil && self.collectionItem?[field.property] != nil {
                if field.dataType == "number" {
                    initialValue = String(describing: self.collectionItem?[field.property].number!)
                } else {
                    initialValue = (self.collectionItem?[field.property].string!)!
                }
            }
            cell = Forms.generateDefaultInputCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required)
            (cell as! LSQCellFormInput).input?.keyboardType = field.keyboard
            (cell as! LSQCellFormInput).input?.delegate = self
        }
        if field.formControl == "select" {
            // TODO: handle data type conversion son
            if self.collectionItem != nil && self.collectionItem![field.property].exists() && self.collectionItem![field.property] != JSON.null {
                if field.dataType == "number" {
                    initialValue = String(describing: self.collectionItem?[field.property].number!)
                } else {
                    initialValue = (self.collectionItem?[field.property].string!)!
                }
            }
            cell = Forms.generateDefaultSelectCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required, values: field.values)
        }
        if field.formControl == "autocomplete" {
            
            if self.collectionItem != nil && self.collectionItem![field.property].exists() && self.collectionItem![field.property] != JSON.null {
                initialValue = (self.collectionItem?[field.property].string!)!
            }
            cell = Forms.generateDefaultAutocompleteCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required, autocompleteId: field.autocompleteId)
        }
        if field.formControl == "checkbox" {
            var initialBool: Bool = false
            if self.collectionItem != nil {
                initialBool = (self.collectionItem?[field.property].bool!)!
            }
            cell = Forms.generateDefaultCheckboxCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialBool, required: field.required)
        }
        
        if field.formControl == "datepicker" {
            if self.collectionItem != nil && self.collectionItem![field.property].exists() && self.collectionItem![field.property] != JSON.null {
                initialValue = (self.collectionItem?[field.property].string!)!
                if initialValue.characters.count > 0 {
                    let subStr = initialValue[initialValue.startIndex...initialValue.characters.index(initialValue.startIndex, offsetBy: 9)]
                    initialValue = subStr
                }
            }
            cell = Forms.generateDefaultDatePickerCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.lastFocusedField != nil {
            self.lastFocusedField?.resignFirstResponder()
        }
        
        let config: [String: AnyObject] = self.tableConfig[indexPath.section]
        let cell = self.tableView.cellForRow(at: indexPath)
        if config["id"]! as? String == "form" {
            let field = self.visibleFields[indexPath.row]
            var value: String = ""
            if self.collectionItem != nil && self.collectionItem![field.property].exists() && self.collectionItem![field.property] != JSON.null {
                if field.dataType == "number" {
                    value = String(describing: self.collectionItem?[field.property].number!)
                } else if field.dataType == "boolean" {
                    
                } else {
                    value = (self.collectionItem?[field.property].string!)!
                }
            }
            
            // try to find da current value son, and force it down to a string, for basic comparison
            if cell is LSQCellFormSelect {
                // TODO: do we move this interally sucka
                NotificationCenter.default.post(
                    name: LSQ.notification.show.formSelect,
                    object: self,
                    userInfo: [
                        "id": (cell as? LSQCellFormSelect)!.id,
                        "title": field.label,
                        "value": value, // TODO Current Value Son
                        "values": (cell as? LSQCellFormSelect)!.values
                    ]
                )
            }
            
            if cell is LSQCellFormDatePicker {
                // THIS IS FUNbecause, all the properties are IN PROFILE SON
                let field = self.visibleFields[indexPath.row]
                var userInfo: [String: AnyObject] = [
                    "id": (cell as? LSQCellFormDatePicker)!.id as AnyObject,
                    "title": field.label as AnyObject
                ]
                // convert that to a whatchat
                // we basically store in db, timestamps, and dates which "begin" with the same format for date, LOL ZONE BRO
                if let v = self.collectionItem?[field.property].string {
                    if v != "" && v != "0001-01-01" {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let subStr = v.substring(to: v.index(v.startIndex, offsetBy: 10))
                        userInfo["value"] = dateFormatter.date(from: subStr) as AnyObject?
                    }
                }
                
                NotificationCenter.default.post(
                    name: LSQ.notification.show.formDatePicker,
                    object: self,
                    userInfo: userInfo
                )
                return
            }
            
            
            if cell is LSQCellFormAutocomplete {
                // TODO: do we move this interally sucka
                NotificationCenter.default.post(
                    name: LSQ.notification.show.formAutocomplete,
                    object: self,
                    userInfo: [
                        "id": (cell as? LSQCellFormAutocomplete)!.id,
                        "title": field.label,
                        "value": value, // TODO Current Value Son
                        "autocompleteId": (cell as? LSQCellFormAutocomplete)!.autocompleteId
                    ]
                )
            }
        }
        if config["id"]! as? String == "importcontact" {
            // this could just as easily send an event to the mediator, in case we want to capture globally
            self.addExistingContact()
        }
        if config["id"]! as? String == "delete" {
            if self.collectionName != "" {
                self.collectionItem!["_destroy"].bool = true
                // we can temp hack our way through with updateCollection, yea yea yea son
                // we could reasonably easily pass in an additional argumet for "delete" mode on this, so we don't have to duplicate all the network stuffs
                EZLoadingActivity.show("", disableUI: false)
                LSQAPI.sharedInstance.updateCollection(
                    self.patientUuid,
                    collection_name: collectionName,
                    data: (self.collectionItem!.object as AnyObject),
                    success: { response in
                        EZLoadingActivity.hide(true, animated: true)
                        
                        LSQPatientManager.sharedInstance.fetch()
                        
                        let user = LSQUser.currentUser
                        
                        NotificationCenter.default.post(
                            name: LSQ.notification.analytics.event,
                            object: nil,
                            userInfo: [
                                "event": "Patient Edit",
                                "attributes": [
                                    "Scope": self.collectionName,
                                    "Action": "delete",
                                    "AccountId": user.uuid!,
                                    "Provider": user.provider,
                                    "PatientId": self.patientUuid
                                ]
                            ]
                        )
                        
                        self.close()
                    },
                    failure: { response in
                        EZLoadingActivity.hide(true, animated: true)
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
        
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    func addExistingContact(){
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // zero out in-between imports so we don't muddy the waters
        // right we could just re-init, lolzones
        let collectionInstance = LSQModelPatientContact()
        self.collectionItem = collectionInstance.getDefaultJson()
        if contact.givenName != "" {
            self.collectionItem!["first_name"].string = contact.givenName
        }
        if contact.familyName != "" {
            self.collectionItem!["last_name"].string = contact.familyName
        }
        if contact.phoneNumbers.count > 0 {
            // need to strip the country code and non numerics
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                self.collectionItem!["home_phone"].string = LSQ.formatter.phoneStringSquash(phoneNumber)
            }
        }
        if contact.emailAddresses.count > 0 {
            if let email = contact.emailAddresses.first?.value {
                self.collectionItem!["email"].string = email as String
            }
        }
        
        // hard load our notify when scanned though
        self.collectionItem!["notification_postscan"].bool = true
        
        self.dirty = true
        self.tableView.reloadData()
    }

    
    internal func getIndexForTextField(_ textField: UITextField) -> Int {
        return 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = true
        
        if let instance: LSQCellFormInput = (textField.superview?.superview) as? LSQCellFormInput {
            // find in the fields array, get the index and go one more yea son
            for (index, f) in self.fields.enumerated() {
                if f.property == instance.id {
                    // next field
                    if index + 1 <= self.visibleFields.count {
                        let nextField: LSQModelFieldC = self.visibleFields[index+1]
                        let nextIndexPath: IndexPath = IndexPath(row: index+1, section:0)
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
                    } else {
                        // redundant
                        if index == self.fields.count - 1 {
                            textField.resignFirstResponder()
                            self.handleDone()
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
            for (index, f) in self.fields.enumerated() {
                if f.property == instance.id {
                    // if the next one is not a field you can "edit" like a checkbox, just do Return
                    if index == self.fields.count - 1 {
                        textField.returnKeyType = UIReturnKeyType.done
                    }
                    /*
                    if let nextField: LSQModelFieldC = self.visibleFields[index+1] {
                        if nextField.formControl == "checkbox" {
                            // textField.returnKeyType = UIReturnKeyType.Default
                        }
                    } else {
                        if index == self.fields.count - 1 {
                            textField.returnKeyType = UIReturnKeyType.done
                        }
                    }
                    */
                }
            }
        }
        
        return true
    }
    
    func pluginPopulateDose(_ response: AnyObject) {
        // find da matching table cell, and populate da values after some choice data transformations
        // yea son iterate and look for cell.id = therapy_strength_form but that's hard because we have polymorphism MF MF MF MF MF MF
        // in an extremely terrible way, we might query directly by index but that's really terrible
        var values: [[String: AnyObject]] = []
        if response["routes"] != nil {
            for obj in (response["routes"] as? [String])! {
                values.append(["name": obj as AnyObject, "value": obj as AnyObject])
            }
        }
        // sketchy
        for i in 0..<self.fields.count {
            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0))
            if cell is LSQCellFormSelect {
                let cellId:String = (cell as? LSQCellFormSelect)!.id
                if cellId == "therapy_strength_form" {
                    // HOLY WTF BATMAN
                    (cell as? LSQCellFormSelect)!.values = values
                    // also if we have an existing value, setInitialValue yea son! yea son
                    if self.collectionItem?["therapy_strength_form"] != nil {
                        (cell as? LSQCellFormSelect)!.setInitial((self.collectionItem?["therapy_strength_form"].string!)!)
                    }
                    return
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*
        let config: [String: AnyObject] = self.dataConfig[indexPath.section] as [String : AnyObject]
        
        if config["key"]! as? String == "emergency-promo" {
            return 154.0
        }
         */
        return 56.0
    }
    
}

// http://stackoverflow.com/questions/5115135/uinavigationcontroller-how-to-cancel-the-back-button-event
/*
extension LSQEditCollectionItemViewController : UINavigationBarDelegate {
    internal func navigationBar(navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        return false
    }
}
*/
