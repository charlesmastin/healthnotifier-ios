//
//  LSQRoutesLifesquare.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQRoutesLifesquare : LSQRouter {
    
    override func addObservers(){
        
        // TODO: move to lifesquare bro
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.lifesquare,
                object: nil,
                queue: OperationQueue.main,
                using: self.loadPatientFromLifesquare
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.patientFragment,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPatientFragmentScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.captureLifesquareCode,
                object: nil,
                queue: OperationQueue.main,
                using: self.showCaptureLifesquareCodeScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.dismiss.captureLifesquareCode,
                object: nil,
                queue: OperationQueue.main,
                using: self.dismissCaptureLifesquareCodeScreen// here goes nothing son
            )
        )
        
        // TODO: move to lifesquare
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.scanCodeEntry,
                object: nil,
                queue: OperationQueue.main,
                using: self.showScanCodeEntryScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.document,
                object: nil,
                queue: OperationQueue.main,
                using: self.showDocumentScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.patientPhoto,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPatientPhotoScreen
            )
        )
    }
    
    func loadPatientFromLifesquare(notification: Notification) {
        
        // TODO: meh
        LSQAppearanceManager.sharedInstance.reset()
        
        if notification.userInfo!["lifesquare"] != nil {
            // scan & code entry
            // first call, just to get the patientId, except use our new versioning, and we can instead
        }
        if notification.userInfo!["patientId"] != nil {
            // this is when we have previously scanned, history, or a network connection
            // load patient with callback
            let uuid = (notification.userInfo!["patientId"] as! String)
            var force: Bool = false
            if notification.userInfo!["reload"] != nil {
                force = true
            }
            if LSQPatientManager.sharedInstance.uuid != uuid || force {
                LSQPatientManager.sharedInstance.uuid = uuid
                LSQPatientManager.sharedInstance.fetchWithCallbacks(
                    success: { response in
                        self.renderLifesquareScreen(notification.object as! UIViewController, patient: LSQPatientManager.sharedInstance.json!)
                    },
                    failure: { response in
                    }
                )
            } else {
                // ugg, here's where we needs to refresh our sizzle
                self.renderLifesquareScreen(notification.object as! UIViewController, patient: LSQPatientManager.sharedInstance.json!)
            }
            
            /*
             LSQAPI.sharedInstance.loadPatientWithCallbacks(
             (notification.userInfo!["patientId"] as? String)!,
             success: { response in
             let p: JSON = JSON(response)
             if p["meta"]["owner"].boolValue {
             //YUP TOO CONFUSING, and mounting in the wrong place, etc
             // self.renderPatientScreen(notification.object as! UIViewController, patient: p)
             self.renderLifesquareScreen(notification.object as! UIViewController, patient: p)
             } else {
             self.renderLifesquareScreen(notification.object as! UIViewController, patient: p)
             }
             },
             failure: { response in
             self.patientLoadFailure(notification.object as! UIViewController)
             }
             )
             */
        }
        // no longer in use really though
        /*
         if notification.userInfo!["patientInstance"] != nil {
         // this is when when we want to view it ourself, but passed through the messaging, vs a direct method call
         self.renderLifesquareScreen(notification.object as! UIViewController, patient: JSON(notification.userInfo!["patientInstance"]!))
         }
         */
    }
    
    // called in multiple contexts
    internal func renderLifesquareScreen(_ pvc: UIViewController, patient: JSON) {
        
        let sb:UIStoryboard = UIStoryboard(name:"Lifesquare", bundle:nil)
        let vc:LSQLifesquareViewController = sb.instantiateViewController(withIdentifier: "LifesquareViewController") as! LSQLifesquareViewController
        vc.data = patient
        let navigationController = UINavigationController(rootViewController: vc)
        let rvc = self.appDelegate.window!.rootViewController        // this is not needed
        if let cvc:UIViewController = getCurrentViewController(rvc!) {
            cvc.present(navigationController, animated: true, completion: {
            })
        }
        
        
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "Patient View",
                "attributes": [
                    "AccountId": LSQUser.currentUser.uuid!,
                    "Provider": LSQUser.currentUser.provider,
                    "PatientId": patient["profile"]["uuid"].string!
                ]
            ]
        )
    }
    
    func showPatientFragmentScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Lifesquare", bundle:nil)
        let pvc: UIViewController = notification.object as! UIViewController
        
        // TODO: ALL OF THESE MOVE TO JSON blablabro
        
        // var vc: UIViewController = nil
        let type: String = (notification.userInfo!["type"] as? String)!
        if type == "emergency" {
            let vc:LSQEmergencyContactViewController = sb.instantiateViewController(withIdentifier: "EmergencyContactViewController") as! LSQEmergencyContactViewController
            // this will become a generic mapping, and dry'd up to setter in the VC
            vc.tableDataInit(JSON(notification.userInfo!["data"]! as AnyObject))
            pvc.navigationController?.pushViewController(vc, animated:true)
        }
        if type == "insurances" {
            let vc:LSQInsuranceViewController = sb.instantiateViewController(withIdentifier: "InsuranceViewController") as! LSQInsuranceViewController
            vc.tableDataInit(JSON(notification.userInfo!["data"]! as AnyObject))
            pvc.navigationController?.pushViewController(vc, animated:true)
        }
        if type == "hospitals" {
            let vc:LSQHospitalViewController = sb.instantiateViewController(withIdentifier: "HospitalViewController") as! LSQHospitalViewController
            vc.tableDataInit(JSON(notification.userInfo!["data"]! as AnyObject))
            pvc.navigationController?.pushViewController(vc, animated:true)
        }
        if type == "pharmacies" {
            // OVERLOAD THE HOSPITAL GUY, since it has the same exact data
            let vc:LSQHospitalViewController = sb.instantiateViewController(withIdentifier: "HospitalViewController") as! LSQHospitalViewController
            vc.tableDataInit(JSON(notification.userInfo!["data"]! as AnyObject))
            vc.title = "Pharmacy"
            pvc.navigationController?.pushViewController(vc, animated:true)
        }
        if type == "care_providers" {
            // OVERLOAD THE HOSPITAL GUY, since it has the same exact data
            let vc:LSQHospitalViewController = sb.instantiateViewController(withIdentifier: "HospitalViewController") as! LSQHospitalViewController
            vc.tableDataInit(JSON(notification.userInfo!["data"]! as AnyObject))
            vc.title = "Physician"
            pvc.navigationController?.pushViewController(vc, animated:true)
        }
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "Patient Details View",
                "attributes": [
                    "Scope": type,
                    "AccountId": LSQUser.currentUser.uuid!,
                    "Provider": LSQUser.currentUser.provider,
                    "PatientId": (notification.userInfo!["patient_id"] as? String)! // TODO: sort it son
                ]
            ]
        )
        
    }
    
    func showPatientPhotoScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Lifesquare", bundle:nil)
        let vc:LSQProfilePhotoViewController = sb.instantiateViewController(withIdentifier: "ProfilePhotoViewController") as! LSQProfilePhotoViewController
        
        
        let navigationController = UINavigationController(rootViewController: vc)
        guard let rvc = self.appDelegate.window!.rootViewController else {
            return
        }
        let url: String = (notification.userInfo?["URL"] as? String)!
        if let cvc:UIViewController = getCurrentViewController(rvc) {
            cvc.present(navigationController, animated: true, completion: {
                // vc.loadData(documentId, fileIndex: fileIndex!)
                vc.loadImage(url)
            })
        }
    }
    
    func showDocumentScreen(notification: Notification) {
        let tA = URL(string:(notification.userInfo!["URL"])! as! String)!.absoluteString.components(separatedBy: "/")
        let documentId = tA[tA.count - 2]
        let fileIndex = tA.last
        // TODO: pass through the title
        // otherwise we need an endpoint that describes a DD know what I'm sayin
        // that probably makes sense anyhow, consider yourself considered
        let sb:UIStoryboard = UIStoryboard(name:"Lifesquare", bundle:nil)
        let vc:LSQDocumentViewController = sb.instantiateViewController(withIdentifier: "DocumentViewController") as! LSQDocumentViewController
        // TODO: viewing in the Lifesquare only context bro, it's going to be "wrong" ish? maybe
        // TODO: Lifesquare view has a strange context though, from a scan,
        // case would be viewing LifeCircle member from inside your Patient, then this document, FAILZONE
        // FIXME: fix it
        vc.patientId = LSQPatientManager.sharedInstance.uuid!
        
        let navigationController = UINavigationController(rootViewController: vc)
        guard let rvc = self.appDelegate.window!.rootViewController else {
            return
        }
        if let cvc:UIViewController = getCurrentViewController(rvc) {
            // cvc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            cvc.present(navigationController, animated: true, completion: {
                vc.loadData(documentId, fileIndex: fileIndex!)
            })
        }
    }
    
    
    func showCaptureLifesquareCodeScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQScanViewController = sb.instantiateViewController(withIdentifier: "CaptureLifesquareCodeViewController") as! LSQScanViewController
        vc.captureMode = true
        let pvc: UIViewController = notification.object as! UIViewController
        let navigationController = UINavigationController(rootViewController: vc)
        pvc.present(navigationController, animated: true, completion: {
    
        })
    }
    
    // TODO: retire or consolidate pattern of closing VC
    func dismissCaptureLifesquareCodeScreen(notification: Notification) {
        (notification.object! as AnyObject).dismiss(animated: true, completion: nil)
    }
    
    func showScanCodeEntryScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let vc:LSQCodeEntryViewController = sb.instantiateViewController(withIdentifier: "CodeEntryViewController") as! LSQCodeEntryViewController
        // FML
        vc.hackPresentingViewController = (notification.object as? UIViewController)!
        
        if let captureMode: Bool = (notification.userInfo!["capture"] as? Bool) {
            if captureMode {
                vc.captureMode = true
            }
        }
        // TODO: analytics
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            // vc.loadData()
        }
    }
}
