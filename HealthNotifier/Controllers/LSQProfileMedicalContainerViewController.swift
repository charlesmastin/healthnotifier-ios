//
//  LSQOnboardingProfileMedicalViewController.swift
//
//  Created by Charles Mastin on 11/7/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQProfileMedicalContainerViewController : UIViewController {
    var data: JSON = JSON.null
    var vcMedical: LSQPatientMedicalViewController? {
        return childViewControllers.flatMap({ $0 as? LSQPatientMedicalViewController }).first
    }
    var onboarding: Bool = false
    
    // LOL SON
    internal func continueToNextOnboardingStep() {
        NotificationCenter.default.post(
            name: LSQ.notification.show.profileEditContacts,
            object: self, // parent was an attempt to replace hierarchy? not sure
            userInfo: nil
        )
    }
    
    @IBAction func actionContinue() {
        if self.onboarding {
            
            // VALIDATE on EMPTY COLLECTIONS and throw up da alert son
            // put this somewhere????
            // IF we literally have 0 length on all of the collections
            
            // do we have a fresh copy from the inner controller, whatever FML
            
            let patient = self.vcMedical?.data
            
            if patient!["directives"].arrayValue.count == 0 &&
                patient!["medications"].arrayValue.count == 0 &&
                patient!["allergies"].arrayValue.count == 0 &&
                patient!["conditions"].arrayValue.count == 0 &&
                patient!["conditions"].arrayValue.count == 0 &&
                patient!["procedures"].arrayValue.count == 0 &&
                patient!["immunizations"].arrayValue.count == 0 &&
                patient!["documents"].arrayValue.count == 0 {
                
                // OH SNAP
                let alert: UIAlertController = UIAlertController(
                    title: "Proceed with no medical history?",
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
            LSQPatientManager.sharedInstance.fetch() // but why though?
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.vcMedical!.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.vcMedical!.data = self.data
        self.vcMedical!.editMode = true
        self.vcMedical!.configureTable()
        let onboardingState: String = self.data["meta"]["onboarding_state"].string!
        if onboardingState != "ONBOARDING_COMPLETE" {
            self.onboarding = true
        }
        if self.onboarding {
            self.title = "Medical Details"
            self.navigationItem.rightBarButtonItem?.title = "Continue"
        } else {
            self.title = "Medical Details"
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
        
        self.addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EZLoadingActivity.hide(true, animated: true)
    }
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        
        self.observationQueue = []
        // THIS IS A plugin for the medication -> dose relationship
        /*
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.loaded.patient2,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.vcMedical?.data = LSQPatientManager.sharedInstance.json
                self.vcMedical?.tableView.reloadData()
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
