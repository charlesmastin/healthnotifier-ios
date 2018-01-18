//
//  LSQAppDelegate.swift
//
//  Created by Charles Mastin on 2/27/16.
//

import UIKit
import Fabric
import Crashlytics
import KeenClient
import Stripe
import Kingfisher
import AlamofireNetworkActivityIndicator
import UserNotifications
import UserNotificationsUI
import SwiftyJSON

@UIApplicationMain
class LSQAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var routers:[LSQRouter] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // yea son
        self.connectRouters()
        
        // fabric, analytics, etc
        self.initializeThirdParties()
        
        // theme your stuff silly
        LSQ.appearance.initialize()
        
        // top level listeners, soon to be gone bro
        self.initializeMediators()
        
        let user:LSQUser = LSQUser.currentUser
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        // place dummy VC on, just to fulfill the basic requirement and buy us some time to calcuate stuffs
        let sb:UIStoryboard = UIStoryboard(name:"Launch Screen", bundle:nil)
        let vc:UIViewController = sb.instantiateViewController(withIdentifier: "LaunchScreenViewController")
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        // top level app restore, from auth perspective
        // inside navigation mediator will be the logic to manage resuming user/onboarding state from successfull auth
        if user.restoreAccessToken() {
            user.restoreUserJson()
            // if we are "not expired locally"
            // at the high level, let's do this, as this will kick off a 401 if we need to
            user.fetch()
            // basically if this is going to fail, it's going to fail
            // optimistic init
            LSQScanHistory.sharedInstance.initializeForUser(LSQUser.currentUser.uuid!)
            UIApplication.shared.registerForRemoteNotifications()
            
            // TODO: pause until we know auth was good, so we don't flash to login, meh, meh
            
            // we need an auth authorized callback state manager, so we don't' even need this jimmy jangle
            // NotificationCenter.default.post(name: LSQ.notification.show.tabController, object:nil)
            // worse thing is the auth expires and re re-auth which replaces the view mounted here, not too much compromise, exception
            // no networking, but then again, someone would have needed to be previously authenticated, meh, low risk.
        } else {
            NotificationCenter.default.post(name: LSQ.notification.show.welcome, object:nil)
            // this is a security blanket over the UI
            // NotificationCenter.default.post(name: LSQ.notification.auth.unauthorized, object: nil)
        }
        
        // Kick off Values service, always ok, since it does not require auth
        LSQAPI.sharedInstance.loadValues()
        
        // okie dokie
        return true
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        // inspect notificationSettings to see what the user said!
        // OH BOY - the missing link already, but only do this for iOS 9, don't even bother watching or listening or whatever yea son
        // https://thatthinginswift.com/remote-notifications/
        if #available(iOS 10, *) {
            // already handled using the modern UNUserNotificationCenter
        } else {
            //
            let notificationTypes = UIApplication.shared.currentUserNotificationSettings!.types
            
            if notificationTypes.contains(UIUserNotificationType.alert) {
                // good enough for me, despite asking for sound and badge
                // technically this will fire if the user tweaks stuff in the settings, but w/e it's not making any difference if there aren't any listeners!
                print("ios 9 you has notifications authorized, hopefully you has remote too")
                NotificationCenter.default.post(name: LSQ.notification.permissions.authorize.notifications, object: nil)
                DispatchQueue.main.async(){
                    //code
                    print("Hahaha")
                }
                //LSQUser.currentUser.prefs.pushEnabled = true
                //LSQUser.currentUser.persistPrefs()
            } else {
                // whatevs bro
                print("ios 9 you likely denied notifications permissions, or you removed them")
                NotificationCenter.default.post(name: LSQ.notification.permissions.deny.notifications, object: nil)
                DispatchQueue.main.async(){
                    print("ssssssss")
                }
                //LSQUser.currentUser.prefs.pushEnabled = false
                //LSQUser.currentUser.persistPrefs()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var deviceTokenString: String = ""
        // http://stackoverflow.com/questions/39495391/swift-3-device-tokens-are-now-being-parsed-as-32bytes/39518078
        if #available(iOS 10.0, *) {
            var token = ""
            for i in 0..<deviceToken.count {
                token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
            }
            deviceTokenString = token
        } else {
            // is this where we double chimmy changa changa check your chiminies
            let characterSet: CharacterSet = CharacterSet(charactersIn: "<>")
            deviceTokenString = (deviceToken.description as NSString)
                .trimmingCharacters(in: characterSet)
                .replacingOccurrences( of: " ", with: "") as String
        }
        if deviceTokenString != "" {
            LSQAPI.sharedInstance.addDeviceToken(
                deviceTokenString,
                success: { response in
                    LSQUser.currentUser.prefs.pushEnabled = true
                },
                failure: { response in
                    LSQUser.currentUser.prefs.pushEnabled = false
                }
            )
            // unsure if this is the best place to do it though
            self.configureNotificationActions()
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("no remote notifications for you son")
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]){
        // could have easily just made a delegate
        let pushController: LSQPushController = LSQPushController()
        pushController.handleNotification(application, userInfo:userInfo)
    }
    
    // notification action handler
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            // The user dismissed the notification without taking action
            
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // The user launched the app
        } else {
            let identifier = response.actionIdentifier
            let json = JSON(response.notification.request.content.userInfo)
            // check da category son
            if identifier == "SCANDETAILS_ACTION" {
                // meh meh meh
            }
            if identifier == "CALL_ACTION" {
                if let phone = json["data"]["phone"].string {
                    LSQ.launchers.phone(phone)
                }
            }
            if identifier == "SMS_ACTION" {
                if let phone = json["data"]["phone"].string {
                    LSQ.launchers.sms(phone)
                }
            }
        }
        completionHandler()
    }
    
    // TODO: handle network offline / online
    
    // TODO: foreground sync on the badge / notifications son

    func applicationDidEnterBackground(_ application: UIApplication) {
        let taskId: UIBackgroundTaskIdentifier = application.beginBackgroundTask(expirationHandler: {() -> Void in
            
        });
        KeenClient.shared().upload(finishedBlock: {() -> Void in
            application.endBackgroundTask(taskId)});
        
    }
    
    fileprivate func configureNotificationActions(){
        print("configure notification actions modern style")
        if #available(iOS 10.0, *) {
            
            // view LifeSticker
            
            // view details (go into app for summary UI of scan, me)
            let detailsAction = UNNotificationAction(identifier: "SCANDETAILS_ACTION",
                                                  title: "View Details",
                                                  options: .foreground)
            
            let callAction = UNNotificationAction(identifier: "CALL_ACTION",
                                                    title: "Callback",
                                                    options: .foreground)
            let smsAction = UNNotificationAction(identifier: "SMS_ACTION",
                                                  title: "Message",
                                                  options: .foreground)
            
            
            let postscanCategory = UNNotificationCategory(identifier: "POSTSCAN",
                                                         actions: [detailsAction, callAction, smsAction],
                                                         intentIdentifiers: [],
                                                         options: [])
            
            let postscansmsCategory = UNNotificationCategory(identifier: "POSTSCANSMS",
                                                          actions: [detailsAction, callAction, smsAction],
                                                          intentIdentifiers: [],
                                                          options: [])
            
            // Register the category.
            let center = UNUserNotificationCenter.current()
            center.setNotificationCategories([postscanCategory, postscansmsCategory])
        }
    }
    
    fileprivate func initializeMediators(){
        // huh not her bro
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LSQAppDelegate.analyticsTrackEvent(_:)),
            name: LSQ.notification.analytics.event,
            object: nil
        )
        
    }
    
    fileprivate func connectRouters(){
        self.disconnectRouters()
        self.routers = []
        self.routers.append(contentsOf: [
            LSQRoutesAccount(),
            LSQRoutesAuth(),
            LSQRoutesCareplans(),
            LSQRoutesForms(),
            LSQRoutesLifesquare(),
            LSQRoutesNetworking(),
            LSQRoutesOnboarding(),
            LSQRoutesPatient(),
            LSQRoutesPatientNetwork(),
            LSQRoutesPermissions(),
            LSQRoutesProvider(),
            LSQRoutesTabs()
        ]
        )
        for router: LSQRouter in self.routers {
            router.addObservers()
        }
    }
    
    // no real reason to disconnect
    fileprivate func disconnectRouters(){
        for router: LSQRouter in self.routers {
            router.removeObservers()
        }
    }
    
    fileprivate func initializeThirdParties(){
        Fabric.with([Crashlytics.self])
        
        KeenClient.disableGeoLocationDefaultRequest()
        
        // THIS IS A DIRTY CHECK
        if LSQAPI.sharedInstance.api_root != LSQAPI.sharedInstance.release_api_root {
            // DEBUG / TEST / QA
            // TODO: move to API endpoint
            KeenClient.sharedClient(withProjectID: "",
                                    andWriteKey: "",
                                    andReadKey: ""
            )
            
            // TEST KEYs
            STPPaymentConfiguration.shared().publishableKey = ""
        } else {
            // PROD
            
            KeenClient.sharedClient(withProjectID: "",
                                    andWriteKey: "",
                                    andReadKey: ""
            )
            
            // PROD KEYs
            STPPaymentConfiguration.shared().publishableKey = ""
            // APPLE PAY SON
            // STPPaymentConfiguration.shared().appleMerchantIdentifier = "your apple merchant identifier"
        }
        
        let bundleObj1: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject?
        let build = bundleObj1 as! String
        let bundleObj2: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let version = bundleObj2 as! String
        
        LSQAPI.sharedInstance.setClientVersion(build: build, name: version)
        
        // also device token for push notifications
        // ok, yea, son
        /*
         if let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
         
         }
         */
        
        // well then
        KeenClient.shared().globalPropertiesDictionary = [
            "keen" : [
                "addons" : [
                    [
                        "name" : "keen:ua_parser",
                        "input" : [
                            "ua_string" : "user_agent"
                        ],
                        "output" : "parsed_user_agent"
                    ]
                    /*
                     [
                     "name" : "keen:ip_to_geo",
                     "input" : ["ip" : "ip_address"],
                     "output" : "ip_geo_info"
                     ]
                     */
                ]
            ],
            "user_agent": "${keen.user_agent}",
            "client_build": Int(build)!,
            "client_version": version,
            //"ip_address" : self.getIPAddress(true)
        ];
        
        
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
    }
    
    func analyticsTrackEvent(_ notification: Notification) {
        // in keen world, the event is the actual set of attributes
        let event = notification.userInfo!["event"]!
        var attributes = notification.userInfo!["attributes"]
        if attributes != nil {
        } else {
            attributes = ["PooClick": true]
        }
        try! KeenClient.shared().addEvent(attributes! as! [AnyHashable: Any], toEventCollection: event as! String)
        return;
    }
    
    // do the permissions module in here?? maybe?
    
    
}
