//
//  LSQRoutesPatient.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit
import EZLoadingActivity
import SwiftyJSON

class LSQRoutesPatient : LSQRouter {
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.createPatient,
                object: nil,
                queue: OperationQueue.main,
                using: self.createPatient
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.profile,
                object: nil,
                queue: OperationQueue.main,
                using: self.loadOrShowPatient
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.deletePatient,
                object: nil,
                queue: OperationQueue.main,
                using: self.deletePatient
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.profileEditPersonal,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPatientScreenPersonal
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.profileEditMedical,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPatientScreenMedical
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.profileEditContacts,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPatientScreenContacts
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.profileEditEmergency,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPatientScreenEmergency
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.documentForm,
                object: nil,
                queue: OperationQueue.main,
                using: self.showDocumentFormScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.messageContacts,
                object: nil,
                queue: OperationQueue.main,
                using: self.showMessageContactsScreen
            )
        )
    }
    
    
    // MARK: Patient
    func createPatient(notification: Notification) {
        // this is only ever called in adding additional patients
        // let's assume for a moment the calling notification is originiating from the accounts view controller, which is the root for pushing in the new controllers
        
        // self.patientParentViewController = (notification.object as? UIViewController)!
        LSQAPI.sharedInstance.createProfile()
    }
    
    internal func patientLoadFailure(_ vc: UIViewController) {
        let alert: UIAlertController = UIAlertController(
            title: "Server Error",
            message: "Unable to load profile.",
            preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
            // TODO: focus first problem child?
        })
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func loadOrShowPatient(notification: Notification) {
        // if we were sent patientInstance - show
        if let patientId = notification.userInfo!["patientId"] {
            LSQPatientManager.sharedInstance.uuid = (patientId as! String)
            LSQPatientManager.sharedInstance.fetchWithCallbacks(
                success: { response in
                    let _ = self.renderPatientScreen(notification.object as! UIViewController)
                },
                    failure: { response in
                        
                }
            )
            // begin listening in this class, so we can async without needing callback blocks in fetch
            //
            /*
             LSQAPI.sharedInstance.loadPatientWithCallbacks(
             (patientId as? String)!,
             success: { response in
             let _ = self.renderPatientScreen(notification.object as! UIViewController, patient: JSON(response))
             },
             failure: { response in
             // really not sure what to do, other than broadcast a generic load fail
             // there are multiple consumers of this
             self.patientLoadFailure(notification.object as! UIViewController)
             }
             )
             */
        }
        /*
         if let patientInstance = notification.userInfo!["patientInstance"] {
         let _ = self.renderPatientScreen(notification.object as! UIViewController, patient: JSON(patientInstance))
         return
         }
         if let patientId = notification.userInfo!["patientId"] {
         LSQAPI.sharedInstance.loadPatientWithCallbacks(
         (patientId as? String)!,
         success: { response in
         let _ = self.renderPatientScreen(notification.object as! UIViewController, patient: JSON(response))
         },
         failure: { response in
         // really not sure what to do, other than broadcast a generic load fail
         // there are multiple consumers of this
         self.patientLoadFailure(notification.object as! UIViewController)
         }
         )
         }
         */
    }
    
    // current calling context yo
    func deletePatient(notification: Notification) {
        // semi legit use case in da future would be deleting from a list context… meh
        let p = LSQPatientManager.sharedInstance.json!
        // TODO: refactor to internal when needing the other calling context
        var title: String = "Delete profile for \(p["profile"]["first_name"].string!)?"
        if p["profile"]["first_name"].string == "" {
            title = "Delete New Profile?"
        }
        let alert: UIAlertController = UIAlertController(
            title: title,
            message: "Paramedics won’t be able to retrieve essential health information in an emergency. Any recurring subscriptions will be cancelled and no partial refunds will be issued. Enter \"delete\" into the text field.",
            preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Confirmation"
        })
        let okAction: UIAlertAction = UIAlertAction(title:"Delete Profile", style: UIAlertActionStyle.destructive, handler: { action in
            if let textFields = alert.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText: String = theTextFields[0].text!
                if enteredText.lowercased() == "delete" {
                    EZLoadingActivity.show("", disableUI: false) // hahahahaha
                    LSQAPI.sharedInstance.deleteProfile(
                        p["profile"]["uuid"].string!,
                        success: { response in
                            EZLoadingActivity.hide(true, animated: true)
                            // send an event that the "patients" vc will listen to and reload
                            // send you back to patients view
                            // confirmation on throwing away your patient
                            // hacky message here
                            NotificationCenter.default.post(
                                name: LSQ.notification.network.success,
                                object: self,
                                userInfo: [
                                    "object": "profile",
                                    "action": "delete"
                                ]
                            )
                            let pvc: UIViewController = notification.object as! UIViewController
                            pvc.navigationController?.popToRootViewController(animated: true)
                    },
                        failure: { response in
                            // SO MUCH FAIL SON
                            EZLoadingActivity.hide(false, animated: true)
                            
                            let alert: UIAlertController = UIAlertController(
                                title: "Server Error",
                                message: "Unable to delete profile :(. Please contact support@domain.com for assistance.",
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
            // shut it down
        })
        alert.addAction(cancelAction)
        (notification.object as! UIViewController).present(alert, animated: true, completion: nil)
        
    }
    
    // called in multiple contexts
    internal func renderPatientScreen(_ pvc: UIViewController) -> UIViewController {
        //self.activePatientId = patient["profile"]["uuid"].string!
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQPatientSummaryViewController = sb.instantiateViewController(withIdentifier: "PatientSummaryViewController") as! LSQPatientSummaryViewController
        vc.data = LSQPatientManager.sharedInstance.json!
        vc.doubleSecretInit()
        
        let rvc = self.appDelegate.window!.rootViewController
        if let cvc:UIViewController = getCurrentViewController(rvc!) {
            cvc.navigationController?.pushViewController(vc, animated: true)
        }
        //
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "Patient Summary View",
                "attributes": [
                    "AccountId": LSQUser.currentUser.uuid!,
                    "Provider": LSQUser.currentUser.provider,
                    "PatientId": LSQPatientManager.sharedInstance.uuid!
                ]
            ]
        )
        
        return vc
    }
    
    
    func showPatientScreenPersonal(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQProfilePersonalContainerViewController = sb.instantiateViewController(withIdentifier: "ProfilePersonalContainerViewController") as! LSQProfilePersonalContainerViewController
        vc.data = LSQPatientManager.sharedInstance.json!
        let pvc: UIViewController = notification.object as! UIViewController
        pvc.navigationController?.pushViewController(vc, animated:true)
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "Patient Edit View",
                "attributes": [
                    "Scope": "personal",
                    "AccountId": LSQUser.currentUser.uuid!,
                    "Provider": LSQUser.currentUser.provider,
                    "PatientId": vc.data["profile"]["uuid"].string! // TODO: sort it son
                ]
            ]
        )
    }
    
    func showPatientScreenMedical(notification: Notification) {
        
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQProfileMedicalContainerViewController = sb.instantiateViewController(withIdentifier: "ProfileMedicalContainerViewController") as! LSQProfileMedicalContainerViewController
        vc.data = LSQPatientManager.sharedInstance.json!
        let pvc: UIViewController = notification.object as! UIViewController
        pvc.navigationController?.pushViewController(vc, animated:true)
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "Patient Edit View",
                "attributes": [
                    "Scope": "medical",
                    "AccountId": LSQUser.currentUser.uuid!,
                    "Provider": LSQUser.currentUser.provider,
                    "PatientId": LSQPatientManager.sharedInstance.uuid! // TODO: sort it son
                ]
            ]
        )
        
    }
    
    func showPatientScreenContacts(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQProfileContactsContainerViewController = sb.instantiateViewController(withIdentifier: "ProfileContactsContainerViewController") as! LSQProfileContactsContainerViewController
        vc.data = LSQPatientManager.sharedInstance.json!
        let pvc: UIViewController = notification.object as! UIViewController
        pvc.navigationController?.pushViewController(vc, animated:true)
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "Patient Edit View",
                "attributes": [
                    "Scope": "contacts",
                    "AccountId": LSQUser.currentUser.uuid!,
                    "Provider": LSQUser.currentUser.provider,
                    "PatientId": LSQPatientManager.sharedInstance.uuid! // TODO: sort it son
                ]
            ]
        )
    }
    
    func showPatientScreenEmergency(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQProfileEmergencyContainerViewController = sb.instantiateViewController(withIdentifier: "ProfileEmergencyContainerViewController") as! LSQProfileEmergencyContainerViewController
        vc.data = LSQPatientManager.sharedInstance.json!
        let pvc: UIViewController = notification.object as! UIViewController
        pvc.navigationController?.pushViewController(vc, animated:true)
        
        NotificationCenter.default.post(
            name: LSQ.notification.analytics.event,
            object: nil,
            userInfo: [
                "event": "Patient Edit View",
                "attributes": [
                    "Scope": "emergency",
                    "AccountId": LSQUser.currentUser.uuid!,
                    "Provider": LSQUser.currentUser.provider,
                    "PatientId": LSQPatientManager.sharedInstance.uuid! // TODO: sort it son
                ]
            ]
        )
        
    }
    
    func showDocumentFormScreen(notification: Notification) {
        // push it son
        
        // // transition on the hook brolo partial reset though, only
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = nil
        
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQAddDocumentViewController = sb.instantiateViewController(withIdentifier: "DocumentFormViewController") as! LSQAddDocumentViewController
        vc.patientId = LSQPatientManager.sharedInstance.uuid!
        if let mode = notification.userInfo!["mode"] as? String {
            vc.mode = mode
        }
        if let instance = notification.userInfo!["documentInstance"] {
            vc.data = JSON(instance)
        }
        let pvc: UIViewController = notification.object as! UIViewController
        
        
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
    
    internal func showAddDocumentPickerScreen(_ pvc: UIViewController, mode: String, type:String) {
        // pass through a target or id so we can know where to go next
        // NOTE: because of the current webview, we can't just "make a drag/drop segue"
        // I don't know enough about creating programmatic segues though, that might work, in terms of doing the "unwinding"
        // TODO: needs to be shown in the navigationController SON!
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQAddDocumentViewController = sb.instantiateViewController(withIdentifier: "AddDocumentViewController") as! LSQAddDocumentViewController
        vc.mode = mode //(notification.userInfo!["mode"])! as! String
        vc.patientId = LSQPatientManager.sharedInstance.uuid!
        
        // deal with patient
        guard let rvc = self.appDelegate.window!.rootViewController else {
            return
        }
        if let cvc:UIViewController = getCurrentViewController(rvc) {
            cvc.navigationController?.pushViewController(vc, animated: true, completion: {
                
            })
        }
    }
    
    func showMessageContactsScreen(notification: Notification) {
        
        // TODO: pass through the title,
        // otherwise we need an endpoint that describes a DD know what I'm sayin
        // that probably makes sense anyhow, consider yourself considered
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQMessageContactsViewController = sb.instantiateViewController(withIdentifier: "MessageContactsViewController") as! LSQMessageContactsViewController
        vc.patientId = LSQPatientManager.sharedInstance.uuid! // da F
        vc.data = LSQPatientManager.sharedInstance.json!
        
        // we need to pass in the current patient JSON, so we can list the contacts here
        
        let navigationController = UINavigationController(rootViewController: vc)
        guard let rvc = self.appDelegate.window!.rootViewController else {
            return
        }
        if let cvc:UIViewController = getCurrentViewController(rvc) {
            // cvc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            cvc.present(navigationController, animated: true, completion: {
                // vc.loadData(documentId, fileIndex: fileIndex!)
            })
        }
    }
}
