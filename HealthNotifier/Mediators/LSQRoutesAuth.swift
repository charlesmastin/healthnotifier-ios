//
//  LSQRoutesAuth.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit
import KeychainAccess
import SwiftyJSON

class LSQRoutesAuth : LSQRouter {
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.authorize,
                object: nil,
                queue: OperationQueue.main,
                using: self.authAuthorize
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.authorized,
                object: nil,
                queue: OperationQueue.main,
                using: self.authAuthorized
            )
        )
    
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.passwordRetrieved,
                object: nil,
                queue: OperationQueue.main,
                using: self.authPasswordRetrieved
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.passwordRetrievalError,
                object: nil,
                queue: OperationQueue.main,
                using: self.authPasswordRetrievalError
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.deauthorize,
                object: nil,
                queue: OperationQueue.main,
                using: self.authDeauthorize
            )
        )
        
        /*
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.deauthorized,
                object: nil,
                queue: OperationQueue.main,
                using: self.authDeauthorized
            )
        )
        */
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.unauthorized,
                object: nil,
                queue: OperationQueue.main,
                using: self.authUnauthorized
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.unauthorized,
                object: nil,
                queue: OperationQueue.main,
                using: self.authUnauthorized
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.logout,
                object: nil,
                queue: OperationQueue.main,
                using: self.showLogoutAlert
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.forgotPassword,
                object: nil,
                queue: OperationQueue.main,
                using: self.showForgotPasswordScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.passwordSent,
                object: nil,
                queue: OperationQueue.main,
                using: self.showForgotPasswordSuccessScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.unlockSent,
                object: nil,
                queue: OperationQueue.main,
                using: self.showUnlockScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.completeRecovery,
                object: nil,
                queue: OperationQueue.main,
                using: self.showCompleteRecoveryScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.login,
                object: nil,
                queue: OperationQueue.main,
                using: self.showLoginScreen
            )
        )
    }
    
    func showLoginScreen(notification: Notification) {
        //LSQAppearanceManager.sharedInstance.underlinedInputs = true
        LSQAppearanceManager.sharedInstance.activateThemeAuth() // WOO HOO SON
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQLoginViewController = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LSQLoginViewController
        if notification.userInfo?["email"] != nil {
            vc.existingEmail = notification.userInfo!["email"] as? String
            //vc.passwordField?.becomeFirstResponder()
        }
        self.attachRootVC(vc)
    }
    
    func authAuthorize(notification: Notification) {
        // TODO: hook in the Oauth2 flow son
        LSQAPI.sharedInstance.getAccessToken(
            (notification.userInfo!["username"] as? String)!,
            password: (notification.userInfo!["password"] as? String)!,
            success: { response in
                let persisted = LSQUser.currentUser.processAccessToken(response: response)
                
                if persisted {
                    NotificationCenter.default.post(name: LSQ.notification.auth.authorized, object: nil)
                    
                    // do a user fetch, with callback meh meh, this sketchy as shiz
                    LSQUser.currentUser.fetch()
                    
                    if notification.userInfo!["next"] as? String == "registrationSuccess" {
                        // this is probably questionable at best, but it works
                        //self.activePatientId = (notification.userInfo!["patientId"] as? String)!
                        /*
                        NotificationCenter.default.post(
                            name: LSQ.notification.show.registrationSuccess,
                            object: self,
                            userInfo: [
                                // this is so tedius
                                "patientId": (notification.userInfo!["patientId"] as? String)!
                            ]
                        )
                        */
                    } else if notification.userInfo!["next"] as? String == "enablePush" {
                        // this is probably questionable at best, but it works
                        //self.activePatientId = (notification.userInfo!["patientId"] as? String)!
                        /*
                        NotificationCenter.default.post(
                            name: LSQ.notification.show.enablePush,
                            object: self,
                            userInfo: [
                                // this is so tedius
                                "patientId": (notification.userInfo!["patientId"] as? String)!
                            ]
                        )
                         */
                    } else {
                        // HIGHLY SUSPECT CODE???
                     // WHAT THE FLIP SON
                        //NotificationCenter.default.post(name: LSQ.notification.dismiss.login, object:self)
                        /*
                         guard let rvc = self.appDelegate.window!.rootViewController else {
                         return
                         }
                         if let vc:UIViewController = getCurrentViewController(rvc) {
                         vc.navigationController?.popToViewController(self.allTheTabs[0].childViewControllers.first!, animated: true)
                         }
                         */
                    }
                    
                    // not to interfere with the next command which is meant for view redirection, but w/e reinvent dem wheels
                    if let meta = notification.userInfo!["_callback_meta_"] as? String {
                        if meta == "log-complete-recovery" {
                            NotificationCenter.default.post(
                                name: LSQ.notification.analytics.event,
                                object: nil,
                                userInfo: [
                                    "event": "Account Complete Recovery",
                                    "attributes": [
                                        "AccountId": LSQUser.currentUser.uuid!
                                    ]
                                ]
                            )
                        }
                    }
                    
                    
                } else {
                    // we had an error with the token, or we were unable to persist, or something
                    // see this is sketchy in this context, perhaps we need to process here?
                    // well yes we do
                }
        },
            failure: { response in
                // ok here's where we break from the mold slightly in our responses from the OAuth2 spec, or not
                // actually no, we don't because that's just bad for security
                NotificationCenter.default.post(name: LSQ.notification.show.login, object:self)
        }
        )
    }
    
    
    
    
    func authAuthorized(notification: Notification) {
        //
        print("authAuthorized")
        
        // FIXME: restore
        LSQScanHistory.sharedInstance.initializeForUser(LSQUser.currentUser.uuid!)
        
        UIApplication.shared.registerForRemoteNotifications()
        
        LSQUser.currentUser.fetch()
        //LSQBadgeManager.sharedInstance.sync()
    }
    
    func authPasswordRetrievalError(notification: Notification) {
        print("password retrieval error")
        // so primary use case is failure or cancelling the auth to lookup the encrypted password
        // since our common case is auth on all requests, the logical thing is to deauth and kick to login
        NotificationCenter.default.post(name: LSQ.notification.auth.deauthorize, object: nil)
    }
    
    func authPasswordRetrieved(notification: Notification) {
        let password = notification.userInfo!["password"] as? String
        let json:JSON = LSQUser.currentUser.getSavedJson()
        if let email = json["Email"].string {
            LSQAPI.sharedInstance.getAccessToken(
                email,
                password: password!,
                success: { response in
                    // meh meh meh meh
                    let persisted = LSQUser.currentUser.processAccessToken(response: response)
                    if persisted {
                        NotificationCenter.default.post(name: LSQ.notification.auth.authorized, object: nil)
                        // do the previous failed operation bro
                        print("perform queued network operation now")
                        // do a user fetch, with callback meh meh, this sketchy as shiz
                        LSQUser.currentUser.fetch()
                    } else {
                        // we had an error with the token, or we were unable to persist, or something
                        // see this is sketchy in this context, perhaps we need to process here?
                        // well yes we do
                    }
            },
                failure: { response in
                    // present this is some way or form, neg
                    NotificationCenter.default.post(name: LSQ.notification.auth.deauthorize, object: nil)
            }
            )
        }
    }
    
    func showLogoutAlert(notification: Notification) {
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        let alert: UIAlertController = UIAlertController(
            title: "Really log out of HealthNotifier?",// NSLocalizedString("healthnotifier.session.logout", nil)
            message: nil,
            preferredStyle: preferredStyle)
        
        // NSLocalizedString(@"healthnotifier.button.logout", nil)
        let logoutAction: UIAlertAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive, handler: { action in
            NotificationCenter.default.post(
                name: LSQ.notification.auth.deauthorize,
                object: nil,
                userInfo: [
                    "userInvoked": true
                ]
            )
        })
        
        alert.addAction(logoutAction)
        
        //NSLocalizedString(@"healthnotifier.button.cancel", nil)
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            // nothing here
        })
        alert.addAction(cancelAction)
        
        // TODO: DRY THIS SHIZ UP
        guard let rvc = self.appDelegate.window!.rootViewController else {
            return
        }
        if let vc:UIViewController = getCurrentViewController(rvc) {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func authDeauthorize(notification: Notification) {
        // really that stuffs should be the the model, which should send a auth.deauthorized notification
        // THIS IS A CLUSTER OF STUFFS
        // this is me not understanding optionals and all that jazz son
        var invoked : Bool = false
        if notification.userInfo != nil {
            if (notification.userInfo?.keys.contains("userInvoked"))! {
                invoked = true
            }
        }
        /*
        if (notification.userInfo != nil && ["userInvoked"] as? Bool)! {
            invoked = true
        } else {
            // no plan for this currently
        }
        */
                /*
        do {
            invoked = try notification.userInfo?["userInvoked"] as? Bool!!!
        } catch {
            // nothing
        }
        */
        if LSQUser.currentUser.isLoggedIn() && invoked {
            NotificationCenter.default.post(
                name: LSQ.notification.analytics.event,
                object: nil,
                userInfo: [
                    "event": "Logout",
                    "attributes": [
                        "AccountId": LSQUser.currentUser.uuid!,
                        "Provider": LSQUser.currentUser.provider
                    ]
                ]
            )
            // this is supposed to do the stuffs
            LSQUser.currentUser.destroy()
        }
        //self.activePatientId = nil
        LSQPatientManager.sharedInstance.reset()
        LSQScanHistory.sharedInstance.purge()
        LSQBadgeManager.sharedInstance.reset()
        LSQOnboardingManager.sharedInstance.reset()
        
        // TODO: RESTORE THIS BROLO
        // logout on server, so we stop getting push notifications to this device
        // Be sure to pass along the push token though, which let's us dance around the shared auth token architecture
        if invoked {
            LSQAPI.sharedInstance.deauthenticateAccount(
                { response in
                    LSQAPI.sharedInstance.clearToken()
                },
                failure: { response in
                    // alert perhaps
                    //
                    // bail on this totally not sure why we sat there and hung on our 401, hmm or whatever
                    //
            }
            )
        }
        // now quickly check if we have any keychain saved stuff, but if we wiped it down, we need to go to welcome screen bro
        // the deauthorized part
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        let j = try! keychain.get(LSQUser.keyForUuid)
        if j != nil {
            NotificationCenter.default.post(name: LSQ.notification.show.login, object: nil)
        } else {
            NotificationCenter.default.post(name: LSQ.notification.show.welcome, object: nil)
        }
    }
    
    func authUnauthorized(notification: Notification) {
        print("authUnauthorized")
        // TODO: more elegant way to cancel existing stuffs
        
        // can we catch it the first time around though only
        
        // top level handler, the goal is VC's could themselves listen for it? we need to think about that event flow, this is a stop gap global option though
        
        // so in the most general sense we can…
        // attempt to reauthenticate at this point via our token cycling strategies
        // present based on a root view controller
        
        // or fallback to the login VC as a last resort
        // huh what?
        
        // TODO: store our NEXT operation for manual retry lololo, maybe someday it will all work seamlessly
        
        let uuid: String = LSQUser.currentUser.getSavedUuid()
        if uuid != "" {
            let json:JSON = LSQUser.currentUser.getSavedJson()
            if json["Email"].exists() {
                LSQUser.currentUser.restorePrefs()
                if LSQUser.currentUser.prefs.touchIdEnabled {
                    // introduce some delay, and place on background thread though?
                    LSQTouchAuthManager.sharedInstance.requestPasswordAsync()
                    return
                }
            }
        }
        // as fallback now issue the deauthorize command
        NotificationCenter.default.post(name: LSQ.notification.auth.deauthorize, object: nil)
    }
    
    func authDeauthorized(notification: Notification) {
        // TODO: flow this back in though
        // call our local authDeauthorize, then show us a special special alert about being booted from da server
        // NotificationCenter.default.post(name: LSQ.notification.auth.deauthorize, object: nil)
    }
    
    // MARK: Forgot Password
    
    func showForgotPasswordScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQForgotPasswordViewController = sb.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! LSQForgotPasswordViewController
        if notification.userInfo?["email"] != nil {
            vc.existingEmail = notification.userInfo!["email"] as? String
        }
        self.attachRootVC(vc)
    }
    
    func showForgotPasswordSuccessScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQForgotPasswordSuccessViewController = sb.instantiateViewController(withIdentifier: "ForgotPasswordSuccessViewController") as! LSQForgotPasswordSuccessViewController
        self.attachRootVC(vc)
    }
    
    func showUnlockScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQUnlockViewController = sb.instantiateViewController(withIdentifier: "UnlockViewController") as! LSQUnlockViewController
        if notification.userInfo?["phone"] != nil {
            // use the existing blablabla pattern son
            vc.mobilePhone = (notification.userInfo!["phone"] as? String)!
        } else {
            // we're fd
        }
        self.attachRootVC(vc)
    }
    
    func showCompleteRecoveryScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQCompleteRecoveryViewController = sb.instantiateViewController(withIdentifier: "CompleteRecoveryViewController") as! LSQCompleteRecoveryViewController
        if notification.userInfo?["token"] != nil {
            vc.token = (notification.userInfo!["token"] as? String)!
        } else {
            // we're fd
        }
        self.attachRootVC(vc)
    }
    
    
    
    
    
    
}
