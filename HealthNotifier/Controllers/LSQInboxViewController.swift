//
//  LSQInbox.swift
//
//  Created by Charles Mastin on 12/15/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQInboxViewController : UITableViewController {
    var rawData: JSON = JSON.null
    var data: [[String: AnyObject]] = []
    // group by peep
    //
    //
    // don't show headers if the account only has 1 patient, but w/e we don't have access to that at the moment
    override func viewDidLoad() {
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addObservers()
        self.loadData()
        
        // TODO: perhaps we check permissions for badges specifically on viewing, just to be 100% sure
        // LSQBadgeManager.sharedInstance.permissionsCheck()
        
    }
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.badgeCountChange,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.loadData()
            }
        )
    }
    
    func removeObservers() {
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    deinit {
        self.removeObservers()
    }
    
    func loadData(){
        // straight sketchy beans son
        self.rawData = LSQBadgeManager.sharedInstance.data
        // transform the data as needed son - pain and sufferrings
        self.data = []
        // begin sketchy times for life son
        for inviteJson in self.rawData["invites"].arrayValue {
            // find our local "index"
            // do we have a key, if not, create one
            var foundIndex: Int = -1
            for (index, obj) in self.data.enumerated() {
                if obj["patient_uuid"] as? String == inviteJson["granter_uuid"].string {
                    foundIndex = index
                    break
                }
            }
            if foundIndex != -1 {
                if var inviteA:[AnyObject] = self.data[foundIndex]["invites"] as? [AnyObject] {
                    inviteA.append(inviteJson.object as AnyObject)
                    self.data[foundIndex]["invites"] = inviteA as AnyObject?
                }
            } else {
                self.data.append([
                    "patient_uuid": inviteJson["granter_uuid"].string! as AnyObject,
                    "patient_name": inviteJson["granter_name"].string! as AnyObject,
                    "invites": [inviteJson.object] as AnyObject
                ])
            }
        }
        
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // this will be broken down by person son
        return self.data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.data[section]["invites"] as! [AnyObject]).count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Requests For \((self.data[section]["patient_name"] as? String)!)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_inbound")
        let row = JSON((self.data[indexPath.section]["invites"] as! [AnyObject])[indexPath.row])
        cell.textLabel?.text = row["auditor_name"].string!
        cell.detailTextLabel?.text = LSQ.formatter.humanizeTimestamp(row["asked_at"].string!)
        
        let cellPatientId: String = row["auditor_uuid"].string!
        var cellPatientPhotoUuid: String = ""
        if let photo_uuid:String = row["auditor_photo_uuid"].string {
            cellPatientPhotoUuid = photo_uuid
        }
        
        let imageSize: Int = 88
        let photoUrl: String = "\(LSQAPI.sharedInstance.api_root)profiles/\(cellPatientId)/profile-photo?photo_uuid=\(cellPatientPhotoUuid)&width=\(Int(imageSize * 2))&height=\(Int(imageSize * 2))"
        cell = Tables.decorateProfilePhoto(cell, photoUrl: photoUrl, imageSize: imageSize)
        
        if row["auditor_provider"].boolValue {
            cell.detailTextLabel?.text = "\(LSQ.formatter.humanizeTimestamp(row["asked_at"].string!)) - Registered Health Care Provider"
        }
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let row = JSON((self.data[indexPath.section]["invites"] as! [AnyObject])[indexPath.row])
        NotificationCenter.default.post(
            name: LSQ.notification.action.answerConnectionRequest,
            object: self,
            userInfo:[
                "granter_uuid": row["granter_uuid"].string!,
                "auditor_uuid": row["auditor_uuid"].string!,
                "auditor_name": row["auditor_name"].string!,
                "is_provider": row["auditor_provider"].boolValue
            ]
        )
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0//+22.0
    }
}
