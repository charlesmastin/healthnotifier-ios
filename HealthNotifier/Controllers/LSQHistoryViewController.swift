//
//  LSQHistoryViewController.swift
//
//  Created by Charles Mastin on 3/8/16.
//

import Foundation
import UIKit

class LSQHistoryViewController : UITableViewController {
    
    // debatable if we need to store a copy here, seems stupid, just use the underlying mechanism
    // var patients: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    // constructor hacks to run setup
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // be smarter and only reload non visible thing??
        self.reloadData()
        
        let user: LSQUser = LSQUser.currentUser
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "History View",
                "attributes": [
                    "AccountId": user.uuid!,
                    "Provider": user.provider,
                ]
            ]
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        self.title = "History"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(LSQHistoryViewController.handleHistoryUpdate(_:)), name: LSQ.notification.hacks.patientHistoryUpdate, object: nil)
    }
    
    func handleHistoryUpdate(_ notification: Notification?) {
        // reload all the data just because we like to be inefficient
        self.reloadData()
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    // TABLE DELEGATE STUFFS, OMG
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LSQHistoryViewControllerCellIdentifier", for: indexPath) as! LSQHistoryTableViewCell
        
        // TODO: improve referene strength
        let patient = LSQScanHistory.sharedInstance.patients[indexPath.row]
        cell.titleTextLabel!.text = patient["Name"] as? String
        cell.addressTextLabel!.text = patient["Address"] as? String
        cell.locationTextLabel.text = "LifeSticker location: " + (patient["LifesquareLocation"] as? String)!
        cell.timestampTextLabel.text = "Scanned at: " + (LSQ.formatter.standardTimestamp((patient["ScanTime"] as? Date)!))
        // cell.profilePhoto!.downloadImage(patient["ProfilePhoto"].string!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LSQScanHistory.sharedInstance.patients.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // by some patientid fragile reference
            //let patientId: String = LSQScanHistory.sharedInstance.patients[indexPath.row]["PatientId"]
            //LSQScanHistory.sharedInstance.removePatientById(patientId)
            LSQScanHistory.sharedInstance.removePatientByIndex(indexPath.row)
            // we can restore the fancy deleting when we sort out the event flow at another point in time
            // self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: improve this reference strength, w/e
        let patient = LSQScanHistory.sharedInstance.patients[indexPath.row]
        
        let user: LSQUser = LSQUser.currentUser
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "History View Patient",
                "attributes": [
                    "AccountId": user.uuid!,
                    "Provider": user.provider,
                    "PatientId": patient["PatientId"] as! String
                ]
            ]
        )
        
        NotificationCenter.default.post(
            name: LSQ.notification.show.lifesquare,
            object: self,
            userInfo: [
                "patientId": patient["PatientId"] as! String
            ]
        )
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if LSQScanHistory.sharedInstance.patients.count > 0 {
            return "Recently Scanned LifeStickers (\(LSQScanHistory.sharedInstance.patients.count))"
        } else {
            return "No Recently Scanned LifeStickers"
        }
    }
}
