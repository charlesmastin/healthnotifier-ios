//
//  LSQMessageContactsViewController.swift
//
//  Created by Charles Mastin on 9/23/16.
//

import Foundation
import UIKit
import SwiftyJSON
import AVFoundation
import CoreLocation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LSQMessageContactsViewController: UITableViewController, UITextViewDelegate {
    
    var data: JSON? = nil
    var patientId: String? = nil
    // we add a certain amount of characters in our "template" so this is a safe zone
    var maxCharacters: Int? = 140 // chunkingin SMS starts at 160 and makes chunks of 153
    var remainingCharacters: Int? = 140
    
    var tableConfig: [[String: AnyObject]] = []
    var includeLocation: Bool = false
    // track state of has permission too
    var message: String = ""
    
    // convenience son
    var input: UITextView? = nil
    
    //@IBOutlet weak var messageTextView: UITextView?
    //@IBOutlet weak var infoLabel: UILabel?
    
    @IBOutlet weak var myTable: UITableView?
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        self.close()
    }
    
    @IBAction func submit() {
        // valiate
        let content: String = message
        if content.characters.count > 0 {
            
            var latitude: Double? = nil
            var longitude: Double? = nil
            if let location: CLLocation = LSQLocationManager.sharedInstance.lastLocation {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
            }
            // spin up the networking layer somewhere, and hit our API with the contents of said messageTextView
            LSQAPI.sharedInstance.messageContacts(
                self.patientId!,
                message: content,
                latitude: latitude,
                longitude: longitude
            )
            
            let user: LSQUser = LSQUser.currentUser
            
            NotificationCenter.default.post(
                name: LSQ.notification.analytics.event,
                object: nil,
                userInfo: [
                    "event": "Message Contacts",
                    "attributes": [
                        "AccountId": user.uuid!,
                        "Provider": user.provider,
                        "PatientId": self.patientId!
                    ]
                ]
            )
            
            // send a "toast or something" whatever you do in the iOS land, can't remember
            self.close()
        } else {
            let alert: UIAlertController = UIAlertController(
                title: "Please add a Message",
                message: "" ,
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                self.focusInput()
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func focusInput() -> Void {
        if self.input != nil {
            self.input!.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.infoLabel?.hidden = true
        
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)

        self.tableView.register(UINib(nibName: "CellFormCheckbox", bundle: nil), forCellReuseIdentifier: "CellFormCheckbox")
        self.tableView.register(UINib(nibName: "CellFormInputMultiline", bundle: nil), forCellReuseIdentifier: "CellFormInputMultiline")

        
        self.tableConfig = []
        self.tableConfig.append([
            "id": "message" as AnyObject,
            "header": "Message" as AnyObject
        ])
        // put the location on the message
        self.tableConfig.append([
            "id": "recipients" as AnyObject,
            "header": "Recipients" as AnyObject
        ])
        
        // check your location permissions, here son, if you agreed turn it on
        
        self.tableView.reloadData()
        // observers in order to do the thingy bingy
        
        // so we can "set our location toggler"
        self.addObservers()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.focusInput()
        
        // check our location services permissions
        // let permissions: String =
        LSQLocationManager.sharedInstance.start()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LSQLocationManager.sharedInstance.stop()
    }
    
    func handleTextChange(_ value: String) -> Void {
        self.remainingCharacters = self.maxCharacters! - value.characters.count
        if self.remainingCharacters > 0 {
            // self.infoLabel?.text = "\(self.remainingCharacters!) Characters Remaining"
        }else {
            let alert: UIAlertController = UIAlertController(
                title: "Maximum characters input",
                message: "Please shorten message" ,
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                self.focusInput()
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
            
            // self.infoLabel?.text = ""
        }
        //return textView.text.characters.count + (text.characters.count - range.length) <= self.maxCharacters!
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableConfig.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let config: [String: AnyObject] = self.tableConfig[section]
        
        if config["id"]! as? String == "recipients" {
            return "\((self.tableConfig[section]["header"]! as? String)!) (\(self.data!["emergency"].arrayValue.count))"
        }

        return config["header"] as? String
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let config: [String: AnyObject] = self.tableConfig[section]
        if config["id"]! as? String == "message" {
            // currently disabled the location toggle
            return 1
            // return 2
        }
        if config["id"]! as? String == "recipients" {
            // bwaa
            if self.data != nil {
                return self.data!["emergency"].arrayValue.count
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell_default")
        
        let config: [String: AnyObject] = self.tableConfig[indexPath.section]
        if config["id"]! as? String == "message" {
            if indexPath.row == 0 {
                // the input
                // cell.textInputMode =
                // size is currently hardcoded up in this bizzle
                cell = Forms.generateDefaultInputMultilineCell(tableView, indexPath: indexPath, id: "message", label: "", initialValue: "", required: true)
                self.input = (cell as? LSQCellFormInputMultiline)?.input
                return cell
            }
            if indexPath.row == 1 {
                // location SON
                //
                
                //
                cell = Forms.generateDefaultCheckboxCell(tableView, indexPath: indexPath, id: "", label: "Include GPS Location", initialValue: self.includeLocation, required: false)
                return cell
            }
        }
        if config["id"]! as? String == "recipients" {
            let contact = self.data!["emergency"].arrayValue[indexPath.row]
            // csv of email and phone
            var channels: [String] = []
            if contact["email"].string != "" {
                channels.append("Email")
            }
            if contact["home_phone"].string != "" {
                channels.append("SMS")
            }
            
            cell.detailTextLabel?.text = channels.joined(separator: ", ")
            cell.textLabel?.text = "\(contact["first_name"].string!) \(contact["last_name"].string!)"
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let config: [String: AnyObject] = self.tableConfig[indexPath.section]
        if config["id"]! as? String == "message" {
            if indexPath.row == 0 {
                return 176.0
            }
        }
        return 44.0
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
                let attribute: String = (notification.userInfo!["id"] as? String)!
                
                if attribute == "message" {
                    self.message = (notification.userInfo!["value"] as? String)!
                    self.handleTextChange(self.message)
                }
                
                if attribute == "location" {
                    self.includeLocation = (notification.userInfo!["value"] as? Bool)!
                    // really just for that section though
                    self.tableView.reloadData()
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
    
    /*
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            if self.remainingCharacters > 0 {
                return "\(self.remainingCharacters!) Characters Remaining"
            }else {
                return ""
            }
        }
        return ""
    }
    */
    
}
