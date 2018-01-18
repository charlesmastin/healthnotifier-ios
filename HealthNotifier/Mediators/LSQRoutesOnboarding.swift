//
//  LSQRoutesOnboarding.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQRoutesOnboarding : LSQRouter {
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.welcome,
                object: nil,
                queue: OperationQueue.main,
                using: self.showWelcomeScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingAccount,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingAccountScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingLicense,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingLicenseScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.licenseCaptured,
                object: nil,
                queue: OperationQueue.main,
                using: self.segueueOnboardingLicenseToProfileScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingProfile,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingProfileScreen
            )
        )
        
        // alt entry point
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.createPatientOnboarding,
                object: nil,
                queue: OperationQueue.main,
                using: self.createPatientOnboarding
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingPhoto,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingPhotoScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingScanLifesquare,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingScanLifesquareScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingContacts,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingContactsScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingInsurance,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingInsuranceScreen
            )
        )
    
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingMedical,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingMedicalScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingPromo,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingPromoScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingConfirm,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingConfirmScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.terms,
                object: nil,
                queue: OperationQueue.main,
                using: self.showTermsScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.privacy,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPrivacyScreen
            )
        )
        
        // TODO: retire from UX
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.profileConfirm,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPatientScreenConfirm
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.checkout,
                object: nil,
                queue: OperationQueue.main,
                using: self.showCheckoutScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.checkoutSuccess,
                object: nil,
                queue: OperationQueue.main,
                using: self.showCheckoutSuccessScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.onboardingSuccess,
                object: nil,
                queue: OperationQueue.main,
                using: self.showOnboardingSuccessScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.enablePush,
                object: nil,
                queue: OperationQueue.main,
                using: self.showEnablePushScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.scanImport,
                object: nil,
                queue: OperationQueue.main,
                using: self.showScanImportScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.nextOnboardingStep,
                object: nil,
                queue: OperationQueue.main,
                using: self.nextOnboardingStep
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.prevOnboardingStep,
                object: nil,
                queue: OperationQueue.main,
                using: self.prevOnboardingStep
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.skipOnboardingStep,
                object: nil,
                queue: OperationQueue.main,
                using: self.skipOnboardingStep
            )
        )
        
        // TODO: retire or move to higher level though?
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.continueSetup,
                object: nil,
                queue: OperationQueue.main,
                using: self.continueSetup
            )
        )
    }
    
    // TODO: actual presentation logic and class doe
    func showWelcomeScreen(notification: Notification) {
        LSQOnboardingManager.sharedInstance.reset()
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQWelcomeViewController = sb.instantiateViewController(withIdentifier: "WelcomeViewController") as! LSQWelcomeViewController
        
        self.attachRootVC(UINavigationController(rootViewController: vc))
        
        /*
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
        */
    }
    
    func showOnboardingAccountScreen(notification: Notification) {
        // for our 2 entry points
        LSQOnboardingManager.sharedInstance.begin()
        LSQAppearanceManager.sharedInstance.underlinedInputs = true
        LSQAppearanceManager.sharedInstance.activateThemeAuth()
        
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingAccountViewController = sb.instantiateViewController(withIdentifier: "OnboardingAccountViewController2") as! LSQOnboardingAccountViewController
        if notification.userInfo?["email"] != nil {
            vc.textEmail?.text = notification.userInfo!["email"] as? String
        }
        
        //
        let pvc: UIViewController = notification.object as! UIViewController
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
        /*
        if pvc.isEmbeded {
            self.attachRootVC(UINavigationController(rootViewController: vc))
        } else {
            // XXX: this is using the fancy extension from SO, the block is the completion callback
            pvc.navigationController?.pushViewController(vc, animated: true) {
                
            }
        }
        */
    }
    
    func showTermsScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQTermsViewController = sb.instantiateViewController(withIdentifier: "TermsViewController") as! LSQTermsViewController
        let pvc: UIViewController = notification.object as! UIViewController
        
        // look if we're
        
        if pvc.isEmbeded {
            pvc.navigationController?.pushViewController(vc, animated: true) {
                // vc.title = (notification.userInfo!["collectionId"] as? String)!
                // pass in da object if we's haszz it
            }
        } else {
            let navigationController = UINavigationController(rootViewController: vc)
            pvc.present(navigationController, animated: true, completion: {
                //
            })
        }
    }
    
    func showPrivacyScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQTermsViewController = sb.instantiateViewController(withIdentifier: "TermsViewController") as! LSQTermsViewController
        let pvc: UIViewController = notification.object as! UIViewController
        
        // look if we're
        
        if pvc.isEmbeded {
            pvc.navigationController?.pushViewController(vc, animated: true) {
                // vc.title = (notification.userInfo!["collectionId"] as? String)!
                // pass in da object if we's haszz it
                vc.showTab(index: 1)
            }
        } else {
            let navigationController = UINavigationController(rootViewController: vc)
            pvc.present(navigationController, animated: true, completion: {
                //
                vc.showTab(index: 1)
            })
        }
    }
    
    func showOnboardingLicenseScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingLicenseViewController = sb.instantiateViewController(withIdentifier: "OnboardingLicenseViewController") as! LSQOnboardingLicenseViewController
        self.attachRootVC(UINavigationController(rootViewController: vc))
    }
    
    func segueueOnboardingLicenseToProfileScreen(notification: Notification) {
        // close the license modal
        (notification.object! as! UIViewController).dismiss(animated: true, completion: {
            // ugggg, find the vc which logically is just the previous in the navigation stack lolzin
            // HOLY COW THIS COULD BE A HORRIBLE IDEA THOUGH BROLO
            //print(self.appDelegate.window?.rootViewController)
            //print(self.appDelegate.window?.rootViewController?.navigationController?)
//            if self.appDelegate.window?.rootViewController?.navigationController?.topViewController != nil {
//                // ghetto to da max brolo
//                let vc = (self.appDelegate.window?.rootViewController?.navigationController?.topViewController as! LSQOnboardingProfileViewController)
//                vc.importedJson = JSON((notification.userInfo?["data"])!)
//                vc.populateWithJson(json: vc.importedJson!)
//                print("OH BROTHER")
//            }
            // THIS IS BAD AND SO BAD AND YOU KNOW IT
            let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
            let vc:LSQOnboardingProfileViewController = sb.instantiateViewController(withIdentifier: "OnboardingProfileViewController2") as! LSQOnboardingProfileViewController
            vc.importedJson = JSON((notification.userInfo?["data"])!)
            // this is all wrong
            self.attachRootVC(UINavigationController(rootViewController: vc))
            
            // timeout, ghetto max edition this is so wrong though brolo, as we need to simply manage the up and down from within
            //_ = setTimeout(0.5, block: { () -> Void in
                
            //})
            //vc.populateWithJson(json: JSON((notification.userInfo?["data"])!))
        })
        // cycle the view controllers
        // data to onboarding singleton data store
        // pass data
    }
    
    func createPatientOnboarding(notification: Notification) {
        // zero out patient manager
        // transition ui
        // meh
        // TODO: meh initial mounting
        LSQPatientManager.sharedInstance.reset()
        NotificationCenter.default.post(
            name: LSQ.notification.show.onboardingProfile,
            object: notification.object,
            userInfo: nil
        )
    }
    
    func showOnboardingProfileScreen(notification: Notification) {
        LSQOnboardingManager.sharedInstance.begin()
        // and toned so we can render them son
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        LSQAppearanceManager.sharedInstance.underlinedInputs = true // jump start son
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingProfileViewController = sb.instantiateViewController(withIdentifier: "OnboardingProfileViewController2") as! LSQOnboardingProfileViewController
        let pvc: UIViewController = notification.object as! UIViewController
        
        // ENTRY POINTS BRO
        if pvc.isEmbeded {
            // XXX: this is using the fancy extension from SO, the block is the completion callback
            
            
            // ok, instead modal preset brolo
            /*
            pvc.navigationController?.pushViewController(vc, animated: true) {
                
            }
             */
            let navigationController = UINavigationController(rootViewController: vc)
            pvc.present(navigationController, animated: true, completion: {
                //vc.loadData(documentId, fileIndex: fileIndex!)
            })
        } else {
            self.attachRootVC(UINavigationController(rootViewController: vc))
        }
    }
    
    func showOnboardingPhotoScreen(notification: Notification) {
        
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingPhotoViewController = sb.instantiateViewController(withIdentifier: "OnboardingPhotoViewController") as! LSQOnboardingPhotoViewController
        //
        //self.attachRootVC(UINavigationController(rootViewController: vc))
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    func showOnboardingScanLifesquareScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingScanLifesquareViewController = sb.instantiateViewController(withIdentifier: "OnboardingScanLifesquareViewController") as! LSQOnboardingScanLifesquareViewController
        //self.attachRootVC(UINavigationController(rootViewController: vc))
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    func showOnboardingContactsScreen(notification: Notification) {
        // JUMP START HACK ON embedVC rendering lifecycle, ugggggg uggg
        
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        LSQAppearanceManager.sharedInstance.underlinedInputs = false
        LSQAppearanceManager.sharedInstance.cellSeparatorColor = UIColor.white.withAlphaComponent(0.2)
        
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingContactsViewController = sb.instantiateViewController(withIdentifier: "OnboardingContactsViewController") as! LSQOnboardingContactsViewController
        //self.attachRootVC(UINavigationController(rootViewController: vc))
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        /*
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
        */
        
        if notification.userInfo != nil {
            if notification.userInfo!["resume"] != nil {
                vc.resumed = true
                let navigationController = UINavigationController(rootViewController: vc)
                // only do this is we're launching in though brolo as an entry point though, mmmkay
                
                // LALLALALALALALALALALALAL - aka
                pvc.present(navigationController, animated: true, completion: {
                    //vc.loadData(documentId, fileIndex: fileIndex!)
                    // create an Exit Setup flow action brolo
                })
            }
        } else {
            // only valid case is coming from previous scope bro
            vc.resumed = true
            // just force it though lololo
            // CUT IT OFF
            pvc.navigationController?.pushViewController(vc, animated: true) {
                
            }
        }
        /*
        // CUT OFF THIN RED LINE
        
        if pvc.isEmbeded {
            // XXX: this is using the fancy extension from SO, the block is the completion callback
            
            vc.resumed = true
            let navigationController = UINavigationController(rootViewController: vc)
            // only do this is we're launching in though brolo as an entry point though, mmmkay
            
            // LALLALALALALALALALALALAL - aka
            pvc.present(navigationController, animated: true, completion: {
                //vc.loadData(documentId, fileIndex: fileIndex!)
                // create an Exit Setup flow action brolo
            })
            // ok, instead modal preset brolo
            /*
             pvc.navigationController?.pushViewController(vc, animated: true) {
             
             }
             */
            
        } else {
            pvc.navigationController?.pushViewController(vc, animated: true) {
                
            }
            //self.attachRootVC(UINavigationController(rootViewController: vc))
        }
         */
    }
    
    func showOnboardingInsuranceScreen(notification: Notification) {
        
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingInsuranceViewController = sb.instantiateViewController(withIdentifier: "OnboardingInsuranceViewController") as! LSQOnboardingInsuranceViewController
        //self.attachRootVC(UINavigationController(rootViewController: vc))
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    func showOnboardingMedicalScreen(notification: Notification) {
        
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingMedicalViewController = sb.instantiateViewController(withIdentifier: "OnboardingMedicalViewController2") as! LSQOnboardingMedicalViewController
        //self.attachRootVC(UINavigationController(rootViewController: vc))
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    func showOnboardingPromoScreen(notification: Notification) {
        
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingPromoViewController = sb.instantiateViewController(withIdentifier: "OnboardingPromoViewController") as! LSQOnboardingPromoViewController
        //self.attachRootVC(UINavigationController(rootViewController: vc))
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    func showOnboardingConfirmScreen(notification: Notification) {
        // kick it off though
        
        
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQOnboardingConfirmViewController = sb.instantiateViewController(withIdentifier: "OnboardingConfirmViewController") as! LSQOnboardingConfirmViewController
        //self.attachRootVC(UINavigationController(rootViewController: vc))
        
        // if if if if if if if if if if if if if if if if
        if notification.userInfo != nil {
            if notification.userInfo!["legacy"] != nil {
                vc.legacy = true
            }
        }
        
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    // MARK: Registration
    
    func showEnablePushScreen(notification: Notification) {
        
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:UIViewController = sb.instantiateViewController(withIdentifier: "OnboardingEnablePushViewController")
        //self.attachRootVC(UINavigationController(rootViewController: vc))
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    func showOnboardingSuccessScreen(notification: Notification) {
        
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:UIViewController = sb.instantiateViewController(withIdentifier: "OnboardingSuccessViewController")
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
        //self.attachRootVC(UINavigationController(rootViewController: vc))
    }
    
    func showScanImportScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQScanImportViewController = sb.instantiateViewController(withIdentifier: "ScanImportViewController") as! LSQScanImportViewController
        let pvc: UIViewController = notification.object as! UIViewController
        
        let navigationController = UINavigationController(rootViewController: vc)
        pvc.present(navigationController, animated: true, completion: {
            //vc.loadData(documentId, fileIndex: fileIndex!)
        })
    }
    
    // TODO: retire or consolidate pattern of closing VC
    func hideScanImportScreen(notification: Notification){
        // CRASH CENTRAL DOT COM
        (notification.object! as! UIViewController).dismiss(animated: true, completion: nil)
        //(notification.object! as AnyObject).navigationController?!.popViewController(animated: true)
    }
    
    func showPatientScreenConfirm(notification: Notification) {
        // TODO: this screen is cut basically anyhow
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQConfirmViewController = sb.instantiateViewController(withIdentifier: "ConfirmViewController") as! LSQConfirmViewController
        vc.data = LSQPatientManager.sharedInstance.json!
        let pvc: UIViewController = notification.object as! UIViewController
        pvc.navigationController?.pushViewController(vc, animated:true)
        // TODO: ANALYTICS SON
        
    }
    
    func showCheckoutScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        
        // lolzin brolo
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = nil
        
        let vc:LSQCheckoutViewController = sb.instantiateViewController(withIdentifier: "CheckoutViewController") as! LSQCheckoutViewController
        vc.mode = (notification.userInfo!["mode"]! as? String)!
        vc.patients = [LSQPatientManager.sharedInstance.json!] // WTF bro
        
        //
        // balls on balls, these should not bleed, and should be reset when onboarding concludes doe
        //
        if LSQOnboardingManager.sharedInstance.claimedLifesquare != nil {
            vc.lifesquareCode = LSQOnboardingManager.sharedInstance.claimedLifesquare!
            vc.lifesquareValid = true
            vc.assignMethod = "claim"
        } else {
            vc.assignMethod = "new"
        }
        if LSQOnboardingManager.sharedInstance.promoCode != nil {
            vc.promoCode = LSQOnboardingManager.sharedInstance.promoCode!
            vc.promoValid = true
        }
        
        vc.doubleSecretInit()
        
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
    }
    
    func showCheckoutSuccessScreen(notification: Notification) {
        let pvc: UIViewController = notification.object as! UIViewController
        
        if LSQOnboardingManager.sharedInstance.active {
            
            //
            // show confirm screen bro, which is slightly misleading though
            //
            NotificationCenter.default.post(
                name: LSQ.notification.action.nextOnboardingStep,
                object: pvc,
                userInfo: nil
            )
            
        } else {
            pvc.navigationController?.popToRootViewController(animated: true)
        }
        
        // let's be honest, we don't need this, because everyone has email on their phones, and they get push email for the most part
        _ = setTimeout(0.5, block: { () -> Void in
            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                preferredStyle = UIAlertControllerStyle.actionSheet
            }
            let alert: UIAlertController = UIAlertController(
                title: "Checkout Success!",
                message: "Please check your email for details",
                preferredStyle: preferredStyle)
            
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
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
            // issue the event to reload patients collection bro
            NotificationCenter.default.post(
                name: LSQ.notification.hacks.reloadPatients,
                object: nil,
                userInfo: nil
            )
        })
    }
    
    func nextOnboardingStep(notification: Notification){
        self.transitionOnboarding(notification:notification, advance: true)
    }
    
    func skipOnboardingStep(notification: Notification){
        self.transitionOnboarding(notification:notification, advance: true, skip: true)
    }
    
    func prevOnboardingStep(notification: Notification){
        self.transitionOnboarding(notification:notification, advance: false)
    }
    
    internal func transitionOnboarding(notification: Notification, advance: Bool = true, skip: Bool = false){
        
        // TEMP NO CRASH SPECIAL BRO
        // TEMP TEMP TEMP TEMP TEMP TEMP TEMP
        if LSQPatientManager.sharedInstance.uuid == nil {
            LSQPatientManager.sharedInstance.uuid = "DONKEY"
        } else {
            // this is dumb
        }
        
        // this is our massive sequence router, lolzin, based mostly on "from" or the instance of the class, bro in the object, yea son
        // switch on our from class instance, then look at advance, aka direction if necessary, and skip, if whatever, for whatever reason
        // NOTE: all data transactions are done in VC before sending this, it is safe to proceed if this is called (ish).
        if notification.object is LSQOnboardingAccountViewController {
            // only forward bro, and resend the existing screen so we can transition the beef in da futures son
            NotificationCenter.default.post(
                name: LSQ.notification.show.onboardingProfile,
                object: notification.object,
                userInfo: nil
            )
        }
        
        if notification.object is LSQOnboardingLicenseViewController {
            // only forward bro, and resend the existing screen so we can transition the beef in da futures son
            NotificationCenter.default.post(
                name: LSQ.notification.show.onboardingProfile,
                object: notification.object,
                userInfo: nil
            )
        }
        
        if notification.object is LSQOnboardingProfileViewController {
            // only forward bro, and resend the existing screen so we can transition the beef in da futures son
            NotificationCenter.default.post(
                name: LSQ.notification.show.onboardingPhoto,
                object: notification.object,
                userInfo: nil
            )
        }
        
        if notification.object is LSQOnboardingPhotoViewController {
            // only forward bro, and resend the existing screen so we can transition the beef in da futures son
            NotificationCenter.default.post(
                name: LSQ.notification.show.onboardingContacts,
                object: notification.object,
                userInfo: nil
            )
        }
        
        if notification.object is LSQOnboardingContactsViewController {
            // only forward bro, and resend the existing screen so we can transition the beef in da futures son
            // TODO: enable this though brolo, as we don't have an API for this now
            //
//            NotificationCenter.default.post(
//                name: LSQ.notification.show.onboardingInsurance,
//                object: notification.object,
//                userInfo: nil
//            )
            NotificationCenter.default.post(
                name: LSQ.notification.show.onboardingMedical,
                object: notification.object,
                userInfo: nil
            )
        }
        
        if notification.object is LSQOnboardingInsuranceViewController {
            // only forward bro, and resend the existing screen so we can transition the beef in da futures son
            NotificationCenter.default.post(
                name: LSQ.notification.show.onboardingMedical,
                object: notification.object,
                userInfo: nil
            )
        }
        
        if notification.object is LSQOnboardingMedicalViewController {
            // only forward bro, and resend the existing screen so we can transition the beef in da futures son
            NotificationCenter.default.post(
                name: LSQ.notification.show.onboardingScanLifesquare,
                object: notification.object,
                userInfo: nil
            )
        }
        
        if notification.object is LSQOnboardingScanLifesquareViewController {
            var paymentRequired: Bool = false
            if LSQOnboardingManager.sharedInstance.amountDue > 0 {
                paymentRequired = true
            }
            if paymentRequired {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.onboardingPromo,
                    object: notification.object,
                    userInfo: nil
                )
            } else {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.onboardingConfirm,
                    object: notification.object,
                    userInfo: nil
                )
            }
        }
        
        if notification.object is LSQOnboardingPromoViewController {
            // only forward bro, and resend the existing screen so we can transition the beef in da futures son
            // also calculate if we need push or simply success brobass haus
            // this would be living in the onboarding manager hopefully yea son as a calculated result of previous API calls
            var paymentRequired: Bool = false
            
            if LSQOnboardingManager.sharedInstance.amountDue > 0 {
                // TODO: re-enable as time permits
                paymentRequired = true
            }
            
            if paymentRequired {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.checkout,
                    object: notification.object,
                    userInfo: [
                        "mode": "assign"
                    ]
                )
            } else {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.onboardingConfirm,
                    object: notification.object,
                    userInfo: nil
                )
                /*
                // we still need to assign though… aka claim our shizzle nizzle
                print("CLAIM OUR SQUARES NOW BASICALLY")
                // which honestly we could do on the promo code screen
                
                if LSQ.permissions.checkPermissionNotifications() {
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.onboardingSuccess,
                        object: notification.object,
                        userInfo: nil
                    )
                } else {
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.enablePush,
                        object: notification.object,
                        userInfo: nil
                    )
                }
                 */
            }
        }
        
        if notification.object is LSQOnboardingConfirmViewController {
            // only if we're in onboarding and only if push is not currently enabled though brosef brobass bronuts
            if LSQ.permissions.checkPermissionNotifications() {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.onboardingSuccess,
                    object: notification.object,
                    userInfo: nil
                )
            } else {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.enablePush,
                    object: notification.object,
                    userInfo: nil
                )
            }
        }
        
        // now we go forth brolo and calculate things on things on things
        if notification.object is LSQCheckoutViewController {
            
            // the ONLY reason this should happen is if we needed to organically checkout… so show the confirm screen, what evs
            NotificationCenter.default.post(
                name: LSQ.notification.show.onboardingConfirm,
                object: notification.object,
                userInfo: [
                    "legacy": true
                ]
            )
            /*
            // only if we're in onboarding and only if push is not currently enabled though brosef brobass bronuts
            if LSQ.permissions.checkPermissionNotifications() {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.onboardingSuccess,
                    object: notification.object,
                    userInfo: nil
                )
            } else {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.enablePush,
                    object: notification.object,
                    userInfo: nil
                )
            }
             */
        }
        
        if notification.object is LSQEnablePushViewController {
            // only forward bro, and resend the existing screen so we can transition the beef in da futures son
            NotificationCenter.default.post(
                name: LSQ.notification.show.onboardingSuccess,
                object: notification.object,
                userInfo: nil
            )
        }
        
        if notification.object is LSQOnboardingSuccessViewController {
            
            // RESUME OUR CLASSIC UI LOOK AND FEEL BRO
            LSQAppearanceManager.sharedInstance.reset()
            
            // TODO: transition to tab UI, and ideally though, zone in on the new patient brolo, single user UX, blabla
            NotificationCenter.default.post(
                name: LSQ.notification.show.tabController,
                object: notification.object,
                userInfo: nil
            )
        }
        
        // loop town
        
    }
    
    func continueSetup(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let next = userInfo["next"] {
                if next as! String == "editPersonal" {
                    // look at legacy codebasae if you ever want this behavior again, but likely you don't
                }
            } else {
                // no next but blbla
            }
        }
        
        // assume an instance to introspect, or we have to load and check where / what to do next
        if LSQPatientManager.sharedInstance.json != nil {
            let patient = LSQPatientManager.sharedInstance.json!
            // hahahahahahahahahahahahaha upgrade you son
            var onboardingState: String = patient["meta"]["onboarding_state"].string!
            let vc = notification.object as! UIViewController
            print(onboardingState)
            if onboardingState == "ONBOARDING_COMPLETE" {
                print("DA F")
                //self.onboarding = false
                //self.showPatientScreen(patient)
                // this should do nothing
            }else {
                //self.onboarding = true
                // where do we go based on the state
                
                // TODO: TEMP UPGRADE YOUR STATUS CHECK UNTIL WE UPDATE THE BACKEND APIs
                
                // do we have firstname, lastname, birthdate
                //if residences.count > 0 && patient.first_name != '' && patient.last_name != '' && patient.birthdate != nil && patient.birthdate.to_s != "01/01/0001 00:00:00"
                //return 'personal'
                //end
                if onboardingState == "account" {
                    // crash worthy bro
                    if let firstname = patient["profile"]["first_name"].string {
                        if firstname != "" {
                            if let lastname = patient["profile"]["last_name"].string {
                                if lastname != "" {
                                    if let birthdate = patient["profile"]["birthdate"].string {
                                        if birthdate != "" && birthdate != "0001-01-01" {
                                            // upgrade you son
                                            onboardingState = "personal"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                if onboardingState == "lifesquare" {
                    //hmm yup, not sure
                    // renewal brobass
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.checkout,
                        object: vc as UIViewController,
                        userInfo: [
                            "mode": "renew",
                        ]
                    )
                }
                // ok gotta check the in-betweener here
                if onboardingState == "confirm" {
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.checkout,
                        object: vc as UIViewController,
                        userInfo: [
                            "mode": "assign",
                        ]
                    )
                }
                
                // ok, lump all dis in the general free-form Onboarding with resume state bro! bas sauce facs
                // it's mmmm kay if you skip it though, maybe though, hahah
                // THESE ALL NEED TO LAUNCH MODALLY THOUGH MY BRO BASS BOSS SAUCE NUTS…
                // consider an easy hack to determine this without explicitly passing something
                if onboardingState == "emergency" {
                    //TODO: wire emergency view
                    LSQOnboardingManager.sharedInstance.begin()
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.onboardingContacts,
                        object: vc as UIViewController,
                        userInfo: [
                            "resume": true
                        ]
                    )
                }
                if onboardingState == "medical" {
                    LSQOnboardingManager.sharedInstance.begin()
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.onboardingContacts,
                        object: vc as UIViewController,
                        userInfo: [
                            "resume": true
                        ]
                    )
                }
                if onboardingState == "personal" {
                    LSQOnboardingManager.sharedInstance.begin()
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.onboardingContacts,
                        object: vc as UIViewController,
                        userInfo: [
                            "resume": true
                        ]
                    )
                }
                // relaunches of the app first time run should capture this, hmm kay
                if onboardingState == "account" {
                    // MEH this should never happen though brolo… but in case it does !!!!, hmmm hmm hmm hmm hmm hmm. Dead end edition bro
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.profileEditPersonal,
                        object: vc as UIViewController,
                        userInfo: nil
                    )
                }
            }
        }
        
    }
}
