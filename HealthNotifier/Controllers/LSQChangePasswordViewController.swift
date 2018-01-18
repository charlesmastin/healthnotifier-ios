//
//  LSQChangePasswordViewController.swift
//
//  Created by Charles Mastin on 12/9/16.
//

import Foundation
import UIKit
import EZLoadingActivity

class LSQChangePasswordViewController: UITableViewController {
    
    var fields: [LSQModelFieldC] = []
    let user: LSQUser = LSQUser.currentUser
    
    var valCurrentPassword: String = ""
    var valNewPassword: String = ""
    var valConfirmPassword: String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // load our cells and stuffs
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        
        self.tableView.register(UINib(nibName: "CellFormInput", bundle: nil), forCellReuseIdentifier: "CellFormInput")
        
        let currentPasswordField: LSQModelFieldC = LSQModelFieldC()
        currentPasswordField.label = "Current"
        currentPasswordField.property = "currentpassword"
        currentPasswordField.keyboard = UIKeyboardType.default
        
        let newPasswordField: LSQModelFieldC = LSQModelFieldC()
        newPasswordField.label = "New"
        newPasswordField.property = "newpassword"
        newPasswordField.keyboard = UIKeyboardType.default
        
        let confirmPasswordField: LSQModelFieldC = LSQModelFieldC()
        confirmPasswordField.label = "(Again)"
        confirmPasswordField.property = "confirmpassword"
        confirmPasswordField.keyboard = UIKeyboardType.default
        
        self.fields = [
            currentPasswordField,
            newPasswordField,
            confirmPasswordField
        ]
        
        self.addObservers()
        
    }
    
    @IBAction func actionDone() {
        // basically, only valid if we have all the things in line son
        var errors: [[String: AnyObject]] = []
        
        if LSQ.validator.password(self.valCurrentPassword) &&
            LSQ.validator.password(self.valNewPassword) &&
            LSQ.validator.password(self.valConfirmPassword) {
            // we can't check this  until we hit the server, and a round trip is going to be painful if we "clear" it, lolzors
            if self.valCurrentPassword == self.valNewPassword {
                errors.append([
                    "message": "New password is the same as current password. Please choose a unique new password." as AnyObject
                ])
            }
            if self.valNewPassword == self.valConfirmPassword {
                // NON OP, proceed
            } else {
                errors.append([
                    "message": "New and Confirmation passwords do not match." as AnyObject
                ])
            }
            
        } else {
            errors.append([
                "message": "Please complete all fields with 'valid' passwords as defined below." as AnyObject
            ])
        }
         
        if errors.count > 0 {
            // DRY THIS MOTHER TRUCKER UP TO OUR CORE ERROR RENDERER
            var messages: [String] = []
            for (_, value) in errors.enumerated() {
                messages.append(value["message"] as! String)
            }
            
            let alert: UIAlertController = UIAlertController(
                title: "Validation Errors",
                message: messages.joined(separator: "\n") ,
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                // TODO: focus field items if we have a handle
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        EZLoadingActivity.show("", disableUI: true)
        
        // BECAUSE FML, we have to send along the existing Email and MobilePhone, w/e w/e
        
        let data: [String: AnyObject] = [
            "Email": self.user.email as AnyObject,
            "CurrentPassword": self.valCurrentPassword as AnyObject,
            "NewPassword": self.valNewPassword as AnyObject
        ]
        if user.phone != nil {
            // NON OP, we don't need to send it right now,
            // YES THIS IS MAD SKETCHY AND VIOLATES THE FLIPPING
            // PUT HTTP SPEC, SUE ME
        }
        
        LSQAPI.sharedInstance.updateUser(
            self.user.uuid!,
            data: data as AnyObject,
            success: { response in
                //
                // MVP - NON OP
                //
                // PHASE 1 - CYCLE THE TOKENS ON THE SERVER AND RESYNC LOCALLY
                NotificationCenter.default.post(
                    name: LSQ.notification.analytics.event,
                    object: nil,
                    userInfo: [
                        "event": "Change Password",
                        "attributes": [
                            "AccountId": self.user.uuid!,
                            "Provider": self.user.provider
                        ]
                    ]
                )
                
                
                EZLoadingActivity.hide(true, animated: true)
                self.navigationController?.popViewController(animated: true)
            },
            failure: { response in
                EZLoadingActivity.hide(false, animated: true)
                // show da errors in allert form straight from da server
                // maybe check a bit on response codes
                let alert: UIAlertController = UIAlertController(
                    title: "Error",
                    message: "Unable to change passwords on server, possibly because current password is not correct." ,
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
        )
    }
    
    // table delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell_default")
        
        let field = self.fields[indexPath.row]
        
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        
        var initialValue: String = ""
        initialValue = "" // suck it compiler
        if field.formControl == "input" {
            
            cell = Forms.generateDefaultInputCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required)
            (cell as! LSQCellFormInput).input?.keyboardType = field.keyboard
            
            // ok secure the entry now
            (cell as! LSQCellFormInput).input?.isSecureTextEntry = true
            
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "A password must be at least 8 characters long and contain either a number or a symbol e.g. #!*"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.form.field.change,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                let attribute = (notification.userInfo!["id"] as? String)
                if attribute == "currentpassword" {
                    self.valCurrentPassword = (notification.userInfo!["value"] as? String)!
                }
                if attribute == "newpassword" {
                    self.valNewPassword = (notification.userInfo!["value"] as? String)!
                }
                if attribute == "confirmpassword" {
                    self.valConfirmPassword = (notification.userInfo!["value"] as? String)!
                }
            }
        )
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
