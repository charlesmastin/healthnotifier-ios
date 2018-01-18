//
//  LSQRoutesCareplans.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit

class LSQRoutesCareplans : LSQRouter {
    
    internal var questionGroupsHistory: [String] = []
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.careplanIndex,
                object: nil,
                queue: OperationQueue.main,
                using: self.showCareplanIndexScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.careplanQuestionGroup,
                object: nil,
                queue: OperationQueue.main,
                using: self.showCareplanQuestionGroupScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.careplanRecommendation,
                object: nil,
                queue: OperationQueue.main,
                using: self.showCareplanRecommendationScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.resetCarePlanHistory,
                object: nil,
                queue: OperationQueue.main,
                using: self.resetCarePlanHistory
            )
        )
    }
    
    func showCareplanIndexScreen(notification: Notification) {
        self.resetCarePlanHistory()
        // needs loading of data
        let sb:UIStoryboard = UIStoryboard(name:"Careplan", bundle:nil)
        let vc:LSQCarePlanIndexViewController = sb.instantiateViewController(withIdentifier: "CarePlanIndexViewController") as! LSQCarePlanIndexViewController
        vc.patientId = LSQPatientManager.sharedInstance.uuid!
        
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            vc.loadData()
        }
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "Care Plans View",
                "attributes": [
                    "AccountId": LSQUser.currentUser.uuid!,
                    "Provider": LSQUser.currentUser.provider,
                    "PatientId": LSQPatientManager.sharedInstance.uuid!
                ]
            ]
        )
    }
    
    func showCareplanPlanScreen(notification: Notification) {
        // push view controller from index
        self.resetCarePlanHistory()
    }
    
    func resetCarePlanHistory(notification: Notification? = nil) {
        self.questionGroupsHistory = []
    }
    
    func showCareplanQuestionGroupScreen(notification: Notification) {
        // needs loading of data
        // push view controller from previous group / plan screen
        let sb:UIStoryboard = UIStoryboard(name:"Careplan", bundle:nil)
        let vc:LSQCarePlanQuestionGroupViewController = sb.instantiateViewController(withIdentifier: "CarePlanQuestionGroupViewController") as! LSQCarePlanQuestionGroupViewController
        vc.patientId = LSQPatientManager.sharedInstance.uuid!
        let uuid: String = (notification.userInfo!["question_group_uuid"]! as? String)!
        vc.questionGroupUuid = uuid
        
        // loop our history
        // if we find a match, splice off additional items
        // https://developer.apple.com/reference/swift/arrayslice
        // because apple sucks and it's hard to read documentation
        var found: Bool = false
        for (index, obj) in self.questionGroupsHistory.enumerated() {
            if obj == uuid {
                // F this
                var tA:[String] = []
                // unsure how to do this in swift, hate my life, DIAF
                for (index2, obj2) in self.questionGroupsHistory.enumerated() {
                    if index2 <= index {
                        tA.append(obj2)
                    }
                }
                self.questionGroupsHistory = tA
                found = true
                break
            }
        }
        if !found {
            self.questionGroupsHistory.append(uuid)
        }
        vc.index = self.questionGroupsHistory.count
        
        let pvc: UIViewController = notification.object as! UIViewController
        
        
        
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            vc.loadData()
        }
        
    }
    
    func showCareplanRecommendationScreen(notification: Notification) {
        // needs loading of data
        // push (but clear stack) from previous group
        // needs loading of data
        let sb:UIStoryboard = UIStoryboard(name:"Careplan", bundle:nil)
        let vc:LSQCarePlanRecommendationViewController = sb.instantiateViewController(withIdentifier: "CarePlanRecommendationViewController") as! LSQCarePlanRecommendationViewController
        vc.patientId = LSQPatientManager.sharedInstance.uuid!
        vc.recommendationUuid = notification.userInfo!["recommendation_uuid"]! as? String
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            vc.loadData()
        }
    }
}
