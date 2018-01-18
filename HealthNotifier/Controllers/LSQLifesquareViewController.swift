//
//  LSQPatientViewController2.swift
//
//  Created by Charles Mastin on 8/3/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQLifesquareViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var personalJW: UIView?
    @IBOutlet weak var medicalJW: UIView?
    @IBOutlet weak var contactsJW: UIView?
    @IBOutlet weak var segmentedControlBackgroundView: UIView?
    
    var editMode: Bool = false
    
    var data: JSON = JSON.null
    
    var vcPersonal: LSQPatientPersonalViewController? {
        return childViewControllers.flatMap({ $0 as? LSQPatientPersonalViewController }).first
    }
    var vcMedical: LSQPatientMedicalViewController? {
        return childViewControllers.flatMap({ $0 as? LSQPatientMedicalViewController }).first
    }
    var vcContacts: LSQPatientContactsViewController? {
        return childViewControllers.flatMap({ $0 as? LSQPatientContactsViewController }).first
    }
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObservers()
        self.segmentedControlBackgroundView?.backgroundColor = LSQ.appearance.color.newBlue
        self.segmentedControl.tintColor = LSQ.appearance.color.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObservers()
    }
    
    @IBAction func actionDone() -> Void {
        self.close()
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    // ok these are custom getter setters, what's the beef with that son?
    // http://www.swift-studies.com/blog/2014/6/12/observing-properties-in-swift
    // yup not enough bandwidth for this right now
    // TODO: sort out a better way
    func handleEditingChange() -> Void {
        self.renderSubviews() // this will effectively toggle out da stuffs
        
        self.vcMedical!.editMode = self.editMode
        self.vcMedical!.handleEditingChange()
        self.vcContacts!.editMode = self.editMode
        self.vcContacts!.handleEditingChange()
        
        if self.editMode {
            // fade in a new navigation title area view?
            // or just change what we have, or just cross fade items that live in the same container, yea son
            
            // change our title here? Editing FirstName?
            // TODO: handle nil since we won't have this on the first go
            self.title = "Editing \(self.data["profile"]["first_name"].string!)"
            // change out navigation back to Cancel
            //self.navigationItem.leftBarButtonItem?.enabled = false
            self.navigationItem.setHidesBackButton(true, animated: true)
            self.navigationItem.setLeftBarButton(
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.handleCancelAction(_:))), animated: true
            )
            
            // change out actions area to Save
            // self.navigationItem.rightBarButtonItem?.enabled = false
//            self.navigationItem.setRightBarButtonItem(
//                UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(self.handleSaveAction(_:))), animated: true
//            )
        } else {
            self.navigationItem.setHidesBackButton(false, animated: true)
            self.navigationItem.leftBarButtonItem = nil
            // title
            // TODO: handle nil patient data
            
            // we can't say your, unless there is only one profile in the account, son
            
            self.title = "\(self.data["profile"]["first_name"].string!)’s LifeSticker"// \(self.data["profile"]["last_name"].string!)
            // actions
            self.navigationItem.setRightBarButton(
                UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.handleViewActions(_:))), animated: true
            )
            
        }
    }
    
    func beginEditing() -> Void {
        self.editMode = true
        self.handleEditingChange()
    }
    
    func handleCancelAction(_ notification: Notification) -> Void {
        self.editMode = false
        self.handleEditingChange()
    }
    
    func completeEditing() -> Void {
        // placeholder, we'll likely pass the specific transport stuff somewhere else, but w/e
        // probably call self.cancelEditing, but then
        // show some kinds of affirmation? or something or not
        // blablabla
    }
    
    func triggerActions() -> Void {
        // nil patient data, blablabla
        NotificationCenter.default.post(
            name: LSQ.notification.action.patientActions,
            object: self,
            userInfo: ["patientName": "\(self.data["profile"]["first_name"].string!) \(self.data["profile"]["last_name"].string!)"]
        )
    }
    
    func handleViewActions(_ notification: Notification) -> Void {
        self.triggerActions()
    }
    
    // default IB connection w/e son, we should do this only with code as this is confusing
    @IBAction func viewActions() {
        self.triggerActions()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.vcPersonal!.tableView.register(UINib(nibName: "CellProfilePhoto", bundle: nil), forCellReuseIdentifier: "CellProfilePhoto")
        
        self.vcMedical!.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.vcMedical!.tableView.register(LSQCellPrivacyRestrictedItem.self, forCellReuseIdentifier: "CellPrivacyRestrictedItem")
        self.vcMedical!.tableView.register(LSQCellEmptyCollection.self, forCellReuseIdentifier: "CellEmptyCollection")
        
        self.vcContacts!.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.vcContacts!.tableView.register(LSQCellPrivacyRestrictedItem.self, forCellReuseIdentifier: "CellPrivacyRestrictedItem")
        self.vcContacts!.tableView.register(LSQCellEmptyCollection.self, forCellReuseIdentifier: "CellEmptyCollection")
        
        self.setup()
    }
    
    func setup() -> Void {
        self.vcPersonal!.tableDataInit(self.data)
        self.vcMedical!.data = self.data
        self.vcMedical!.configureTable()
        self.vcContacts!.data = self.data
        self.vcContacts!.configureTable()
        // TODO: get rid of top level patient internally (or at the API, since it's a request for one)
        // Woot, quite possibly the worlds most hideous access syntax ever
        // TODO: handle nil patient data
        self.title = "\(self.data["profile"]["first_name"].string!)’s LifeSticker"
        // self.title = "\(self.data["profile"]["first_name"].string!) \(self.data["profile"]["last_name"].string!)"
        // data segments to the respective view controllers, blablabla
        self.personalJW!.isHidden = false
        self.medicalJW!.isHidden = true
        self.contactsJW!.isHidden = true
        
        // hide the Cancel action
        if self.data["meta"]["owner"].boolValue == false {
            self.navigationItem.rightBarButtonItems = nil
        }
        
    }
    
    @IBAction func segmentedControlAction() -> Void {
        // TODO: do we intercept and clamp it down if we're currently in editing mode?????????
        // WHY NOT
        self.renderSubviews()
    }
    
    func renderSubviews() -> Void {
        let int : Int = self.segmentedControl!.selectedSegmentIndex as Int
        if(int == 0){
            if self.editMode {
                self.personalJW!.isHidden = true
            } else {
                self.personalJW!.isHidden = false
            }
            self.medicalJW!.isHidden = true
            self.contactsJW!.isHidden = true
        }
        if(int == 1){
            self.personalJW!.isHidden = true
            self.medicalJW!.isHidden = false
            self.contactsJW!.isHidden = true
        }
        if(int == 2){
            self.personalJW!.isHidden = true
            self.medicalJW!.isHidden = true
            self.contactsJW!.isHidden = false
        }
    }
    
}
