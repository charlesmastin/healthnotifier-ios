//
//  LSQUnlockViewController.swift
//
//  Created by Charles Mastin on 12/6/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQUnlockViewController: UIViewController {
    var mobilePhone: String = ""
    
    @IBOutlet weak var codeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = LSQ.appearance.color.newTeal
    }
    // a UI label showing the number we send stuffs to son
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var shouldReturn = true
        if textField == self.codeField {
            shouldReturn = false
            self.actionSubmit()
        }
        return shouldReturn
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.codeField {
            textField.returnKeyType = UIReturnKeyType.go
        }
        return true
    }
    
    @IBAction func actionSubmit() -> Void {
        // pre-validate that, na bro
        // trim that
        let code = self.codeField!.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        LSQAPI.sharedInstance.unlockAccountWithCode(
            code,
            phone: self.mobilePhone,
            success: { response in
                
                let j = JSON(response)
                NotificationCenter.default.post(
                    name: LSQ.notification.show.completeRecovery,
                    object: self,
                    userInfo: [
                        "token": j["token"].string!
                    ]
                )
                
                NotificationCenter.default.post(
                    name: LSQ.notification.analytics.event,
                    object: nil,
                    userInfo: [
                        "event": "Account Unlock"
                    ]
                )
            },
            failure: { response in
                let alert: UIAlertController = UIAlertController(
                    title: "Error",
                    message: "Invalid Unlock Code",
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    self.codeField.becomeFirstResponder()
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        )
    }
    
    @IBAction func actionCancel() -> Void {
        NotificationCenter.default.post(name: LSQ.notification.show.login, object: self)
    }
}
