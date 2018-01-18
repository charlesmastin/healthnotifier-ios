//
//  LSQCarePlanIndexViewController.swift
//
//  Created by Charles Mastin on 9/30/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity
// is this necessary, probably not

class LSQCarePlanIndexViewController: UITableViewController {
    var patientId: String? = nil
    var plans: Array<JSON> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(
            name: LSQ.notification.hacks.resetCarePlanHistory,
            object: self,
            userInfo: nil
        )
        
    }
    
    
    
    // basic table, cell is Title and "description"
    // click through disclosure to landing view for Plan
    // but for now, route it action wise to the first question group, which we will have on the data
    // meh, should there be a patientId attribute in this class? meh
    func loadData() {
        // call it up in the LSQAPI2 - but it's async, so how to deal with it in a classy way, solve once
        // potentially cache this? but meh for now as the notion of offline care plans is nil
        EZLoadingActivity.show("", disableUI: false)
        LSQAPI.sharedInstance.loadCareplans(
            self.patientId!,
            success: { response in
                EZLoadingActivity.hide()
                let data = JSON(response)
                self.plans = data.arrayValue
                self.tableView.reloadData()
            },
            failure: { response in
                EZLoadingActivity.hide()
            }
        )
    }
    
    // table delegate methods - Get your purdue boilermakers on
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose A Condition"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.plans.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cp_special")
        // only if we have an initial
        cell.textLabel?.text = self.plans[indexPath.row]["name"].string!
        
        if self.plans[indexPath.row]["initial_question_group_uuid"] != JSON.null {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // but for now, hit up dat first question group son!
        
        // only if we have an initial blablal
        if self.plans[indexPath.row]["initial_question_group_uuid"] != JSON.null {
            NotificationCenter.default.post(
                name: LSQ.notification.show.careplanQuestionGroup,
                object: self,
                userInfo: [
                    "question_group_uuid": (self.plans[indexPath.row]["initial_question_group_uuid"].string)!
                ]
            )
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*
        if indexPath.section == 2 {
            return 66.0
        }
        */
        return 44.0
    }
}
