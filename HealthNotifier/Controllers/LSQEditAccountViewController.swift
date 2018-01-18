//
//  LSQEditAccountViewController.swift
//
//  Created by Charles Mastin on 11/1/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQEditAccountViewController: UITableViewController {
    
    var fields: [LSQModelFieldC] = []
    let user: LSQUser = LSQUser.currentUser
    // var data: JSON = JSON([])
    var valEmail: String = ""
    var valPhone: String? = nil
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // load our cells and stuffs
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        
        self.tableView.register(UINib(nibName: "CellFormInput", bundle: nil), forCellReuseIdentifier: "CellFormInput")
        
        // let profileInstance: LSQModelProfile = LSQModelProfile()
        let emailField: LSQModelFieldC = LSQModelFieldC()
        emailField.label = "Email"
        emailField.property = "email"
        emailField.keyboard = UIKeyboardType.emailAddress
        
        let phoneField: LSQModelFieldC = LSQModelFieldC()
        phoneField.label = "Mobile Phone"
        phoneField.property = "phone"
        phoneField.keyboard = UIKeyboardType.phonePad
        
        self.fields = [
            emailField,
            phoneField
        ]
        
        // prepopulate dem values son
        // double check we can "persist" a nil email when clearing it, mmmkay, actually this is difficult, whatever, don't stress
        self.valEmail = user.email
        // DO NOT populate newPhone though
        
        self.addObservers()
        
    }
    
    @IBAction func actionDone() {
        var dirty: Bool = false
        var errors: [[String:AnyObject]] = []
        
        // validate email
        if self.valEmail != self.user.email {
            // validate it
            if LSQ.validator.email(self.valEmail) {
                
            } else {
                // failed
                errors.append([
                    "message": "Invalid Email Format" as AnyObject
                ])
            }
            dirty = true
        }
        
        if self.valPhone != self.user.phone {
            // basic check, strip and so on
            
            // manual nillllling
            if self.valPhone == "" {
                dirty = true
            } else if self.valPhone == nil {
                // ok this case could not happen
                // don't include it
            } else {
                // we entered something, so regex that stuffs son
                // we need a regex, strip to num and better be 10 long
                if self.valPhone!.isPhoneNumber {
                    print("WHAT THE BRO")
                    dirty = true
                } else {
                    errors.append([
                        "message": "Invalid Phone" as AnyObject
                    ])
                }
            }
            
            // dirty = true
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
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if dirty {
            EZLoadingActivity.show("", disableUI: true)
            var data: [String: AnyObject] = [
                "Email": self.valEmail as AnyObject
            ]
            if self.valPhone != nil {
                data["MobilePhone"] = self.valPhone! as AnyObject?
            }
            
            LSQAPI.sharedInstance.updateUser(
                self.user.uuid!,
                data: data as AnyObject,
                success: { response in
                    
                    NotificationCenter.default.post(
                        name: LSQ.notification.analytics.event,
                        object: nil,
                        userInfo: [
                            "event": "Account Edit",
                            "attributes": [
                                "AccountId": self.user.uuid!,
                                "Provider": self.user.provider
                            ]
                        ]
                    )
                    
                    self.user.fetch()
                    
                    EZLoadingActivity.hide(true, animated: true)
                    self.navigationController?.popViewController(animated: true)
                },
                failure: { response in
                    EZLoadingActivity.hide(false, animated: true)
                    // show da errors in allert form straight from da server
                    // maybe check a bit on response codes
                    let alert: UIAlertController = UIAlertController(
                        title: "Server Error",
                        message: "Unable to update your account",
                        preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    })
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            )
            
        } else {
            // just send it back son
            self.navigationController?.popViewController(animated: true)
        }
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
                if attribute == "email" {
                    self.valEmail = (notification.userInfo!["value"] as? String)!
                }
                if attribute == "phone" {
                    self.valPhone = (notification.userInfo!["value"] as? String)!
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

    
    // create "delegate" to capture changes on the "form"
    
    // table delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fields.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell_default")
        
        let field = self.fields[indexPath.row]
        
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        
        var initialValue: String = ""
        
        if field.formControl == "input" {
            // SPECIAL BINDING TIMES SON
            if field.property == "email" {
                initialValue = user.email
            }
            if field.property == "phone" {
                if (user.phone != nil) {
                    initialValue = user.phone!
                }
            }
            
            cell = Forms.generateDefaultInputCell(tableView, indexPath: indexPath, id: field.property, label: field.label, initialValue: initialValue, required: field.required)
            (cell as! LSQCellFormInput).input?.keyboardType = field.keyboard
        }
        
        return cell
    }
}
