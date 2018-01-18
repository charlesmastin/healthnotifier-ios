//
//  LSQCarePlanRecommendationViewController.swift
//
//  Created by Charles Mastin on 9/30/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQCarePlanRecommendationViewController: UITableViewController {

    var patientId: String? = nil
    var recommendationUuid: String? = nil
    var data: JSON? = nil //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    // basic table, cell is Title and "description"
    // click through disclosure to landing view for Plan
    // but for now, route it action wise to the first question group, which we will have on the data
    func loadData() {
        // call it up in the LSQAPI2 - but it's async, so how to deal with it in a classy way, solve once
        EZLoadingActivity.show("", disableUI: false)
        LSQAPI.sharedInstance.loadCareplanRecommendation(
            self.patientId!,
            recommendation_uuid: self.recommendationUuid!,
            success: { response in
                EZLoadingActivity.hide()
                self.data = JSON(response)
                self.tableView.reloadData()
                
                let user = LSQUser.currentUser
                                
                NotificationCenter.default.post(
                    name: LSQ.notification.analytics.event,
                    object: nil,
                    userInfo: [
                        "event": "Care Plan Recommendation View",
                        "attributes": [
                            "AccountId": user.uuid!,
                            "Provider": user.provider,
                            "PatientId": self.patientId!,
                            "RecommendationId": self.recommendationUuid!,
                            "CarePlanId": (response["uuid"] as? String)!
                        ]
                    ]
                )
                
            },
            failure: { response in
                // pass
                EZLoadingActivity.hide()
                
                let alert: UIAlertController = UIAlertController(
                    title: "Server Error",
                    message: "Unable to load recommendation.",
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    // TODO: focus first problem child?
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        )
        
    }
    
    // table delegate methods - Get your purdue boilermakers on
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.data != nil {
            return self.data!["components"].arrayValue.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.data != nil {
            return self.data!["components"][section]["category"].string!
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cp_special")
        cell.textLabel?.numberOfLines = 0
        let inputText: String = self.data!["components"][indexPath.section]["data"].string!
        cell.textLabel?.text = inputText
        cell.textLabel?.sizeToFit()
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
