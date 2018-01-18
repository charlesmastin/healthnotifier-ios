//
//  LSQForgotPasswordViewController.swift
//
//  Created by Charles Mastin on 2/25/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQForgotPasswordViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var mobilePhoneField: UITextField!

    var existingEmail: String?
    var existingPhone: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.existingEmail != nil {
            self.usernameField.text = self.existingEmail!
        }
        if self.existingPhone != nil {
            self.mobilePhoneField.text = self.existingPhone!
        }
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if self.existingEmail == nil {
            self.usernameField.becomeFirstResponder()
        } else {
            self.mobilePhoneField.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
//        self.view.backgroundColor = LSQ.appearance.color.newTeal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LSQForgotPasswordViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        
        
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        self.usernameField.resignFirstResponder()
        self.mobilePhoneField.resignFirstResponder()
    }
    
    /*
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.reminderButtonClicked(nil)
        return false
    }
    */
 
    @IBAction func reminderButtonClicked(_ sender: UIButton?){
        self.actionSubmit()
    }

    @IBAction func loginButtonPressed(_ sender: UIButton?){
        NotificationCenter.default.post(name: LSQ.notification.show.login, object: self)
    }

    func actionSubmit() {
        let email = self.usernameField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let phone = self.mobilePhoneField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if !LSQ.validator.email(email) {
            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                preferredStyle = UIAlertControllerStyle.actionSheet
            }
            let alert: UIAlertController = UIAlertController(
                title: "Oops",
                message: "Please enter an actual email address before submitting!",
                preferredStyle: preferredStyle)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                // nothing here
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        self.usernameField!.resignFirstResponder()
        self.mobilePhoneField!.resignFirstResponder()
        
        var mobile_mode: Bool = false
        
        if phone != "" {
            // WEAK and no server validation but what/ver
            mobile_mode = true
        }
        
        LSQAPI.sharedInstance.forgotPassword(
            email,
            phone: phone,
            success: { response in
                                
                NotificationCenter.default.post(
                    name: LSQ.notification.analytics.event,
                    object:nil,
                    userInfo: [
                        "event": "Password Reminder",
                        "attributes": [
                            "Mobile": mobile_mode
                        ]
                    ]
                )
                
                // inspect the content for the "CHANNEL" son
                let j = JSON(response)
                
                // slightly dicey son
                if j["channel"].string!.uppercased() == "SMS" {
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.unlockSent,
                        object: self,
                        userInfo:[
                            "email": email,
                            "phone": phone
                        ]
                    )
                }else {
                    NotificationCenter.default.post(name: LSQ.notification.show.passwordSent, object: self)
                }
                
                // TODO: have some server sent uid here so we can attach it to something useful
                // tack fails, etc on phising
            },
            failure: { response in
                var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                    preferredStyle = UIAlertControllerStyle.actionSheet
                }
                let alert: UIAlertController = UIAlertController(
                    title: "Oops",
                    message: "We couldn’t find that email in our system. Contact support@domain.com if you need assistance.",
                    preferredStyle: preferredStyle)
                let registerAction: UIAlertAction = UIAlertAction(title:"Sign Up for HealthNotifier", style: UIAlertActionStyle.default, handler: { action in
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.onboardingAccount,
                        object: self,
                        userInfo:[
                            "email": email,
                            //"phone": phone
                        ]
                    )
                })
                alert.addAction(registerAction)
                
                // wootsy colins
                alert.addAction(LSQ.action.support)
                
                let cancelAction: UIAlertAction = UIAlertAction(title:"Try Again", style: UIAlertActionStyle.cancel, handler: { action in
                    // nothing here
                    self.usernameField!.becomeFirstResponder()
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var shouldReturn = true
        if textField == self.mobilePhoneField {
            shouldReturn = false
            self.actionSubmit()
        } else {
            self.mobilePhoneField.becomeFirstResponder()
        }
        return shouldReturn
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // change it up chimmy changas
        if textField == self.usernameField {
            textField.returnKeyType = UIReturnKeyType.next
        }
        if textField == self.mobilePhoneField {
            textField.returnKeyType = UIReturnKeyType.go
        }
        return true
    }

}

