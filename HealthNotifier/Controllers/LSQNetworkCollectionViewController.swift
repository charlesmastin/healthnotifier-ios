//
//  LSQNetworkCollectionViewController.swift
//
//  Created by Charles Mastin on 11/22/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQNetworkCollectionViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    var patientId: String? = nil
    var mode: String = "inbound" // or outbound - quick business so we have have dual purpose for this here VC son
    var data: JSON? = nil //bwaaa not sure how we're gonna source this at the moment son
    
    // TODO: handle blankstates
    // TODO: handle photos
    
    @IBAction func actionAdd() -> Void {
        self.actionAddConnection()
    }
    
    func actionAddConnection() -> Void {
        NotificationCenter.default.post(
            name: LSQ.notification.show.patientNetworkSearch,
            object: self,
            userInfo: [
                "mode": self.mode
            ]
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        
        //self.registerNib(UINib(nibName: "CollectionBlankstate", bundle: nil))
        // NSBundle.mainBundle().loadNibNamed("CollectionBlankstate", owner: self, options: nil)
        
        // OH MY SON, config the stuffs
        // let emptyBackgroundView = LSQCollectionBlankstate()
        // self.tableView.backgroundView = emptyBackgroundView
        
        // wire the CTA
        
        if self.mode == "inbound" {
            self.navigationItem.title = "Shared With You"
            /*
            self.navigationItem.setRightBarButtonItem(
                UIBarButtonItem(
                    title: "Request Access",
                    style: UIBarButtonItemStyle.Plain,
                    target: self,
                    action: #selector(self.actionAddConnection)
                ),
                animated: false
            )
            */
        } else {
            self.navigationItem.title = "LifeCircle"
            /*
            self.navigationItem.setRightBarButtonItem(
                UIBarButtonItem(
                    title: "Share LifeSticker",
                    style: UIBarButtonItemStyle.Plain,
                    target: self,
                    action: #selector(self.actionAddConnection)
                ),
                animated: false
            )
            */
        }
        
        self.searchBar.isHidden = true
        
        let user = LSQUser.currentUser
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "Network View",
                "attributes": [
                    "Mode": self.mode,
                    "AccountId": user.uuid!,
                    "Provider": user.provider,
                    "PatientId": self.patientId!
                ]
            ]
        )
    }
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.network.success,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                
                // only respond to the specific object and action
                if notification.userInfo!["object"] as? String == "patientnetwork" {
                    if notification.userInfo!["action"] as? String == "index" {
                        self.handleResults(notification.userInfo!["response"]! as AnyObject)
                    } else {
                        // reload that mother trucker, try not to create an infinite loop
                        self.loadData()
                        // notify the patient has chaged, so our parent view can reload it self,
                        
                        // yea this is o so efficient
                    }
                    // network management
                    
                    // network management
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

    // load data son
    func loadData() -> Void {
        // TODO: pass in da mode of this here thingy son
        LSQAPI.sharedInstance.patientNetworkConnections(self.patientId!)
    }
    
    func handleResults(_ results: AnyObject) {
        self.data = JSON(results)
        self.tableView.reloadData()
        // re-tap da calculations son
    }
    
    // hide blankstate
    func showBlankstate() {
//        self.tableView.separatorStyle = .none
//        self.tableView.backgroundView?.hidden = false
    }
    
    func hideBlankstate() {
//        self.tableView.separatorStyle = .SingleLine
//        self.tableView.backgroundView?.hidden = true
    }
    
    // TABLE STUFFS] so much tedium son
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.data != nil {
            // ghetto rig, hide the blankstate
            hideBlankstate()
            // this class is overloaded, but, I'm way too lazy to setup a proper class / subclass
            if self.mode == "inbound" {
                if self.data!["granters_pending"].arrayValue.count > 0 {
                    return 2
                }
                return 1
            }
            if self.mode == "outbound" {
                if self.data!["auditors_pending"].arrayValue.count > 0 {
                    return 2
                }
                return 1
            }
            
        }
        // ok, trigger off the blankstate setup
        showBlankstate()
        return 0
        // return 2 if pending son
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.data != nil {
            if self.mode == "inbound" {
                // hmm, we have to check the stuffs again, ugg
                if self.data!["granters_pending"].arrayValue.count > 0 && section == 0 {
                    return self.data!["granters_pending"].arrayValue.count
                }
                return self.data!["granters"].arrayValue.count + 1
            }
            if self.mode == "outbound" {
                // hmm, we have to check the stuffs again, ugg
                if self.data!["auditors_pending"].arrayValue.count > 0 && section == 0 {
                    return self.data!["auditors_pending"].arrayValue.count
                }
                return self.data!["auditors"].arrayValue.count + 1
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // TODO: precanned data structure avoids hitting all this again and again, in terms of what the cells are exactly
        if self.data != nil {
            if self.mode == "inbound" {
                if self.data!["granters_pending"].arrayValue.count > 0 && section == 0 {
                    return "Pending Access You Requested"
                }
                return "Connections"
                // hmm, we have to check the stuffs again, ugg
            }
            if self.mode == "outbound" {
                // hmm, we have to check the stuffs again, ugg
                if self.data!["auditors_pending"].arrayValue.count > 0 && section == 0 {
                    return "Requests To Join Your LifeCircle"
                }
                return "Connections"
            }
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_default")
        var cellPatientId: String = ""
        var cellPatientPhotoUuid: String = ""
        // TODO: provider status
        
        // TODO: abstract on server????? FTW
        
        if self.mode == "inbound" {
            if self.data!["granters_pending"].arrayValue.count > 0 && indexPath.section == 0 {
                let node: JSON = self.data!["granters_pending"][indexPath.row]
                cell.textLabel?.text = node["granter_name"].string!
                cell.detailTextLabel?.text = LSQ.formatter.humanizeTimestamp(node["asked_at"].string!)
                cellPatientId = node["granter_uuid"].string!
                if let photo_uuid: String = node["granter_photo_uuid"].string {
                    cellPatientPhotoUuid = photo_uuid
                }
                // SUBTLE ABUSE OF THE UI PATTERN FOR NAV, LOL SUE ME APPLE
                // cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else {
                let collection = self.data!["granters"].arrayValue
                if collection.indices.contains(indexPath.row) {
                    let node: JSON = self.data!["granters"][indexPath.row]
                    cell.textLabel?.text = node["granter_name"].string!
                    //cell.detailTextLabel?.text = self.data!["granters"][indexPath.row]["privacy"].string!
                    cellPatientId = node["granter_uuid"].string!
                    if let photo_uuid: String = node["granter_photo_uuid"].string {
                        cellPatientPhotoUuid = photo_uuid
                    }
                    // so you can view their LifeSticker / leave their network son
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                } else {
                    // are we a cell, or the bonus add cell
                    let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "add")
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Request To View LifeSticker"
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "add"
                    return cell
                }
            }
        }
        if self.mode == "outbound" {
            if self.data!["auditors_pending"].arrayValue.count > 0 && indexPath.section == 0 {
                let node: JSON = self.data!["auditors_pending"][indexPath.row]
                cell.textLabel?.text = node["auditor_name"].string!
                cell.detailTextLabel?.text = LSQ.formatter.humanizeTimestamp(node["asked_at"].string!)
                cellPatientId = node["auditor_uuid"].string!
                if let photo_uuid: String = node["auditor_photo_uuid"].string {
                    cellPatientPhotoUuid = photo_uuid
                }
                if node["auditor_provider"].boolValue {
                    cell.detailTextLabel?.text = "\(LSQ.formatter.humanizeTimestamp(node["asked_at"].string!)) - Registered Health Care Provider"
                }
                // so you can accept the invite
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            } else {
                let collection = self.data!["auditors"].arrayValue
                if collection.indices.contains(indexPath.row) {
                    let node: JSON = self.data!["auditors"][indexPath.row]
                    cell.textLabel?.text = node["auditor_name"].string!
                    let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("privacy", attribute: nil, value: node["privacy"].string!)
                    
                    cell.detailTextLabel?.text = "Shared with privacy: \(formattedDonkey)"
                    
                    cellPatientId = node["auditor_uuid"].string!
                    if let photo_uuid: String = node["auditor_photo_uuid"].string {
                        cellPatientPhotoUuid = photo_uuid
                    }
                    // so you can alter the priv
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                } else {
                    let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "add")
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Share Your LifeSticker"
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "add"
                    return cell
                }
            }
        }
        
        let imageSize: Int = 44
        let photoUrl: String = "\(LSQAPI.sharedInstance.api_root)profiles/\(cellPatientId)/profile-photo?photo_uuid=\(cellPatientPhotoUuid)&width=\(Int(imageSize * 2))&height=\(Int(imageSize * 2))"
        cell = Tables.decorateProfilePhoto(cell, photoUrl: photoUrl)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // general cell capture
        // add item hack button son
        let cell = self.tableView.cellForRow(at: indexPath)
        // this is a generic button cell workaround son
        if cell is LSQCellAddCollectionItem {
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "add" {
                self.actionAddConnection()
                return
            }
        }
        
        if self.mode == "inbound" {
            
            if self.data!["granters_pending"].arrayValue.count > 0 && indexPath.section == 0 {
                
            } else {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.lifesquare,
                    object: self,
                    userInfo:[
                        "patientId": self.data!["granters"][indexPath.row]["granter_uuid"].string!,
                    ]
                )
            }
        }
        
        if self.mode == "outbound" {
            
            if self.data!["auditors_pending"].arrayValue.count > 0 && indexPath.section == 0 {
                // bla blablablabla we would be handling the "accept request" w/ privacy at this point
                let node = self.data!["auditors_pending"][indexPath.row]
                NotificationCenter.default.post(
                    name: LSQ.notification.action.answerConnectionRequest,
                    object: self,
                    userInfo:[
                        "granter_uuid": node["granter_uuid"].string!,
                        "auditor_uuid": node["auditor_uuid"].string!,
                        "auditor_name": node["auditor_name"].string!,
                        "is_provider": node["auditor_provider"].boolValue
                    ]
                )
            } else {
                let node = self.data!["auditors"][indexPath.row]
                NotificationCenter.default.post(
                    name: LSQ.notification.action.manageConnection,
                    object: self,
                    userInfo:[
                        "granter_uuid": node["granter_uuid"].string!,
                        "auditor_uuid": node["auditor_uuid"].string!,
                        "auditor_name": node["auditor_name"].string!,
                        "is_provider": node["auditor_provider"].boolValue
                    ]
                )
                
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // only for auditors aka inbound
        if self.mode == "inbound" {
            if self.data!["granters_pending"].arrayValue.count > 0 && indexPath.section == 0 {
                return false
            }
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //let key: String = self.dataConfig[indexPath.section]["key"]!
        //let collectionName: String = self.dataConfig[indexPath.section]["collectionName"]!
        if editingStyle == .delete {
            // confirm that shizniz
            let row = self.data!["granters"][indexPath.row]
            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                preferredStyle = UIAlertControllerStyle.actionSheet
            }
            let alert: UIAlertController = UIAlertController(
                title: "Delete Connection?",
                message: "",
                preferredStyle: preferredStyle)
            
            let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
                LSQAPI.sharedInstance.patientNetworkLeave(
                    self.patientId!,
                    granter_id: row["granter_uuid"].string!,
                    auditor_id: row["auditor_uuid"].string!
                )
            })
            alert.addAction(deleteAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                // nothing here
                // TODO: reverse da swipe animation son
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
