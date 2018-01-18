//
//  LSQBadgeManager.swift
//
//  Created by Charles Mastin on 12/14/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQBadgeManager: NSObject {
    
    static let sharedInstance = LSQBadgeManager()
    
    var count: Int = 0
    var data: JSON = JSON.null
    
    /*
    override func init(){
        super.init()
        self.addObservers()
    }
    */
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.network.success,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                print("HOLY TOLEDO JOE ARE WE STACKING!!! OBSERVERS IN SINGLETONS CAN OF WORMS")
                if notification.userInfo!["object"] as? String == "patientnetwork" {
                    if let action = notification.userInfo!["action"] as? String {
                        if action == "accept" || action == "decline" {
                            self.sync()
                        }
                        // FIXME: meh meh
                        // generic town analytics for da network son
                        /*
                        if action != "index" && action != "search" {
                            NotificationCenter.default.post(
                                name: LSQ.notification.analytics.event,
                                object: nil,
                                userInfo: [
                                    "event": "Network Manage",
                                    "attributes": [
                                        "Action": action,
                                        "AccountId": LSQUser.currentUser.uuid!,
                                        "Provider": LSQUser.currentUser.provider!,
                                        "PatientId": (notification!.userInfo!["patient_id"] as? String)!
                                    ]
                                ]
                            )
                        }
                         */
                        
                    }
                }
            }
        )
    }
    
    /*
    func deinit(){
        self.removeObservers()
    }
    */
    
    func removeObservers(){
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    func permissionsCheck() {
        let types: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
    
    func sync() {
        // peep with da remote
        // update local
        LSQAPI.sharedInstance.getAccountNotifications(
            { response in
                // lololoololol
                self.data = JSON(response)
                if self.data["invites"].exists() {
                    self.count = self.data["invites"].arrayValue.count
                }
                // TODO: be on the lookup for future versions, son
                self.persist()
            },
            failure: { response in
                self.reset()
            }
        )
    }
    
    // convenience
    func increment() {
        self.count += 1
        self.persist()
    }
    
    func decrement() {
        self.count -= 1
        self.persist()
    }
    
    func reset() {
        self.count = 0
        self.persist()
    }
    
    internal func persist() {
        if self.count > -1 {
            UIApplication.shared.applicationIconBadgeNumber = self.count
        }
        NotificationCenter.default.post(
            name: LSQ.notification.hacks.badgeCountChange,
            object: self,
            userInfo: [
                "count": self.count
            ]
        )
    }
    
}
