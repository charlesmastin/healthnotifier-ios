//
//  LSQLoginViewController.swift
//
//  Created by Charles Mastin on 2/24/16.
//

import Foundation
import UIKit
import EZLoadingActivity
import Alamofire
import SwiftyJSON

class LSQLoginViewController: UIViewController, UITextFieldDelegate {
    
    fileprivate var failures:Int = 0
    fileprivate var durationTimer: LSQDurationTimer?

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var existingEmail: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.existingEmail != nil {
            self.usernameField.text = self.existingEmail!
        }
    }
    
    // TODO: look up standardized naming conventions
    @IBAction func createAccount(_ sender: UIButton?){
        NotificationCenter.default.post(
            name: LSQ.notification.show.welcome,
            object: self,
            userInfo: nil
            //userInfo:["email": self.usernameField.text!]
        )   
    }

    @IBAction func login(_ sender: UIButton?){
        //
        self.submitLogin()
    }
    
    @IBAction func forgotPassword(_ sender: UIButton?) {
        NotificationCenter.default.post(
            name: LSQ.notification.show.forgotPassword,
            object: self,
            userInfo:["email": self.usernameField.text!]
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: meh don't do this after logout explicitly though
        // however we don't really have that on file
        let uuid: String = LSQUser.currentUser.getSavedUuid()
        if uuid != "" {
            // but truth be told, we're gonna intercept this higher level and just transparently ask
            // now we also have to check the user preferences for da umm, touch ID business
            
            // but for now, let's attempt to restore the user json and nab ourselves the email addy
            let json:JSON = LSQUser.currentUser.getSavedJson()
            // this is bad because it forces us to deal with schema of the original JSON, which COULD BE SKETCHY
            if let email = json["Email"].string {
                self.usernameField.text = email
                
                // we shouldn't just prompt the touch id at this point but we can add a button maybe???, lolzin
                // so confusing
                // auto prompting could create some notion of infinite loop
                // dry this up so much though
                /*
                 LSQUser.currentUser.restorePrefs()
                 if LSQUser.currentUser.prefs.touchIdEnabled {
                    LSQTouchAuthManager.sharedInstance.requestPasswordAsync()
                 }
                */
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.durationTimer = LSQDurationTimer()
        
        // set background color, more global, only here if we need to override 
        // self.view.backgroundColor = LSQ.appearance.color.newTeal
        
        // self.passwordField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LSQLoginViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        
        // was there a recently logged in user
        // kinda ironic here
        
        
        
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var shouldReturn = true
        if textField == self.passwordField {
            shouldReturn = false
            self.submitLogin()
        } else {
            self.passwordField.becomeFirstResponder()
        }
        return shouldReturn
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // change it up chimmy changas
        if textField == self.usernameField {
            textField.returnKeyType = UIReturnKeyType.next
        }
        if textField == self.passwordField {
            textField.returnKeyType = UIReturnKeyType.go
        }
        return true
    }
    
    fileprivate func submitLogin(){
        // do the actual logging in, this can be called from the "submit" keyboard action, or via the button
        // show spinner
        // alert on blank data lolzone brolozone
        if self.usernameField.text == "" || self.passwordField.text == "" {
            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                preferredStyle = UIAlertControllerStyle.actionSheet
            }
            let alert: UIAlertController = UIAlertController(
                title: "Missing Credentials",
                message: "Please input email and password",
                preferredStyle: preferredStyle)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: { action in
                // lolzone son
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //
        self.usernameField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
        
        LSQAPI.sharedInstance.getAccessToken(
            self.usernameField.text!,
            password: self.passwordField.text!,
            success: { response in
                let persisted = LSQUser.currentUser.processAccessToken(response: response)
                if persisted {
                    // do a user fetch, with callback meh meh, this sketchy as shiz
                    LSQUser.currentUser.fetch()
                    
                    // yes we can in fact read the provider status here
                    
                    // meh
                    NotificationCenter.default.post(name: LSQ.notification.analytics.event, object: nil, userInfo:[
                        "event": "Login",
                        "attributes": [
                            "AccountId": LSQUser.currentUser.uuid!,
                            "Provider": false, // because we're not doing this on a callback of the fetch, we're not totally sure
                            "Failures": self.failures,
                            "IdleDuration": self.durationTimer!.stop()
                        ]
                    ])
                    
                    // TODO: DRY this particular call up
                    NotificationCenter.default.post(name: LSQ.notification.auth.authorized, object: nil)
                    
                    // hmm blablablablal
                    NotificationCenter.default.post(name: LSQ.notification.show.tabController, object:nil)
                    // NotificationCenter.default.post(name: LSQ.notification.show.tabPatients, object:self)
                    
                    //
                    
                } else {
                    // we had an error with the token, or we were unable to persist, or something
                    // see this is sketchy in this context, perhaps we need to process here?
                    // well yes we do
                }
            },
            failure: { response in
                // ok here's where we break from the mold slightly in our responses from the OAuth2 spec, or not
                // actually no, we don't because that's just bad for security
                EZLoadingActivity.hide(false, animated: false)
                
                // focus the username field
                // TODO: why with the conditional for the IBOutlet variables? WTF
                self.failures += 1
                
                var title: String = "Login unsuccessful"
                var message: String = ""
                
                var validAccount: Bool = false
                // this is terrible though
                if let theResponse = response as? Alamofire.DataResponse<Any> {
                    if theResponse.response?.statusCode == 401 {
                        title = "That password is incorrect"
                        message = "Try again or use Forgot Password"
                        validAccount = true
                    }
                }
                var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                    preferredStyle = UIAlertControllerStyle.actionSheet
                }
                let alert: UIAlertController = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: preferredStyle)
                let forgotAction: UIAlertAction = UIAlertAction(title:"Forgot Password", style: UIAlertActionStyle.default, handler: { action in
                    self.forgotPassword(nil)
                })
                alert.addAction(forgotAction)
                let registerAction: UIAlertAction = UIAlertAction(title:"Sign Up for HealthNotifier", style: UIAlertActionStyle.default, handler: { action in
                    self.createAccount(nil)
                })
                alert.addAction(registerAction)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Try Again", style: UIAlertActionStyle.cancel, handler: { action in
                    // nothing here
                    // if we had a 400, focus the password field!!!!
                    if validAccount {
                        self.passwordField.becomeFirstResponder()
                    } else {
                        self.usernameField.becomeFirstResponder()
                    }
                    
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        )
        EZLoadingActivity.showWithDelay("Waiting...", disableUI: true, seconds: 0.5)

    }

}
