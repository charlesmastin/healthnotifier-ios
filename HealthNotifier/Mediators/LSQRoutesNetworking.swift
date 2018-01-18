//
//  LSQRoutesNetworking.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation

class LSQRoutesNetworking : LSQRouter {
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.network.success,
                object: nil,
                queue: OperationQueue.main,
                using: self.handleNetworkSuccess
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.network.error,
                object: nil,
                queue: OperationQueue.main,
                using: self.handleNetworkError
            )
        )
    }
    
    // Top Level Network handlers son
    // TODO: retire this, because it's not needed in the general sense high level at this point
    func handleNetworkSuccess(notification: Notification) {
        // TODO: RETIRE THIS NOW - RETIRE IT, LSQOnboardingManager and LSQPatientManager manage this
        /*
         if notification.userInfo!["object"] as? String == "profile" && notification.userInfo!["action"] as? String == "post" {
         self.activePatientId = notification.userInfo!["patient_id"] as? String
         // TODO: if we were to even have this ghetto zone special, we
         LSQAPI.sharedInstance.loadPatientLegacy(notification.userInfo!["patient_id"]! as! String)
         }
         */
        if notification.userInfo!["object"] as? String == "profile" && notification.userInfo!["action"] as? String == "get" {
            // ok look at the contents of the object yea son
            // let patient: JSON = JSON(notification.userInfo!["response"]!)
            // self.continueSetup(patient)
        }
        // TODO: THIS IS A Poor LOCATION, could/should put directly in the BadgeManager, but that also seemed odd
    }
    
    func handleNetworkError(notification: Notification) {
        // pass
    }
}
