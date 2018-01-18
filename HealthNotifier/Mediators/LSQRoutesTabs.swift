//
//  LSQRoutesTabs.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit

class LSQRoutesTabs : LSQRouter {
    
    internal var mainTabController: UITabBarController!
    internal var allTheTabs: [UIViewController] = []
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.tabController,
                object: nil,
                queue: OperationQueue.main,
                using: self.showTabController
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.tabPatients,
                object: nil,
                queue: OperationQueue.main,
                using: self.showTabPatients
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.configureTabs,
                object: nil,
                queue: OperationQueue.main,
                using: self.handleConfigureTabBar
            )
        )
        
        // TODO: move to the LSQBadgeManager??
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.badgeCountChange,
                object: nil,
                queue: OperationQueue.main,
                using: self.handleBadgeChange
            )
        )
        
    }
    
    func handleBadgeChange(_ notification: Notification?) {
        // we could check the source itself, but let's just look at the payload
        if let count:Int = notification?.userInfo!["count"] as? Int {
            if count > 0 {
                self.addPendingTab()
            } else {
                self.removePendingTab()
            }
        } else {
            self.removePendingTab()
        }
    }
    
    func showTabController(notification: Notification) {
        self.segueueToAuthenticatedUI()
    }
    
    func showTabPatients(notification: Notification) {
        // terriblly lame
        self.mainTabController.selectedIndex = 0
    }
        
    func handleConfigureTabBar(notification: Notification) {
        self.configureTabBar()
    }
    
    // FML
    internal func segueueToAuthenticatedUI(){
        //!!!!!!!!!!!!
        LSQOnboardingManager.sharedInstance.reset()
        LSQAppearanceManager.sharedInstance.reset()// meh zone
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc: UITabBarController = sb.instantiateViewController(withIdentifier: "MainTabs") as! UITabBarController
        self.attachRootVC(vc)
        self.mainTabController = vc
        // be damn sure this is a copy and not a reference
        self.allTheTabs = self.mainTabController.viewControllers!
        self.configureTabBar() // determine pending though bro here
        // which should also
    }
    
    internal func addPendingTab() {
        // meh, but only do this if we're currently in the uhh, umm authenticated UI
        if self.mainTabController != nil {
            self.configureTabBar()
            for tab in self.mainTabController.tabBar.items! {
                if tab.tag == 3 {
                    tab.badgeValue = String(LSQBadgeManager.sharedInstance.count)
                }
            }
        }
    }
    
    internal func removePendingTab() {
        // non-op
        self.configureTabBar()
    }
    
    // handle on tab change though
    // but actually only show this on the specific top level view / render of patientsViewController, aka backing all the way out though
    //
    
    internal func configureTabBar() {
        var authorizedViewControllers: [UIViewController] = []
        // TODO: be damn sure we're gonna order the tabs correctly, this is problematic and
        // based on the original storyboard arrangements
        // at this rate, might as well just do it all in code :)
        for vc:UIViewController in self.allTheTabs {
            if let vcf = vc.childViewControllers.first {
                if vcf.isKind(of: LSQPatientsViewController.self) {
                    authorizedViewControllers.append(vc)
                }
                if vcf.isKind(of: LSQInboxViewController.self) {
                    // and we have notifications? whaaaat?
                    if LSQBadgeManager.sharedInstance.count > 0 {
                        authorizedViewControllers.append(vc)
                    }
                }
                if vcf.isKind(of: LSQScanViewController.self) {
                    authorizedViewControllers.append(vc)
                }
                if vcf.isKind(of: LSQAccountViewController.self) {
                    authorizedViewControllers.append(vc)
                }
                if vcf.isKind(of: LSQNearbyViewController.self) {
                    if LSQUser.currentUser.provider {
                        authorizedViewControllers.append(vc)
                    }
                }
                if vcf.isKind(of: LSQHistoryViewController.self) {
                    if LSQUser.currentUser.provider {
                        authorizedViewControllers.append(vc)
                    }
                }
            }
            
            
            // assign back to the tabs yo
            self.mainTabController.viewControllers = authorizedViewControllers
            
            // apply dat method son
            (self.mainTabController as? LSQTabsController)?.customizeDemTabsSon()
        }
    }
}
