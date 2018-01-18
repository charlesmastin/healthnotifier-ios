//
//  LSQPatientManager.swift
//
//  Created by Charles Mastin on 9/6/17.
//

import Foundation
import SwiftyJSON

class LSQPatientManager {
    
    // this class is kinda cheesy but it's here so we can reduce our desire to pass top level patient JSON in every single notification center message
    static let sharedInstance = LSQPatientManager()
    var uuid: String? = nil
    var json: JSON? = nil // when there is not a patient established, this is true
    
    func reset(){
        self.uuid = nil
        self.json = nil
    }
    
    //FML
    func fetchWithCallbacks(success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void){
        // load with callbacks, meh
        // some caching meh?
        if self.uuid != nil {
            LSQAPI.sharedInstance.loadPatient(
                self.uuid!,
                success: { response in
                    self.json = JSON(response)
                    success(response as AnyObject)
                },
                failure: { response in
                    failure(response as AnyObject)
                }
            )
        }
    }
    
    func fetch(){
        // load with callbacks, meh
        // some caching meh?
        if self.uuid != nil {
            LSQAPI.sharedInstance.loadPatient(
                self.uuid!,
                success: { response in
                    // since we're not transactionally blocking this load
                    // we have to check if we're still umm valid once this success ok
                    if self.uuid != nil {
                        self.json = JSON(response)
                        // broadcast though by default in the underlying son
                        // NOW broadcast, because we can access it now.
                        
                        NotificationCenter.default.post(
                            name: LSQ.notification.loaded.patient2,
                            object: self,
                            userInfo: [
                                "uuid": self.uuid!
                            ]
                        )
                    }
                },
                failure: { response in
                    // really not sure what to do, other than broadcast a generic load fail
                    // self.patientLoadFailure(notification?.object as! UIViewController)
                    // TOP level root attach a "toast" like thing
                    // just broadcast and the navigation mediator can attempt to do something with it????
                }
            )
        }
    }
    
}
