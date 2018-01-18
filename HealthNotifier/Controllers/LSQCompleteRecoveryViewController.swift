//
//  LSQCompleteRecoveryController.swift
//
//  Created by Charles Mastin on 12/6/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQCompleteRecoveryViewController: UIViewController {
    var token: String = ""
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordField2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.view.backgroundColor = LSQ.appearance.color.newTeal
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.passwordField.becomeFirstResponder()
    }
    // a UI label showing the number we send stuffs to son
    
    @IBAction func actionSubmit() -> Void {
        // pre-validate that shizz, na bro
        let pass = self.passwordField!.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let pass2 = self.passwordField2!.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        //
        if LSQ.validator.password(pass){
            if pass == pass2 {
                
                // API STUFFS - may not have an endpoint though
                
                LSQAPI.sharedInstance.completeRecovery(
                    pass,
                    token: self.token,
                    success: { response in
                        // which should then do the things
                        
                        // TODO auth log in
                        let j = JSON(response)

                        NotificationCenter.default.post(
                            name: LSQ.notification.auth.authorize,
                            object: self,
                            userInfo: [
                                "username": j["email"].string!,
                                "password": pass,
                                "_callback_meta_": "log-complete-recovery"
                                // YES we could have use the "next" attribute but that is more for view redirection
                            ]
                        )
                        
                        // ghetto saucers
                        
                        
                    },
                    failure: { response in
                        let alert: UIAlertController = UIAlertController(
                            title: "Server Error",
                            message: "Unable to reset your password. Your token may be invalid.",
                            preferredStyle: .alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                            // TODO: focus first problem child?
                        })
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                )
                
                
            } else {
                // ALERT NON MATCHING SON
                let alert: UIAlertController = UIAlertController(
                    title: "Passwords do not match",
                    message: "Please confirm your password" ,
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    self.passwordField2.becomeFirstResponder()
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            // ALERT PASSWORDS CRITERIA SON BUN
            let alert: UIAlertController = UIAlertController(
                title: "Password Requirements",
                message: "Must be at least 8 characters and contain either a number or a symbol e.g. #!*" ,
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                self.passwordField.becomeFirstResponder()
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionCancel() -> Void {
        NotificationCenter.default.post(name: LSQ.notification.show.login, object: self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var shouldReturn = true
        if textField == self.passwordField2 {
            shouldReturn = false
            self.actionSubmit()
        } else {
            self.passwordField2.becomeFirstResponder()
        }
        return shouldReturn
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // change it up chimmy changas
        if textField == self.passwordField {
            textField.returnKeyType = UIReturnKeyType.next
        }
        if textField == self.passwordField2 {
            textField.returnKeyType = UIReturnKeyType.go
        }
        return true
    }

}
