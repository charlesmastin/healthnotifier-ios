//
//  LSQProfileEmergencyContainerViewController.swift
//
//  Created by Charles Mastin on 12/7/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQProfileEmergencyContainerViewController: UIViewController {
    var data: JSON = JSON.null
    var onboarding: Bool = false
    var vcContacts: LSQProfileEmergencyViewController? {
        return childViewControllers.flatMap({ $0 as? LSQProfileEmergencyViewController }).first
    }
    
    fileprivate func continueToNextOnboardingStep() {
        NotificationCenter.default.post(
            name: LSQ.notification.show.profileConfirm,
            object: self, // don't need dat parent bit, we are the parent son
            userInfo: nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IN THE CHILD CHILD CHILD")
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
            self.title = "Emergency Contacts"
            self.navigationItem.rightBarButtonItem?.title = "Continue"
        } else {
            self.title = "Emergency Contacts"
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
        
        // self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(self.addExistingContact)))
        
        self.addObservers()
    }
    
    
    //
    @IBAction func actionContinue() {
        let patient = self.vcContacts?.data
        
        if !patient!["profile"]["confirmed"].boolValue {
            
            if patient!["emergency"].arrayValue.count == 0 {
                
                // OH SNAP
                let alert: UIAlertController = UIAlertController(
                    title: "Proceed without adding contacts?",
                    message: "You may enter them later but we recommend adding now.",
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
