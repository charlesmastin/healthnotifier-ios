//
//  LSQNetworkSearchResultsViewController.swift
//
//  Created by Charles Mastin on 11/22/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQNetworkSearchResultsViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    var patientId: String? = nil
    var mode: String = "inbound" // or outbound - quick business so we have have dual purpose for this here VC son
    var results: Array<JSON> = [] //bwaaa not sure how we're gonna source this at the moment son
    var handle: AnyObject? = nil
    
    var observationQueue: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        // self.tableView = UITableView(frame: self.tableView.frame, style: .Grouped)
        // self.title = self.autocompleteId.capitalizedString
        // self.searchBar.placeholder = "Search by name"
        // set the focus to the searchBar son
        self.searchBar.delegate = self // why do we need this???
        self.searchBar.becomeFirstResponder()
    }
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.network.success,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if notification.userInfo!["object"] as? String == "patientnetwork" {
                    if notification.userInfo!["action"] as? String == "search" {
                        self.handleResults(notification.userInfo!["response"]! as AnyObject)
                        
                        let user = LSQUser.currentUser
                        
                        NotificationCenter.default.post(
                            name: LSQ.notification.analytics.event,
                            object: nil,
                            userInfo: [
                                "event": "Network Search",
                                "attributes": [
                                    "Mode": self.mode,
                                    "AccountId": user.uuid!,
                                    "Provider": user.provider,
                                    "PatientId": self.patientId!
                                ]
                            ]
                        )
                        
                    }
                    if notification.userInfo!["action"] as? String == "add" {
                        //self.handleResults(notification.userInfo!["response"]!)
                    }
                    if notification.userInfo!["action"] as? String == "request-access" {
                        //self.handleResults(notification.userInfo!["response"]!)
                    }
                }
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.network.error,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if notification.userInfo!["object"] as? String == "patientnetwork" {
                    if notification.userInfo!["action"] as? String == "search" {
                        // self.handleResults(notification.userInfo!["response"]!)
                    }
                    if notification.userInfo!["action"] as? String == "add" {
                        //self.handleResults(notification.userInfo!["response"]!)
                    }
                    if notification.userInfo!["action"] as? String == "request-access" {
                        //self.handleResults(notification.userInfo!["response"]!)
                    }
                }
            }
        )
        
        // NETWORK invites and grants and such SON, for now, we keep it local to keep state simpler,, mmmmmmmmmkkay
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.requestConnection,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.actionRequestConnection(notification)
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.grantConnection,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.actionGrantAccess(notification)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: performance test this
        /*
        if self.handle != nil {
            self.handle?.invalidate()
            self.handle = nil
        }
        self.handle = setTimeout(0.35, block: { () -> Void in
            self.fetchResults(searchText)
        })
        */
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.fetchResults(searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // TODO: fix dis
        //print("hellllllo")
        self.results = []
        self.tableView.reloadData()
    }
    
    func fetchResults(_ query: String) -> Void {
        // for inbound
        var group: String = "granters"
        if self.mode == "outbound" {
            group = "auditors"
        }
        LSQAPI.sharedInstance.patientNetworkSearch(self.patientId!, keywords: query, group: group)
    }
    
    func handleResults(_ results: AnyObject) -> Void {
        // TODO: this data coming from the API is WAY WAY WAY WAY WAY WAY too specific to the query
        var r = JSON(results)
        if r["Patients"].exists() {
            self.results = r["Patients"].arrayValue
        } else {
            self.results = []
        }
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    // cell for row son
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let node: JSON = self.results[indexPath.row]
        
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_default")
        cell.textLabel?.text = node["Name"].string!
        
        let cellPatientId: String = node["PatientUuid"].string!
        var cellPatientPhotoUuid: String = ""
        if let photo_uuid: String = node["PatientPhotoUuid"].string {
            cellPatientPhotoUuid = photo_uuid
        }
        
        let imageSize: Int = 44
        let photoUrl: String = "\(LSQAPI.sharedInstance.api_root)profiles/\(cellPatientId)/profile-photo?photo_uuid=\(cellPatientPhotoUuid)&width=\(Int(imageSize * 2))&height=\(Int(imageSize * 2))"
        cell = Tables.decorateProfilePhoto(cell, photoUrl: photoUrl)
        
        
        if node["IsProvider"].boolValue {
            cell.detailTextLabel?.text = "Registered health care provider"
        }
        
        // pending SON
        if self.mode == "inbound" {
            if node["IsPendingGranter"].boolValue {
                cell.detailTextLabel?.text = "Access requested, awaiting response…"
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
        }
        
        if self.mode == "outbound" {
            // there is no pending out
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // peep dat cell son
        
        if self.mode == "inbound" {
            // are we not a pending invite, this is solvable by disabling select state on this cell, TBD with high level fix
            // beezy
            if self.results[indexPath.row]["IsPendingGranter"].boolValue {
                
            } else {
                // send that through the msg bus because we might change the flow later to have a UI view, mmkay
                // on complete, what's the success state, lol yuuggins
                NotificationCenter.default.post(
                    name: LSQ.notification.action.requestConnection,
                    object: self,
                    userInfo:[
                        "auditor_uuid": self.patientId!,
                        "granter_uuid": self.results[indexPath.row]["PatientUuid"].string!,
                    ]
                )
            }
        }
        
        if self.mode == "outbound" {
            // because this is an action tied to an object only displayed in this here table cell,
            // let's keep the logic internal to this class, and not go through the mediator, because it's just not necessary
            
            NotificationCenter.default.post(
                name: LSQ.notification.action.grantConnection,
                object: self,
                userInfo:[
                    "granter_uuid": self.patientId!,
                    "auditor_uuid": self.results[indexPath.row]["PatientUuid"].string!,
                ]
            )
        }
    }
    
    func actionRequestConnection(_ notification: Notification?) {
        // this is quick n dirty one level, no confirmation
        let vc: UIViewController = notification!.object as! UIViewController
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        let alert: UIAlertController = UIAlertController(
            title: "Request Access",
            message: nil,
            preferredStyle: preferredStyle)
        
        let requestAction: UIAlertAction = UIAlertAction(title: "Please request access", style: UIAlertActionStyle.default, handler: { action in
            LSQAPI.sharedInstance.patientNetworkRequestAccess(
                (notification!.userInfo!["auditor_uuid"] as? String)!,
                granter_id: (notification!.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification!.userInfo!["auditor_uuid"] as? String)!
            )
        })
        alert.addAction(requestAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            // nothing here
        })
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    func actionGrantAccess(_ notification: Notification?) {
        // this is quick n dirty one level, no confirmation
        let vc: UIViewController = notification!.object as! UIViewController
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        let alert: UIAlertController = UIAlertController(
            title: "Share Your LifeSticker",
            message: "Grant with privacy level",
            preferredStyle: preferredStyle)
        
        let publicAction: UIAlertAction = UIAlertAction(title: "HealthNotifier Network", style: UIAlertActionStyle.default, handler: { action in
            LSQAPI.sharedInstance.patientNetworkAdd(
                (notification!.userInfo!["granter_uuid"] as? String)!,
                granter_id: (notification!.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification!.userInfo!["auditor_uuid"] as? String)!,
                privacy: "public"
            )
        })
        alert.addAction(publicAction)
        
        let providerAction: UIAlertAction = UIAlertAction(title: "Authorized Viewers", style: UIAlertActionStyle.default, handler: { action in
            LSQAPI.sharedInstance.patientNetworkAdd(
                (notification!.userInfo!["granter_uuid"] as? String)!,
                granter_id: (notification!.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification!.userInfo!["auditor_uuid"] as? String)!,
                privacy: "provider"
            )
        })
        alert.addAction(providerAction)
        
        let privateAction: UIAlertAction = UIAlertAction(title: "Private", style: UIAlertActionStyle.destructive, handler: { action in
            // TODO: double secret, where is the confirmation opt-in on a potentially dangerous op
            LSQAPI.sharedInstance.patientNetworkAdd(
                (notification!.userInfo!["granter_uuid"] as? String)!,
                granter_id: (notification!.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification!.userInfo!["auditor_uuid"] as? String)!,
                privacy: "private"
            )
        })
        alert.addAction(privateAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            // nothing here
        })
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
    }
}
