//
//  LSQPushController.swift
//
//  Created by Charles Mastin on 3/15/17.
//

import Foundation
import SwiftyJSON
import UIKit

class LSQPushController : NSObject {
    
    var notification: [AnyHashable: Any] = [:]
    var notificationJson: JSON? = nil
    
    // TODO: move generic handling of call/sms into a category so it can work without launching the app though, mmmkay
    // this is for demonstration purposes here
    
    
    // static let sharedInstance = LSQPushController()
    func handleNotification(_ application: UIApplication, userInfo: [AnyHashable: Any]) {
        self.notification = userInfo
        // try/guard/let suck it up and wrap this up
        self.notificationJson = JSON(self.notification)
        //
        switch application.applicationState {
            case .active:
                //app is currently active, can update badges count here
                self.handleForeground()
                break
            case .inactive:
                //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
                self.handleTransitioning()
                break
            case .background:
                //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
                self.handleBackground()
                break
        }
    }
    
    func parseNotification() {
        // http://stackoverflow.com/questions/28596295/swift-read-userinfo-of-remote-notification
        /*
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["message"] as? NSString {
                    //Do stuff
                    print(message)
                }
            } else if let alert = aps["alert"] as? NSString {
                //Do stuff
                print(alert)
            }
        }
        */
        /*
        if let lsq = userInfo["lsq"] as? NSDictionary {
            print("HealthNotifier Custom Data Payload")
            print(lsq)
        }
        */
        
    }
    
    func handleForeground() {
        // do stuff while in foreground, likely super rare
        if let eventName = self.notificationJson!["data"]["event"].string {
            switch eventName {
                case "test":
                    break
                case "patient-network-request":
                    LSQBadgeManager.sharedInstance.sync()
                    break
                case "patient-network-revoked":
                    if LSQPatientManager.sharedInstance.uuid! == self.notificationJson!["data"]["auditor_uuid"].string! {
                        LSQPatientManager.sharedInstance.fetch()
                    }
                    break
                case "patient-network-granted":
                    if LSQPatientManager.sharedInstance.uuid! == self.notificationJson!["data"]["auditor_uuid"].string! {
                        LSQPatientManager.sharedInstance.fetch()
                    }
                    let appDelegate = UIApplication.shared.delegate as! LSQAppDelegate
                    guard let rvc = appDelegate.window!.rootViewController else {
                        return
                    }
                    // if you own it, perhaps just load dat patient doe
                    if let vc:UIViewController = getCurrentViewController(rvc) {
                        //
                        // alert on that sucker
                        //
                        //
                        let alert: UIAlertController = UIAlertController(
                            title: self.notificationJson!["aps"]["alert"]["body"].string!,
                            message: nil,
                            preferredStyle: UIAlertControllerStyle.alert)
                        
                        let openAction: UIAlertAction = UIAlertAction(title:"View LifeSticker", style: UIAlertActionStyle.cancel, handler: { action in
                            // nothing here
                            // close it out brolo
                            let userInfo = ["patientId": self.notificationJson!["data"]["granter_uuid"].string!] as [String : Any]
                            NotificationCenter.default.post(
                                name: LSQ.notification.show.lifesquare,
                                object: vc,
                                userInfo: userInfo
                            )
                        })
                        alert.addAction(openAction)
                        
                        let cancelAction: UIAlertAction = UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default, handler: { action in
                            // nothing here
                        })
                        alert.addAction(cancelAction)
                        
                        vc.present(alert, animated: true, completion: nil)
                    }
                    break
                case "provider-status":
                    // sync account model, show alert with message
                    LSQUser.currentUser.fetch()
                    
                    let appDelegate = UIApplication.shared.delegate as! LSQAppDelegate
                    guard let rvc = appDelegate.window!.rootViewController else {
                        return
                    }
                    // if you own it, perhaps just load dat patient doe
                    if let vc:UIViewController = getCurrentViewController(rvc) {
                        //
                        // alert on that sucker
                        //
                        //
                        let alert: UIAlertController = UIAlertController(
                            title: self.notificationJson!["aps"]["alert"]["body"].string!,
                            message: nil,
                            preferredStyle: UIAlertControllerStyle.alert
                        )
                        
                        let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: { action in
                            // nothing here
                        })
                        alert.addAction(cancelAction)
                        
                        vc.present(alert, animated: true, completion: nil)
                    }
                    
                    break
                case "postscan":
                    // represent as some kind of alert
                    let appDelegate = UIApplication.shared.delegate as! LSQAppDelegate
                    guard let rvc = appDelegate.window!.rootViewController else {
                        return
                    }
                    // if you own it, perhaps just load dat patient doe
                    if let vc:UIViewController = getCurrentViewController(rvc) {
                        //
                        // alert on that sucker
                        //
                        //
                        let alert: UIAlertController = UIAlertController(
                            title: "LifeSticker Scanned",
                            message: self.notificationJson!["aps"]["alert"]["body"].string!,
                            preferredStyle: UIAlertControllerStyle.alert)
                        
                        let openAction: UIAlertAction = UIAlertAction(title:"View LifeSticker", style: UIAlertActionStyle.cancel, handler: { action in
                            // nothing here
                            // close it out brolo
                            let userInfo = ["patientId": self.notificationJson!["data"]["patient_uuid"].string!] as [String : Any]
                            NotificationCenter.default.post(
                                name: LSQ.notification.show.lifesquare,
                                object: vc,
                                userInfo: userInfo
                            )
                        })
                        alert.addAction(openAction)
                        
                        let cancelAction: UIAlertAction = UIAlertAction(title:"Dismiss", style: UIAlertActionStyle.default, handler: { action in
                            // nothing here
                        })
                        alert.addAction(cancelAction)
                        
                        vc.present(alert, animated: true, completion: nil)
                    }
                    break
                default:
                    break
            }
        }
    }
    
    func handleTransitioning() {
        // aka the basic click interaction on UNNotifications in the "background"
        if let eventName = self.notificationJson!["data"]["event"].string {
            switch eventName {
                case "test":
                    break
                case "patient-network-request":
                    LSQBadgeManager.sharedInstance.sync()
                    // show inbox tab after this, but we need a callback
                    break
                case "patient-network-revoked":
                    // basically just reload dem auditor patient
                    // show inbox tab after this, but we need a callback
                    if LSQPatientManager.sharedInstance.uuid! == self.notificationJson!["data"]["auditor_uuid"].string! {
                        LSQPatientManager.sharedInstance.fetch()
                    }
                    break
                case "patient-network-granted":
                    // open up the patient view, with a fresh set of data
                    if LSQPatientManager.sharedInstance.uuid! == self.notificationJson!["data"]["auditor_uuid"].string! {
                        LSQPatientManager.sharedInstance.fetch()
                    }
                    
                    let appDelegate = UIApplication.shared.delegate as! LSQAppDelegate
                    guard let rvc = appDelegate.window!.rootViewController else {
                        return
                    }
                    // if you own it, perhaps just load dat patient doe
                    if let vc:UIViewController = getCurrentViewController(rvc) {
                        let userInfo = ["patientId": self.notificationJson!["data"]["granter_uuid"].string!] as [String : Any]
                        NotificationCenter.default.post(
                            name: LSQ.notification.show.lifesquare,
                            object: vc,
                            userInfo: userInfo
                        )
                    }
                    break
                case "provider-status":
                    // sync account model
                    LSQUser.currentUser.fetch()
                    break
                case "postscan":
                    let appDelegate = UIApplication.shared.delegate as! LSQAppDelegate
                    guard let rvc = appDelegate.window!.rootViewController else {
                        return
                    }
                    // if you own it, perhaps just load dat patient doe
                    if let vc:UIViewController = getCurrentViewController(rvc) {
                        let userInfo = ["patientId": self.notificationJson!["data"]["patient_uuid"].string!] as [String : Any]
                        NotificationCenter.default.post(
                            name: LSQ.notification.show.lifesquare,
                            object: vc,
                            userInfo: userInfo
                        )
                    }
                    break
                default:
                    break
            }
        }
    }
    
    func handleBackground() {
        // we will likely disable this because we're not going to do any real data syncing etc
    }
    
    // ok basically it's a router to controller methods
    
}
