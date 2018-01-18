//
//  LSQRoutesAccount.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit
import EZLoadingActivity

class LSQRoutesAccount : LSQRouter {
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.deleteAccount,
                object: nil,
                queue: OperationQueue.main,
                using: self.deleteAccount
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.goodbye,
                object: nil,
                queue: OperationQueue.main,
                using: self.showGoodbyeScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.accountActions,
                object: nil,
                queue: OperationQueue.main,
                using: self.showAccountActions
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.editAccount,
                object: nil,
                queue: OperationQueue.main,
                using: self.showEditAccountScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.changePassword,
                object: nil,
                queue: OperationQueue.main,
                using: self.showChangePasswordScreen
            )
        )
        
         // TODO: move back somewhere bro
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.termsTouch,
                object: nil,
                queue: OperationQueue.main,
                using: self.showTermsTouchScreen
            )
        )
    }
    
    // TODO: move back somewhere bro
    func showTermsTouchScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQTouchTermsViewController = sb.instantiateViewController(withIdentifier: "TouchTermsViewController") as! LSQTouchTermsViewController
        
        let navigationController = UINavigationController(rootViewController: vc)
        guard let rvc = self.appDelegate.window!.rootViewController else {
            return
        }
        if let cvc:UIViewController = getCurrentViewController(rvc) {
            // cvc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            cvc.present(navigationController, animated: true, completion: {
                //vc.loadData(documentId, fileIndex: fileIndex!)
            })
        }
    }
    
    func showAccountActions(notification: Notification) {
        let vc: UIViewController = notification.object as! UIViewController
        var title: String = "Logged In"
        // TODO: is this crashworthy
        let user:LSQUser = LSQUser.currentUser
        if user.isLoggedIn() {
            title = "Logged in as \(user.email)"
        }
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        let alert: UIAlertController = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: preferredStyle)
        
        let editAction: UIAlertAction = UIAlertAction(title: "Edit Account Details", style: UIAlertActionStyle.destructive, handler: { action in
            NotificationCenter.default.post(name: LSQ.notification.show.editAccount, object: vc)
        })
        alert.addAction(editAction)
        
        // TODO: be in sync
        let registerAction: UIAlertAction = UIAlertAction(title: "Register as Provider", style: UIAlertActionStyle.default, handler: { action in
            NotificationCenter.default.post(name: LSQ.notification.show.providerRegistration, object: vc)
        })
        alert.addAction(registerAction)
        
        let logoutAction: UIAlertAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { action in
            NotificationCenter.default.post(name: LSQ.notification.action.logout, object: vc)
        })
        alert.addAction(logoutAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            // nothing here
        })
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    func showEditAccountScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let vc:LSQEditAccountViewController = sb.instantiateViewController(withIdentifier: "EditAccountViewController") as! LSQEditAccountViewController
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    func showChangePasswordScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let vc:LSQChangePasswordViewController = sb.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! LSQChangePasswordViewController
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    func deleteAccount(notification: Notification) {
        // NON OP
        let user = LSQUser.currentUser
        let alert: UIAlertController = UIAlertController(
            title: "Delete Account?",
            message: "All of your active LifeStickers will be disabled and you will be unable to access the web and mobile apps for this account. If you wish to proceed, please enter \"delete healthnotifier\" into the confirmation field. We’re sorry to see you go.",
            preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "input confirmation here"
        })
        
        let okAction: UIAlertAction = UIAlertAction(title:"Delete", style: UIAlertActionStyle.destructive, handler: { action in
            // nothing here
            // UIApplication.sharedApplication().openURL(NSURL(string: "https://app.domain.com/login?email=\(user.email)")!)
            let email: String = user.email
            if let textFields = alert.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText: String = theTextFields[0].text!
                if enteredText.lowercased() == "delete healthnotifier" {
                    EZLoadingActivity.show("", disableUI: false) // hahahahaha
                    LSQAPI.sharedInstance.deleteAccount(
                        user.uuid!,
                        success: { response in
                            EZLoadingActivity.hide(true, animated: true)
                            
                            NotificationCenter.default.post(name: LSQ.notification.auth.deauthorize, object: nil)
                            //let pvc: UIViewController = notification.object as! UIViewController
                            //pvc.navigationController?.popToRootViewControllerAnimated(true)
                            NotificationCenter.default.post(
                                name: LSQ.notification.show.goodbye,
                                object: self,
                                userInfo: [
                                    "email": email
                                ]
                            )
                    },
                        failure: { response in
                            // SO MUCH FAIL SON
                            EZLoadingActivity.hide(true)
                            
                            let alert: UIAlertController = UIAlertController(
                                title: "Server Error",
                                message: "Unable to delete account :(",
                                preferredStyle: .alert)
                            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                            })
                            alert.addAction(cancelAction)
                            (notification.object as! UIViewController).present(alert, animated: true, completion: nil)
                    }
                    )
                } else {
                    // do nothing - don't close
                    return
                }
            }
        })
        alert.addAction(okAction)
        
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
    
    func showGoodbyeScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQGoodbyeViewController = sb.instantiateViewController(withIdentifier: "GoodbyeViewController") as! LSQGoodbyeViewController
        if notification.userInfo?["email"] != nil {
            //vc.usernameField?.text = notification.userInfo!["email"] as? String
            //vc.passwordField?.becomeFirstResponder()
        }
        self.attachRootVC(vc)
    }
}
