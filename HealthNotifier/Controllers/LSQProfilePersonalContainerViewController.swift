//
//  LSQOnboardingProfilePersonalViewController.swift
//
//  Created by Charles Mastin on 11/1/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQProfilePersonalContainerViewController : UIViewController {
    var data: JSON = JSON.null
    var vcEditPersonal: LSQEditProfileViewController? {
        return childViewControllers.flatMap({ $0 as? LSQEditProfileViewController }).first
    }
    var onboarding: Bool = false
    
    // TODO: capture the unwind " aka nav back " intercept if "dirty"
    
    internal func updateProfileAndContinue(_ profileFragment: JSON){
        EZLoadingActivity.show("", disableUI: true)
        LSQAPI.sharedInstance.updateProfileWithCallbacks(
            profileFragment["uuid"].string!,
            data: profileFragment.object as AnyObject,
            success: { response in
                // only thing we need to do here is return son really though really
                // with callbacks though, sketchy AF
                LSQPatientManager.sharedInstance.fetch()
                
                // because this impacts the only attributes that may "render" on the top level collection only do it here!
                NotificationCenter.default.post(
                    name: LSQ.notification.hacks.reloadPatients,
                    object: nil,
                    userInfo: nil
                )
                
                self.navigationController?.popViewController(animated: true)
                // let the VC listen for the patient updated and re-render itself? maybe
                
                // THIS IS SKETCHY
                /*
                LSQAPI.sharedInstance.loadPatientWithCallbacks(
                    profileFragment["uuid"].string!,
                    success: { response in
                        if self.onboarding {
                            EZLoadingActivity.hide(true, animated: true)
                            NotificationCenter.default.post(
                                name: LSQ.notification.show.profileEditMedical,
                                object: self, // parent was an attempt to replace hierarchy? not sure
                                userInfo: [
                                    "patientInstance": response
                                ]
                            )
                            //let appDelegate = UIApplication.sharedApplication().delegate as! LSQAppDelegate
                            //appDelegate.navigationMediator?.showPatientScreenMedical(JSON(response))
                        } else {
                            let n: Int! = self.navigationController?.viewControllers.count
                            let myUIViewController = self.navigationController?.viewControllers[n-2] as? LSQPatientSummaryViewController
                            myUIViewController?.data = JSON(response)
                            myUIViewController?.doubleSecretInit()
                            // blablablablaablabla
                            self.navigationController?.popViewController(animated: true)
                        }
                    },
                    failure: { response in
                        EZLoadingActivity.hide(false, animated: true)
                        // F off
                    }
                )
                 */
            },
            failure: { response in
                // F off
                EZLoadingActivity.hide(false, animated: true)
                let alert: UIAlertController = UIAlertController(
                    title: "Server Error",
                    message: "Unable to update profile",
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        )
    }
    
    @IBAction func actionContinue() {
        // F THIS METHOD
        let profileToSave: JSON = self.vcEditPersonal!.getValidatedProfileToSave()
        if profileToSave != false {
            if self.vcEditPersonal!.capturedImage != nil {
                // prep dat JSON ma son
                
                // TODO: WRAP THIS IN DEFENSE CODE
                var payload: [String: AnyObject] = [:]
                let fileContents: String = LSQ.formatter.imageToBase64(self.vcEditPersonal!.capturedImage!, mode: "jpeg", compression: 0.5)
                print("IMAGE BASE 64 SIZE: \(fileContents.characters.count)")
                payload["ProfilePhoto"] = [
                    "Name": "ios-app-upload-image.jpg",
                    "File": fileContents,
                    "Mimetype": "image/jpeg"
                ] as AnyObject
                // TODO: crop dimensions son
                EZLoadingActivity.show("", disableUI: true)
                LSQAPI.sharedInstance.updateProfilePhoto(
                    profileToSave["uuid"].string!,
                    data: payload as AnyObject,
                    success: { response in
                        EZLoadingActivity.hide(true, animated: true)
                        self.updateProfileAndContinue(profileToSave)
                    },
                    failure: { response in
                        EZLoadingActivity.hide(false, animated: true)
                    }
                )
            } else {
                self.updateProfileAndContinue(profileToSave)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init that sucka
        self.vcEditPersonal!.vcParent = self
        
        self.vcEditPersonal!.tableView.register(UINib(nibName: "CellProfilePhoto", bundle: nil), forCellReuseIdentifier: "CellProfilePhoto")
        self.vcEditPersonal!.tableView.register(UINib(nibName: "CellFormInput", bundle: nil), forCellReuseIdentifier: "CellFormInput")
        self.vcEditPersonal!.tableView.register(UINib(nibName: "CellFormSelect", bundle: nil), forCellReuseIdentifier: "CellFormSelect")
        self.vcEditPersonal!.tableView.register(UINib(nibName: "CellFormCheckbox", bundle: nil), forCellReuseIdentifier: "CellFormCheckbox")
        self.vcEditPersonal!.tableView.register(UINib(nibName: "CellFormDatePicker", bundle: nil), forCellReuseIdentifier: "CellFormDatePicker")
        self.vcEditPersonal!.tableView.register(UINib(nibName: "CellFormHeightPicker", bundle: nil), forCellReuseIdentifier: "CellFormHeightPicker")
        self.vcEditPersonal!.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.vcEditPersonal!.data = self.data
        //self.vcEditPersonal!.tableView.contentInset = UIEdgeInsetsMake(-64.0, 0, 0, 0)
        let onboardingState: String = self.data["meta"]["onboarding_state"].string!
        if onboardingState != "ONBOARDING_COMPLETE" {
            self.onboarding = true
        }
        
        if self.onboarding {
            self.title = "Personal Details"
            self.navigationItem.rightBarButtonItem?.title = "Continue"
        } else {
            self.title = "Personal Details"
            self.navigationItem.rightBarButtonItem?.title = "Save"
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.onCancel))
    }
    
    func onCancel() {
        if self.vcEditPersonal!.dirty {
            // block it
            let alert: UIAlertController = UIAlertController(
                title: "You Have Unsaved Changes",
                message: "",
                preferredStyle: .alert)
            
            let pauseAction: UIAlertAction = UIAlertAction(title:"Disregard Changes", style: UIAlertActionStyle.default, handler: { action in
                self.navigationController?.popViewController(animated: true)
            })
            let cancelAction: UIAlertAction = UIAlertAction(title:"Continue Editing", style: UIAlertActionStyle.cancel, handler: { action in
            })
            alert.addAction(pauseAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
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
                forName: LSQ.notification.hacks.reloadPatient,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // are we a therapy
                EZLoadingActivity.show("", disableUI: false)
                LSQAPI.sharedInstance.loadPatientWithCallbacks(
                    self.data["profile"]["uuid"].string!,
                    success: { response in
                        //
                        EZLoadingActivity.hide(true, animated: true)
                        self.vcEditPersonal?.data = JSON(response)
                        self.vcEditPersonal?.tableView.reloadData()
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
