//
//  LSQRoutesPermissions.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit
import AVFoundation
import UserNotifications

class LSQRoutesPermissions : LSQRouter {
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.permissions.request.camera,
                object: nil,
                queue: OperationQueue.main,
                using: self.requestPermissionCamera
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.permissions.request.location,
                object: nil,
                queue: OperationQueue.main,
                using: self.requestPermissionLocation
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.permissions.request.notificationsPrettyPlease,
                object: nil,
                queue: OperationQueue.main,
                using: self.requestPermissionNotificationsPrettyPlease
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.permissions.request.notifications,
                object: nil,
                queue: OperationQueue.main,
                using: self.requestPermissionNotifications
            )
        )
    }
    
    func requestPermissionCamera(notification: Notification) {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
            if granted == true {
                // User granted
                print("YES")
                NotificationCenter.default.post(name: LSQ.notification.permissions.authorize.camera, object: self)
            } else {
                // User Rejected
                print("NO")
                NotificationCenter.default.post(name: LSQ.notification.permissions.deny.camera, object: self)
            }
        })
    }
    
    func requestPermissionPhotos(notification: Notification) {
        
    }
    
    func requestPermissionLocation(notification: Notification) {
        
    }
    
    func requestPermissionNotificationsPrettyPlease(notification: Notification) {
        // the alert before the alert
        let preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        let alert: UIAlertController = UIAlertController(
            title: "Can we send you push notifications?",// NSLocalizedString("healthnotifier.session.logout", nil)
            message: "HealthNotifier uses push for actions requiring approval and notifications regarding your account and LifeCircle.",
            preferredStyle: preferredStyle)
        
        // EVEN APPLE IS HACKING THEIR OWN UI PATTERNS AS PER EXAMPLE
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: { action in
            NotificationCenter.default.post(name: LSQ.notification.permissions.request.notifications, object: (notification.object as! UIViewController))
        })
        
        alert.addAction(yesAction)
        
        // so slightly tricky/dark pattern do not show a cancel style because it's overwhelming and distracting
        let cancelAction: UIAlertAction = UIAlertAction(title:"No Thanks", style: UIAlertActionStyle.default, handler: { action in
            NotificationCenter.default.post(name: LSQ.notification.permissions.deny.notificationsPrettyPlease, object: nil)
            // try to set the user bit to false
            // user model false bro
        })
        alert.addAction(cancelAction)
        
        // we ALWAYS have a calling context for this
        (notification.object as! UIViewController).present(alert, animated: true, completion: nil)
    }
    
    func requestPermissionNotifications(notification: Notification) {
        print("request for real doe")
        // if iOS 10, do it to it
        if #available(iOS 10, *) {
            print("ios10 only")
            let authOptions : UNAuthorizationOptions = [UNAuthorizationOptions.alert, UNAuthorizationOptions.badge, UNAuthorizationOptions.sound]
            
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { (success: Bool, error: Error?) in
                    if success {
                        print("yes push")
                        NotificationCenter.default.post(name: LSQ.notification.permissions.authorize.notifications, object: nil)
                        LSQUser.currentUser.prefs.pushEnabled = true
                        LSQUser.currentUser.persistPrefs()
                        // user model should listen though
                        // only at this point in time…
                        // register only at this point? or not
                    } else {
                        print("no pushy pushy")
                        NotificationCenter.default.post(name: LSQ.notification.permissions.deny.notifications, object: nil)
                        LSQUser.currentUser.prefs.pushEnabled = false
                        LSQUser.currentUser.persistPrefs()
                        // user model should listen though
                    }
            }
            )
            
            // do this regardless brizzle, for "silent-push", etc
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            print("ios9 only")
            
            let types: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
            
            // the current view glitches and drops back to login for no known reason, super strange.
            
        }
        
        
    }
}
