//
//  LSQOnboardingProfileContactsViewController.swift
//
//  Created by Charles Mastin on 11/7/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQProfileContactsContainerViewController : UIViewController {
    var data: JSON = JSON.null
    var vcContacts: LSQPatientContactsViewController? {
        return childViewControllers.flatMap({ $0 as? LSQPatientContactsViewController }).first
    }
    var onboarding: Bool = false
    
    fileprivate func continueToNextOnboardingStep() {
        NotificationCenter.default.post(
            name: LSQ.notification.show.profileEditEmergency,
            object: self, // don't need dat parent bit, we are the parent son
            userInfo: nil
        )
    }
    
    @IBAction func actionContinue() {
        // we don't need a fresh copy for confirmation necessarily at all
        // we should have a reference to the currently active patient in the
        
        // OK DOKIE SON
        
        // ONLY if we're confirmed false
        let patient = self.vcContacts?.data
        
        if !patient!["profile"]["confirmed"].boolValue {
            
            // emergency removed here
            if patient!["insurances"].arrayValue.count == 0 &&
                patient!["care_providers"].arrayValue.count == 0 &&
                patient!["hospitals"].arrayValue.count == 0 &&
                patient!["pharmacies"].arrayValue.count == 0 {
                
                // OH SNAP
                let alert: UIAlertController = UIAlertController(
                    title: "Proceed without adding information?",
                    message: "You may enter it later and update at any time but we recommend adding it now.",
                    preferredStyle: .alert)
                let okAction: UIAlertAction = UIAlertAction(title:"Proceed", style: UIAlertActionStyle.default, handler: { action in
                    self.continueToNextOnboardingStep()
                })
                alert.addAction(okAction)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                    
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
                return
            
            }
            
            self.continueToNextOnboardingStep()
            
        } else {
            // TODO: POP TO THE PATIENT SUMMARY SPECIFICALLY SON
            self.navigationController?.popViewController(animated: true)
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.vcContacts!.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.vcContacts!.data = self.data
        self.vcContacts!.editMode = true
        //self.vcContacts!.tableView.contentInset = UIEdgeInsetsMake(-64.0, 0, 0, 0)

        self.vcContacts!.configureTable()
        
        let onboardingState: String = self.data["meta"]["onboarding_state"].string!
        if onboardingState != "ONBOARDING_COMPLETE" {
            self.onboarding = true
        }
        
        if self.onboarding {
            self.title = "Insurance & Medical Contacts"
            self.navigationItem.rightBarButtonItem?.title = "Continue"
        } else {
            self.title = "Insurance & Medical Contacts"
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EZLoadingActivity.hide(true, animated: true)
        self.addObservers()
    }
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        // THIS IS A plugin for the medication -> dose relationship
        /*
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.reloadPatient,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // are we a therapy
                EZLoadingActivity.show("", disableUI: false)
                LSQAPI.sharedInstance.loadPatientWithCallbacks(
                    self.data["profile"]["uuid"].string!,
                    success: { response in
                        EZLoadingActivity.hide(true, animated: true)
                        //
                        self.vcContacts?.data = JSON(response)
                        self.vcContacts?.tableView.reloadData()
                    },
                    failure: { response in
                        //
                    }
                )
            }
        )
         */
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
