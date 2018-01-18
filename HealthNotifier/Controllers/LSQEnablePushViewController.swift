//
//  LSQEnablePushViewController.swift
//
//  Created by Charles Mastin on 3/15/17.
//

import Foundation
import UIKit

class LSQEnablePushViewController: UIViewController {
    private var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = LSQ.appearance.color.newTeal
        self.addObservers()
        
        backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(LSQEnablePushViewController.goBack))
        navigationItem.leftBarButtonItem = backButton
        backButton.isEnabled = false
    }
    
    func goBack(){
        // nada bro
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check status, for example if we had bailed on everything, and denied
        // we need to basically skip this
        // but first we can just show some sad town
        // or not
        // this would require persisting the user decision to deny things, we can't do that 100% in iOS9 but we can in iOS10
        
        // if we are go for remote, but no bueno for alerts, just SKIP and say sorry bro
        let notificationTypes = UIApplication.shared.currentUserNotificationSettings!.types
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications && !notificationTypes.contains(UIUserNotificationType.alert) {
            // we must have rejected it
            // change state on the screen accordingly
            
            // FOR NOW, just alert and go brolo
            // poor UX but faster and idiot-proof
            let alert: UIAlertController = UIAlertController(
                title: "Notifications Disabled",// NSLocalizedString("healthnotifier.session.logout", nil)
                message: "You can re-enable them from your Settings tab in the future. Please continue with setup.",
                preferredStyle: UIAlertControllerStyle.alert)
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
                self.actionSkip(self.view)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        if isRegisteredForRemoteNotifications && notificationTypes.contains(UIUserNotificationType.alert) {
            // we accepted, and for some silly reason this onboarding step was still being called, this is a concern of higher up
            // but this is a last resort to prevent unecessary pain and sufferring
            self.actionSkip(self.view)
        }
    }
    
    @IBAction func actionContinue(_ sender: AnyObject?) -> Void {
        NotificationCenter.default.post(
            name: LSQ.notification.permissions.request.notificationsPrettyPlease,
            object: self
        )
    }

    @IBAction func actionSkip(_ sender: AnyObject?) -> Void {
        NotificationCenter.default.post(
            name: LSQ.notification.action.nextOnboardingStep,
            object: self
        )
    }
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        // THE MEDIATOR is responsible for also listening and handling the user model state stuffs
        // so we know how to proceed when asking in the futures bro
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.permissions.deny.notificationsPrettyPlease,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                //
                self.actionSkip(self.view)
            }
        )
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.permissions.deny.notifications,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.actionSkip(self.view)
            }
        )
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.permissions.authorize.notifications,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // so misleading, but it's the same thing! woot, might as well pat them on the bat too
                self.actionSkip(self.view)
            }
        )
        
    }
    
    func removeObservers() {
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    // TODO: this perhaps needs to be moved to viewDidUnload or something not sure of the entire context it can be rendered visually
    deinit {
        self.removeObservers()
    }
}
