//
//  LSQAccountViewController.swift
//
//  Created by Charles Mastin on 3/4/16.
//

import Foundation
import CoreLocation
import UIKit
import SwiftyJSON

class LSQAccountViewController: UITableViewController {
    var tableConfig: [[String:AnyObject]] = []
    let user = LSQUser.currentUser
    
    var observationQueue: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.tableView.register(UINib(nibName: "CellFormCheckbox", bundle: nil), forCellReuseIdentifier: "CellFormCheckbox")

        self.addObservers()
        self.doubleSecretInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.doubleSecretInit()
    }
    
    func addObservers() {
        self.observationQueue = []
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.touchSetupComplete,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                    preferredStyle = UIAlertControllerStyle.actionSheet
                }
                let alert: UIAlertController = UIAlertController(
                    title: "Touch ID Setup Complete",
                    message: nil,
                    preferredStyle: preferredStyle)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                self.doubleSecretInit()
            }
        )
 
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.acceptTouchTerms,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // prompt the password entry now
                let user: LSQUser = LSQUser.currentUser
                let alert: UIAlertController = UIAlertController(
                    title: "",
                    message: "Please enter the password for \(user.email) in order to complete setup of Touch ID.",
                    preferredStyle: .alert)
                alert.addTextField(configurationHandler: {(textField: UITextField!) in
                    textField.isSecureTextEntry = true
                    textField.placeholder = ""
                })
                
                let okAction: UIAlertAction = UIAlertAction(title:"Submit", style: UIAlertActionStyle.default, handler: { action in
                    
                    if let textFields = alert.textFields{
                        let theTextFields = textFields as [UITextField]
                        let unconfirmedPassword: String = theTextFields[0].text!
                        // TODO TODODODODODODODO
                        // at this point we have to validate the password is correct before we save an encrypted version, lolzin,
                        // the only way to do thiat is to re-authenticate, which works for now, meh meh meh
                        //if LSQ.validator.password(unconfirmedPassword) {
                            
                            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                                preferredStyle = UIAlertControllerStyle.actionSheet
                            }
                            
                            LSQAPI.sharedInstance.verifyAccountCredentials(
                                user.uuid!,
                                password: unconfirmedPassword,
                                success: { response in
                                    LSQTouchAuthManager.sharedInstance.persistPassword(password: unconfirmedPassword)
                                    // TODO: LOLZIN BROLOL I guess it's the job of this guy to set
                                    // yea
                                },
                                failure: { response in
                                    // it' didn't work son, just alert that
                                    let alert: UIAlertController = UIAlertController(
                                        title: "Invalid Password",
                                        message: nil,
                                        preferredStyle: preferredStyle)
                                    let retryAction: UIAlertAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { action in
                                        NotificationCenter.default.post(
                                            name: LSQ.notification.action.acceptTouchTerms,
                                            object: self
                                        )
                                    })
                                    alert.addAction(retryAction)
                                    let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in })
                                    alert.addAction(cancelAction)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            )
                        //}
                    }
                })
                alert.addAction(okAction)
                
                let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                    // nothing here
                })
                alert.addAction(cancelAction)
                
                // TODO: DRY THIS SHIZ UP
                let appDelegate = UIApplication.shared.delegate as! LSQAppDelegate
                guard let rvc = appDelegate.window!.rootViewController else {
                    return
                }
                if let vc:UIViewController = getCurrentViewController(rvc) {
                    vc.present(alert, animated: true, completion: nil)
                }
                
            }
        )
        
        /*
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.declineTouchTerms,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // non op
            }
        )
        */
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.form.field.change,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                let attribute: String = (notification.userInfo!["id"] as? String)!
                let value: AnyObject = notification.userInfo!["value"]! as AnyObject
                
                //
                if attribute == "touchid" {
                    let bValue:Bool = (value as? Bool)!
                    if bValue {
                        NotificationCenter.default.post(
                            name: LSQ.notification.show.termsTouch,
                            object: self
                        )
                    } else {
                        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                            preferredStyle = UIAlertControllerStyle.actionSheet
                        }
                        // yea son// wrap it with a confirm to disable
                        let alert: UIAlertController = UIAlertController(
                            title: "Disable Touch ID?",
                            message: nil,
                            preferredStyle: preferredStyle)
                        let retryAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                            LSQTouchAuthManager.sharedInstance.disable()
                        })
                        alert.addAction(retryAction)
                        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { action in
                            // such overhead just to re-enable a single button lolololo
                            self.doubleSecretInit()
                        })
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
                
                // TEMP INDEPDENT CONTROLS HERES
                if attribute == "location-tracking" {
                    let bValue:Bool = (value as? Bool)!
                    let user = LSQUser.currentUser
                    if bValue {
                        user.prefs.locationTracking = true
                        LSQLocationManager.sharedInstance.start()
                    } else {
                        user.prefs.locationTracking = false
                        LSQLocationManager.sharedInstance.stop()
                    }
                }
                
                if attribute == "background-location" {
                    let bValue:Bool = (value as? Bool)!
                    let user = LSQUser.currentUser
                    if bValue {
                        user.prefs.backgroundLocation = true
                        // ONLY START UP IF NECESSARY
                        if user.prefs.locationTracking {
                            LSQLocationManager.sharedInstance.start()
                        }
                    } else {
                        user.prefs.backgroundLocation = false
                        // for some race condition here, probably never the case
                        if !user.prefs.locationTracking {
                            LSQLocationManager.sharedInstance.stop()
                        }
                    }
                }
                
            }
        )
    }

    
    
    func doubleSecretInit() {
        self.tableConfig = []
        
        // general account info son
        
        var cells: [String] = []
        cells = [
            "email",
            "phone",
            "edit",
            "password",
        ]
        
        // reasonable safeguard
        if LSQTouchAuthManager.sharedInstance.touchIdAvailable() {
            cells.append("touchid")
            // only for 
            //cells.append("touchid-debug")
        }
        
        // put logout in there
        cells.append("logout")
        
        
        // if passcodeset and touchid available
        if LSQ.permissions.checkPermissionNotifications() {
            // User is registered for notification, disable push options
            // TODO:
            // cells.append("disable-push")
            
            if LSQUser.currentUser.prefs.pushEnabled {
                // cells.append("disable-push")
                // TODO: not currently supported, waa waa, just do it at the OS level / settings
            } else {
                // always though, assuming we haven't done the hardcore refusal
                // cells.append("enable-push")
            }
        } else {
            cells.append("enable-push")
        }
        
        self.tableConfig.append([
            "id": "account" as AnyObject,
            "header": "Account" as AnyObject,
            "cells": cells as AnyObject
        ])
        // future - device preferences like notification and so on
        /*
        self.tableConfig.append([
            "id": "device",
            "header": "Device Preferences",
         
        ])
        */
        
        // provider credentialing setup
        self.tableConfig.append([
            "id": "provider" as AnyObject,
            "header": "Health Care Provider" as AnyObject
        ])
        
        self.tableConfig.append([
            "id": "misc" as AnyObject,
            "header": "" as AnyObject,
            "cells": [
                "tou",
                "privacy",
                "support",
                "purge",
                "delete"
            ] as AnyObject
        ])
        
        let user: LSQUser = LSQUser.currentUser
        if user.isHealthNotifierEmployee(){
            // testing admin stuffs
            self.tableConfig.append([
                "id": "admin" as AnyObject,
                "header": "Internal Testing Features" as AnyObject,
                "cells": [
                    "map-emergency",
                    "qrcapture",
                    
                    //"location-tracking",
                    //"background-location"
                ] as AnyObject
            ])
        }
        
        self.tableView.reloadData()
    }
    
    // observe the sketchy user "change" hack event so we can reload our mc shizznizz
    
    // TABLE DELEGATES MY BIZA
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableConfig.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //let config: [String: AnyObject] = self.tableConfig[section]
        return self.tableConfig[section]["header"]! as? String
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let config: [String: AnyObject] = self.tableConfig[section]
        // TOO NOISY TBD
        
         if config["id"]! as? String == "misc" {
            let bundleObj: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject?
            let version = bundleObj as! String
            return "© 2018 Charles Mastin. HealthNotifier \(version) for iOS."
         }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let config: [String: AnyObject] = self.tableConfig[section]
        if config["id"]! as? String == "account" {
            return (config["cells"] as? [String])!.count
        }
        if config["id"]! as? String == "device" {
            return 1 // will expand post mvp - push settings, and some other craps
        }
        if config["id"]! as? String == "provider" {
            return 1 // either a status or a registration link son
        }
        if config["id"]! as? String == "misc" {
            return (config["cells"] as? [String])!.count
        }
        if config["id"]! as? String == "admin" {
            return (config["cells"] as? [String])!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config: [String: AnyObject] = self.tableConfig[indexPath.section]
        
        // TODO: remove the top level switch, so we can more easily move items around sections
        if config["id"]! as? String == "admin" {
            let cellId: String = (config["cells"] as? [String])![indexPath.row]
            
            if cellId == "map-emergency" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "map-emergency"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Map Nearby Emergency Locations"
                return cell
            }
            if cellId == "qrcapture" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "qrcapture"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Capture QRCode Data"
                return cell
            }
            if cellId == "location-tracking" {
                let user = LSQUser.currentUser
                let cell = Forms.generateDefaultCheckboxCell(self.tableView, indexPath: indexPath, id: "location-tracking", label: "Report Location", initialValue: user.prefs.locationTracking, required: false)
                return cell
            }
            if cellId == "background-location" {
                let user = LSQUser.currentUser
                let cell = Forms.generateDefaultCheckboxCell(self.tableView, indexPath: indexPath, id: "background-location", label: "BG Location", initialValue: user.prefs.backgroundLocation, required: false)
                return cell
            }
        }
        
        if config["id"]! as? String == "misc" {
            let cellId: String = (config["cells"] as? [String])![indexPath.row]
            
            if cellId == "tou" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "tou"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Read Terms of Use"
                return cell
            }
            
            if cellId == "privacy" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "privacy"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Read Privacy Policy"
                return cell
            }
            
            if cellId == "support" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "support"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Help & Support"
                return cell
            }
            
            if cellId == "purge" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "purge"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Reset Saved Settings & Logout"
                return cell
            }
            
            if cellId == "delete" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "delete"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Delete Account"
                (cell as? LSQCellAddCollectionItem)?.deleteMode = true
                return cell
            }
        }
        
        if config["id"]! as? String == "account" {
            
            let cellId: String = (config["cells"] as? [String])![indexPath.row]
            
            
            
            if cellId == "touchid" {
                // form switch for touchID enabled or not son
                //let user = LSQUser.currentUser
                let cell = Forms.generateDefaultCheckboxCell(self.tableView, indexPath: indexPath, id: "touchid", label: "Login with Touch ID", initialValue: LSQUser.currentUser.prefs.touchIdEnabled, required: false)
                return cell
            }
            
            if cellId == "touchid-debug" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "touchiddebug"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Debug: Get Touch ID Saved Phrase"
                return cell
            }
            
            if cellId == "email" {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_setup")
                cell.textLabel?.text = user.email
                cell.detailTextLabel?.text = "Logged in as"
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            if cellId == "phone" {
                // lul zone bro
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_setup")
                if user.phone != nil {
                    cell.textLabel?.text = user.phone!
                    cell.detailTextLabel?.text = "Account Recovery Mobile Phone"
                } else {
                    cell.textLabel?.text = "None Entered"
                    cell.detailTextLabel?.text = "Account Recovery Mobile Phone"
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            if cellId == "edit" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "edit"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Edit Details"
                return cell
            }
            if cellId == "password" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "password"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Change Password"
                return cell
            }
            if cellId == "logout" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "logout"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Logout"
                (cell as? LSQCellAddCollectionItem)?.deleteMode = true
                return cell
            }
            // TODO: switch instead
            if cellId == "enable-push" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "enable-push"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Enable Push Notifications"
                return cell
            }
            if cellId == "disable-push" {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "disable-push"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Disable Push Notifications"
                return cell
            }
        }
        
        if config["id"]! as? String == "provider" {
            // are we a provider
            if user.provider {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell_setup")
                cell.textLabel?.text = "Registered Provider"
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            } else {
                if user.providerCredentialStatus != nil {
                    
                    let status = user.providerCredentialStatus?.uppercased()
                    
                    // SHOULD NEVER HAPPEN because .provider is True
                    if status == "ACCEPTED" {
                        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_setup")
                        cell.textLabel?.text = "Credentials Accepted"
                        // cell.detailTextLabel?.text = "Last updated: 12/4/2016 6:30pm"
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                        return cell
                    }
                    if status == "EXPIRED" {
                        let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                        (cell as? LSQCellAddCollectionItem)?.collectionId = "registerprovider"
                        (cell as? LSQCellAddCollectionItem)?.labelText = "Credentials Expired: Register Again"
                        return cell
                        /*
                        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell_setup")
                        cell.textLabel?.text = "Credentials Expired"
                        // cell.detailTextLabel?.text = "Last updated: 12/4/2016 6:30pm"
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                        return cell
                        */
                    }
                    if status == "PENDING" {
                        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_setup")
                        cell.textLabel?.text = "Credentials Review Pending"
                        // cell.detailTextLabel?.text = "Last updated: 12/4/2016 6:30pm"
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                        return cell
                    }
                    if status == "REJECTED" {
                        let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                        (cell as? LSQCellAddCollectionItem)?.collectionId = "registerprovider"
                        (cell as? LSQCellAddCollectionItem)?.labelText = "Credentials Rejected: Register Again"
                        return cell
                    }
                    
                    
                } else {
                    let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "registerprovider"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Register as Provider"
                    return cell
                }
            }
        }
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "bla")
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //var config: [String: AnyObject] = self.tableConfig[indexPath.section]
        let cell = self.tableView.cellForRow(at: indexPath)
        // this is a generic button cell workaround son
        if cell is LSQCellAddCollectionItem {
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "logout" {
                NotificationCenter.default.post(
                    name: LSQ.notification.action.logout,
                    object: self
                )
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "purge" {
                // TODO: put that in a mediator vs here, meh
                // pre-purge before logout bro
                // maybe we need to send user data to handle the mad purge zone though? order of operations, perhaps though
                LSQScanHistory.sharedInstance.purgeKeychain()
                LSQUser.currentUser.purgeKeychain()
                LSQTouchAuthManager.sharedInstance.purgeKeychain()
                NotificationCenter.default.post(
                    name: LSQ.notification.action.logout,
                    object: self
                )
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "delete" {
                NotificationCenter.default.post(
                    name: LSQ.notification.action.deleteAccount,
                    object: self
                )
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "edit" {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.editAccount,
                    object: self
                )
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "touchiddebug" {
                //print("HELLO THERE")
                //print(LSQTouchAuthManager.sharedInstance.requestPassword())
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "enable-push" {
                // double opt in on this bitch
                NotificationCenter.default.post(
                    name: LSQ.notification.permissions.request.notificationsPrettyPlease,
                    object: self
                )
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "disable-push" {
                
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "password" {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.changePassword,
                    object: self
                )
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "registerprovider" {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.providerRegistration,
                    object: self
                )
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "tou" {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.terms,
                    object: self,
                    userInfo: nil
                )
                //UIApplication.shared.openURL(URL(string: "https://www.domain.com/terms/")!)
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "privacy" {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.privacy,
                    object: self,
                    userInfo: nil
                )
                //UIApplication.shared.openURL(URL(string: "https://www.domain.com/privacy/")!)
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "support" {
                UIApplication.shared.openURL(URL(string: "https://www.domain.com/support/")!)
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "qrcapture" {
                NotificationCenter.default.post(
                    name: LSQ.notification.show.scanImport,
                    object: self
                )
            }
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "map-emergency" {
                // grab our coordinates though
                if let location: CLLocation = LSQLocationManager.sharedInstance.lastLocation {
                    UIApplication.shared.openURL(URL(string: "http://maps.apple.com/?q=Hospitals&sll=\(location.coordinate.latitude),\(location.coordinate.longitude)&z=10&t=s")!)
                } else {
                    UIApplication.shared.openURL(URL(string: "http://maps.apple.com/?q=Hospitals&t=m")!)
                }
            }
            return
        }
        
    }
    
}
