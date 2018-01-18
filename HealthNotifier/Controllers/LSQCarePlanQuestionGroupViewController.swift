//
//  LSQCarePlanQuestionGroupViewController.swift
//
//  Created by Charles Mastin on 9/30/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQCarePlanQuestionGroupViewController: UITableViewController {
    
    @IBAction func save() {
        LSQAPI.sharedInstance.sendCareplanResponses(
            self.patientId!,
            questiongroup_uuid: self.data!["uuid"].string!,
            answers: self.answers,
            success: { response in
                
                let user = LSQUser.currentUser
                if let care_plan_uuid:String = response["care_plan_uuid"] as? String {
                    NotificationCenter.default.post(
                        name: LSQ.notification.analytics.event,
                        object: nil,
                        userInfo: [
                            "event": "Care Plan Response",
                            "attributes": [
                                "AccountId": user.uuid!,
                                "Provider": user.provider,
                                "PatientId": self.patientId!,
                                "QuestionGroupId": self.data!["uuid"].string!, // this meh, maybe not necessary
                                "CarePlanId": care_plan_uuid
                                // TODO: timer for time on screen
                            ]
                        ]
                    )
                }
                
                if let val = response["question_group_uuid"] as? String {
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.careplanQuestionGroup,
                        object: self,
                        userInfo: [
                            "question_group_uuid": val
                        ]
                    )
                }
                
                if let val = response["recommendation_uuid"] as? String {
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.careplanRecommendation,
                        object: self,
                        userInfo: [
                            "recommendation_uuid": val
                        ]
                    )
                }
            },
            failure: { response in
                var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                    preferredStyle = UIAlertControllerStyle.actionSheet
                }
                let alert: UIAlertController = UIAlertController(
                    title: "Error saving response. If error persists, please contact support@domain.com",
                    message: "",
                    preferredStyle: preferredStyle)
                
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    // nothing here
                })
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        )
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem?
    
    // delegate for all the UI controllers
    // ok, we could render this as a Grouped Table View
    // each group is a question
    // cells are visible options unless more than 5 choices, in which it's a table drill selector
    // each component is a group
    // generic markdown parsing to some notion of an embedded webview, perhaps?? perhaps?
    // actions and such
    var index:Int = 1
    var patientId: String? = nil
    var questionGroupUuid: String? = nil
    // why oh why do we need this lolzones
    var data: JSON? = nil
    var answers: [[String: AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Question \(self.index)"
    }
    
    // basic table, cell is Title and "description"
    // click through disclosure to landing view for Plan
    // but for now, route it action wise to the first question group, which we will have on the data
    func loadData() {
        // call it up in the LSQAPI2 - but it's async, so how to deal with it in a classy way, solve once
        // potentially cache this?
        EZLoadingActivity.show("", disableUI: false)
        LSQAPI.sharedInstance.loadCareplanQuestionGroup(
            self.patientId!,
            questiongroup_uuid: self.questionGroupUuid!,
            success: { response in
                self.data = JSON(response)
                // stub dem answers son
                self.answers = []
                for obj in self.data!["questions"].arrayValue {
                    self.answers.append(["question_uuid": obj["uuid"].string! as AnyObject, "choice_uuid":"" as AnyObject])
                }
                
                self.tableView.reloadData()
                EZLoadingActivity.hide()
                
                
                let user = LSQUser.currentUser
                
                NotificationCenter.default.post(
                    name: LSQ.notification.analytics.event,
                    object: nil,
                    userInfo: [
                        "event": "Care Plan Question Group View",
                        "attributes": [
                            "AccountId": user.uuid!,
                            "Provider": user.provider,
                            "PatientId": self.patientId!,
                            "QuestionGroupId": self.questionGroupUuid!,
                            "CarePlanId": (response["care_plan_uuid"] as? String)!
                        ]
                    ]
                )
                
            },
            failure: { response in
                // EZLoadingActivity.hide()
                let alert: UIAlertController = UIAlertController(
                    title: "Server Error",
                    message: "Unable to load questions.",
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    // TODO: go back
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        )
        
    }
    
    func processAnswer(_ indexPath: IndexPath) {
        // record in answers "model"
        self.answers[indexPath.section]["choice_uuid"] = self.data!["questions"][indexPath.section]["choices"][indexPath.row]["uuid"].string! as AnyObject
        // set visual state in question choices - aka section of table
        // kludgy master supreme necromancer edition
        
        for (index, obj) in self.data!["questions"][indexPath.section]["choices"].arrayValue.enumerated() {
            let cell = self.tableView.cellForRow(at: IndexPath(row:index, section:indexPath.section))
            if self.answers[indexPath.section]["choice_uuid"] as! String == obj["uuid"].string! {
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        
        // check validation and "active" state of submit button
        var answeredCount: Int = 0
        for obj in self.answers {
            if obj["choice_uuid"] as? String != "" {
                answeredCount += 1
            }
        }
        if answeredCount == self.answers.count {
            self.saveButton?.isEnabled = true
        } else {
            self.saveButton?.isEnabled = false
        }
    }
    
    // table delegate methods - Get your purdue boilermakers on
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.data != nil {
            return self.data!["questions"].arrayValue.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.data != nil {
            return self.data!["questions"][section]["name"].string!
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.data != nil {
            return self.data!["questions"][section]["choices"].arrayValue.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cp_special")
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = self.data!["questions"][indexPath.section]["choices"][indexPath.row]["name"].string!
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // send to the question processor method son
        self.processAnswer(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
