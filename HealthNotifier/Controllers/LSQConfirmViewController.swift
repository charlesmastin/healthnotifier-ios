//
//  LSQConfirmViewController.swift
//
//  Created by Charles Mastin on 11/21/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQConfirmViewController: UIViewController {
    var data: JSON? = nil

    @IBAction func confirm(){
        // ok son this is gonna be a modal though yea son, modal on your modal son

        LSQAPI.sharedInstance.confirmProfile(
            self.data!["profile"]["uuid"].string!,
            success: { response in
                let user: LSQUser = LSQUser.currentUser
                NotificationCenter.default.post(
                    name: LSQ.notification.analytics.event,
                    object: nil,
                    userInfo: [
                        "event": "Patient Confirm",
                        "attributes": [
                            "AccountId": user.uuid!,
                            "Provider": user.provider,
                            "PatientId": self.data!["profile"]["uuid"].string!
                        ]
                    ]
                )
                
                NotificationCenter.default.post(
                    name: LSQ.notification.show.checkout,
                    object: self,
                    userInfo: [
                        "mode": "assign",
                    ]
                )
            },
            failure: { response in
                let alert: UIAlertController = UIAlertController(
                    title: "Server Error",
                    message: "Unable to confirm profile.",
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    // TODO: focus first problem child?
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        )
        
        
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //self.body?.scrollEnabled = false
        //self.body?.scrollEnabled = true
        //self.body?.setContentInset(UIEdgeInsetsMake(-8.0, 0.0, -8.0, 0.0), animated: false)
        //self.body?.text = "I confirm the information entered is accurate and factual. HealthNotifier is a realtime platform and subsequent changes will be available to health care providers in times of intervention or care management."
        
    }
}
