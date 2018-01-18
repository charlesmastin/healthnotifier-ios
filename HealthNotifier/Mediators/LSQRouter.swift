//
//  LSQNotificationRouter.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit

class LSQRouter : NSObject {
    
    internal var appDelegate: LSQAppDelegate = UIApplication.shared.delegate as! LSQAppDelegate
    
    var observationQueue: [AnyObject] = []
    
    // meh meh meh
    func addObservers(){
        // do nothing brolo
    }
    
    func removeObservers() {
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    deinit {
        self.removeObservers()
    }
    
    // MARK: Utils
    internal func attachRootVC(_ vc: AnyObject){
        // AIN'T GOT TIME FOR TRANSITIONS SON
        self.appDelegate.window?.makeKeyAndVisible()
        self.appDelegate.window?.rootViewController = vc as? UIViewController
    }
    /*
    // TODO: RETIRE
    internal func generateWindow() -> UIWindow {
        let newWindow: UIWindow = UIWindow.init(frame: UIApplication.shared.keyWindow!.bounds)
        newWindow.windowLevel = UIWindowLevelNormal + 1 // can't take risk of the login window   cli
        newWindow.backgroundColor = UIColor.white
        return newWindow
    }
     */
}
