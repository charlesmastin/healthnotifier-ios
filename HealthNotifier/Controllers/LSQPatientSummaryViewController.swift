//
//  LSQPatientSummaryViewController.swift
//
//  Created by Charles Mastin on 12/2/16.
//

import Foundation
import UIKit
import SwiftyJSON
import Kingfisher
import EZLoadingActivity

class LSQPatientSummaryViewController : UITableViewController {
    // handle all dem clicks son
    var data: JSON? = nil
    var imageSize: CGFloat = 44.0
    var tableConfig: [[String: AnyObject]] = []
    var hasLifesquare: Bool = true // this sounds dumb, but swift is verbose, so it's a helper
    var hasCoverage: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.addObservers()
    }
    
    func doubleSecretInit() -> Void {
        // huh what?
        self.tableConfig = []
        // preview that shiz ma niz
        if self.data!["profile"]["first_name"].string != "" {
            self.title = "\(self.data!["profile"]["first_name"].string!)’s Profile"
        } else {
            self.title = "New Profile"
        }
        
        if let _ = self.data!["profile"]["lifesquare_id"].string {
            self.hasLifesquare = true
        } else {
            self.hasLifesquare = false
        }
        
        if let _ = self.data!["meta"]["coverage"].dictionaryObject {
            self.hasCoverage = true
        } else {
            self.hasCoverage = false
        }
        
        if self.hasLifesquare {
            self.tableConfig.append([
                "id": "lifesquare" as AnyObject,
                "header": "" as AnyObject//View Your LifeSticker"
            ])
        }
        
        if !self.hasLifesquare || !self.hasCoverage {
            // TODO: and base this on coverage
            self.tableConfig.append([
                "id": "setup" as AnyObject,
                "header": "" as AnyObject
            ])
        }
        
        if self.data!["profile"]["confirmed"].boolValue {
        
            self.tableConfig.append([
                "id": "profile" as AnyObject,
                "header": "Manage Information" as AnyObject
            ])
            self.tableConfig.append([
                "id": "emergency" as AnyObject,
                "header": "Emergency Contacts" as AnyObject
            ])
            
        }
        
        if self.hasLifesquare {
            // calculate that though, limit to 5, show dem stats bigelo
            // put that shiz ma niz in a collection view though
            
            if self.data!["network"]["auditors_pending"].arrayValue.count > 0 {
                self.tableConfig.append([
                    "id": "network-outbound-pending" as AnyObject,
                    "header": "Requests To Join Your LifeCircle" as AnyObject
                ])
            }
            
            self.tableConfig.append([
                "id": "network-outbound" as AnyObject,
                "header": "LifeCircle" as AnyObject
            ])
            
            
            // calculate that though, limit to 5, show dem stats bigelo
            self.tableConfig.append([
                "id": "network-inbound" as AnyObject,
                "header": "Shared With You" as AnyObject
                ])
            
            self.tableConfig.append([
                "id": "careplans" as AnyObject,
                "header": "Advise Me" as AnyObject
                ])
            
            // calculate that though, limit to 5, show dem stats bigelo
            if self.data!["access_log"].arrayValue.count > 0 {
                self.tableConfig.append([
                    "id": "access-log" as AnyObject,
                    "header": "Recent Access Log" as AnyObject
                ])
            }
            
        }
        
        var actions: [String] = []
        
        if self.hasLifesquare {
             // summary
            if self.hasCoverage {
                actions.append("coverage")
                actions.append("replace")
            } else {
                // TODO: we are not currently sending back the expired coverage data, so let's not stress
                actions.append("renew")
            }
            actions.append("delete")
        } else {
            if self.data!["profile"]["confirmed"].boolValue {
                actions.append("assign")
            } else {
                // CONTINUE SETUP SON - but just use that big link above
            }
            // we don't explicitly need the assign action, as it "SHOULD" be handled by the Continue Setup
             // but why not
            actions.append("delete")
        }
        
        let user: LSQUser = LSQUser.currentUser
        // TODO: user user isStaffMember
        if user.isLifesquareEmployee(){
            actions.append("scanimport")
            actions.append("claim")
            actions.append("onboarding-profile")
            actions.append("onboarding-medical")
            actions.append("onboarding-success")
            actions.append("checkout")
        }
        
        self.tableConfig.append([
            "id": "admin" as AnyObject,
            "header": "Administration" as AnyObject,
            "actions": actions as AnyObject
        ])
        
        self.tableView.reloadData()
        EZLoadingActivity.hide(true, animated: true)
    }
    
    // table delegates for days son
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableConfig.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let config: [String: AnyObject] = self.tableConfig[section]
        if config["id"]! as? String == "network-outbound-pending" {
            return "\((self.tableConfig[section]["header"]! as? String)!) (\(self.data!["network"]["auditors_pending"].arrayValue.count))"
        }
        /*
        if config["id"]! as? String == "network-inbound" {
            return "\((self.tableConfig[section]["header"]! as? String)!) (\(self.data!["network"]["granters"].arrayValue.count))"
        }
        if config["id"]! as? String == "network-outbound" {
            return "\((self.tableConfig[section]["header"]! as? String)!) (\(self.data!["network"]["auditors"].arrayValue.count))"
        }
        */
        if let title = self.tableConfig[section]["header"]! as? String {
            return title
        }
        return nil
    }
    
    /*
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let config: [String: AnyObject] = self.tableConfig[section]
        // TOO NOISY TBD
        
        if config["id"]! as? String == "emergency" {
            return "Will be notified when your LifeSticker is scanned"
        }
        if config["id"]! as? String == "network-outbound" {
            return "HealthNotifier members you shared your profile with"
        }
        if config["id"]! as? String == "network-inbound" {
            return "HealthNotifier members who have shared their profile with you"
        }
        if config["id"]! as? String == "careplans" {
            return "Get help with a condition you may have, before you head to the Hospital or Urgent Care!"
        }
        
        return ""
    }
    */
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let config: [String: AnyObject] = self.tableConfig[section]
        if let cid: String = config["id"]! as? String {
            switch cid {
                case "setup":
                    return 1
                case "lifesquare":
                    return 1
                case "profile":
                    return 3
                case "emergency":
                    var count: Int = self.data!["emergency"].arrayValue.count
                    if count > 0 {
                        count += 2
                    }else {
                        count += 1
                    }
                    return count
                case "network-outbound-pending":
                    return self.data!["network"]["auditors_pending"].arrayValue.count
                case "network-inbound":
                    var tot:Int = 0
                    tot += self.data!["network"]["granters"].arrayValue.count
                    tot += 1 // manage button? lol
                    return tot
                case "network-outbound":
                    return self.data!["network"]["auditors"].arrayValue.count + 1
                case "careplans":
                    return 1
                case "access-log":
                    return self.data!["access_log"].arrayValue.count
                case "admin":
                    return (config["actions"]! as? [String])!.count
                default:
                    break
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config: [String: AnyObject] = self.tableConfig[indexPath.section]
        let cid: String = (config["id"]! as? String)!
        let profile: JSON = self.data!["profile"]
        if cid == "setup" {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell_setup")
            cell.textLabel?.text = "Resume Setup"
            cell.textLabel?.textColor = LSQ.appearance.color.blueApple
            // TODO: FONT SIZE
            //cell.textLabel?.font = UIFont(name: (cell.textLabel?.font.fontName)!, size: 24.0)
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            
            
            // dial in a different term of we need to renew coverage
            if self.hasLifesquare && !self.hasCoverage {
                cell.textLabel?.text = "Renew Annual Coverage"
            }
            
            return cell
        } else if cid == "lifesquare" {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "donkeyimage")
            
            let placeholder = UIImage(named: "qrcode")
            cell.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            
            // lifesquares/001LSQ001/image
            if let _ = profile["lifesquare_id"].string {
                let imageURL: String = "\(LSQAPI.sharedInstance.api_root)lifesquares/\(profile["lifesquare_id"].string!)/image?width=\(Int(imageSize * 2))&height=\(Int(imageSize * 2))"
                cell.imageView?.kf.setImage(
                    with: URL(string: imageURL),
                    placeholder: placeholder,
                    options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)]
                )
                
                // TODO: stylized LSQ code view
                cell.textLabel?.text = "View \(profile["first_name"])’s LifeSticker"
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            } else {
                cell.imageView?.image = placeholder
            }
            return cell
        } else if cid == "profile" {
            let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
            if indexPath.row == 0 {
                (cell as? LSQCellAddCollectionItem)?.collectionId = "personal"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Personal Details"
            }
            if indexPath.row == 1 {
                (cell as? LSQCellAddCollectionItem)?.collectionId = "medical"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Medical Records"
            }
            if indexPath.row == 2 {
                (cell as? LSQCellAddCollectionItem)?.collectionId = "contacts"
                (cell as? LSQCellAddCollectionItem)?.labelText = "Insurance & Care Providers"
            }
            return cell
        } else if cid == "emergency" {
            // your summary rows for each contact, theb
            // edit contacts button son
            if (indexPath.row < self.data!["emergency"].arrayValue.count) {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla")
                let row = self.data!["emergency"][indexPath.row]
                if let title = row["title"].string {
                    cell.textLabel?.text = title
                }
                // this will be nil if contact relationship is not set
                // BUT LOL, this should be "" from the server damn
                if let description = row["description"].string {
                    cell.detailTextLabel?.text = description
                }
                cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                return cell
            } else {
                if self.data!["emergency"].arrayValue.count > 0 && indexPath.row == self.data!["emergency"].arrayValue.count {
                    let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "notify-emergency-contacts"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Send A Message To Your Contacts"
                    return cell
                } else {
                    let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "emergency"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Manage Contacts"
                    return cell
                }
            }
        } else if cid == "network-outbound" {
            // edit contacts button son
            if (indexPath.row < self.data!["network"]["auditors"].arrayValue.count) {
                var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_outbound")
                let node: JSON = self.data!["network"]["auditors"][indexPath.row]
                cell.textLabel?.text = node["auditor_name"].string!
                
                let cellPatientId: String = node["auditor_uuid"].string!
                var cellPatientPhotoUuid: String = ""
                if let photo_uuid:String = node["auditor_photo_uuid"].string {
                    cellPatientPhotoUuid = photo_uuid
                }
                let imageSize: Int = 44
                let photoUrl: String = "\(LSQAPI.sharedInstance.api_root)profiles/\(cellPatientId)/profile-photo?photo_uuid=\(cellPatientPhotoUuid)&width=\(Int(imageSize * 2))&height=\(Int(imageSize * 2))"
                cell = Tables.decorateProfilePhoto(cell, photoUrl: photoUrl)

                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                return cell
            } else {
                // manage connections link son -- good time to brush it up son
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "network-outbound"
                if self.data!["network"]["auditors"].arrayValue.count > 0 {
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Manage Connections"
                } else {
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Share Your LifeSticker"
                }
                return cell
            }
        } else if cid == "network-outbound-pending" {
            if (indexPath.row < self.data!["network"]["auditors_pending"].arrayValue.count) {
                var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_inbound")
                let node: JSON = self.data!["network"]["auditors_pending"][indexPath.row]
                cell.textLabel?.text = node["auditor_name"].string!
                cell.detailTextLabel?.text = LSQ.formatter.humanizeTimestamp(node["asked_at"].string!)
                
                let cellPatientId: String = node["auditor_uuid"].string!
                var cellPatientPhotoUuid: String = ""
                if let photo_uuid:String = node["auditor_photo_uuid"].string {
                    cellPatientPhotoUuid = photo_uuid
                }
                
                let imageSize: Int = 44
                let photoUrl: String = "\(LSQAPI.sharedInstance.api_root)profiles/\(cellPatientId)/profile-photo?photo_uuid=\(cellPatientPhotoUuid)&width=\(Int(imageSize * 2))&height=\(Int(imageSize * 2))"
                cell = Tables.decorateProfilePhoto(cell, photoUrl: photoUrl)
                
                if node["auditor_provider"].boolValue {
                    cell.detailTextLabel?.text = "\(LSQ.formatter.humanizeTimestamp(node["asked_at"].string!)) - Registered Health Care Provider"
                }
                
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                return cell
            }
        } else if cid == "network-inbound" {
            // your summary rows for each contact, theb
            
            // edit contacts button son
            if (indexPath.row < self.data!["network"]["granters"].arrayValue.count) {
                var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_inbound")
                let node: JSON = self.data!["network"]["granters"][indexPath.row]
                cell.textLabel?.text = node["granter_name"].string!
                
                let cellPatientId: String = node["granter_uuid"].string!
                var cellPatientPhotoUuid: String = ""
                if let photo_uuid:String = node["granter_photo_uuid"].string {
                    cellPatientPhotoUuid = photo_uuid
                }
                let imageSize: Int = 44
                let photoUrl: String = "\(LSQAPI.sharedInstance.api_root)profiles/\(cellPatientId)/profile-photo?photo_uuid=\(cellPatientPhotoUuid)&width=\(Int(imageSize * 2))&height=\(Int(imageSize * 2))"
                cell = Tables.decorateProfilePhoto(cell, photoUrl: photoUrl)
                
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                return cell
            } else {
                // manage connections link son -- good time to brush it up son
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                (cell as? LSQCellAddCollectionItem)?.collectionId = "network-inbound"
                
                if self.data!["network"]["granters"].arrayValue.count > 0 {
                    // while we could separate these, it's basically always gonna be the same CTA here
                    // "leaving" someone's circle is really a non-op
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Request To View LifeSticker"
                } else {
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Request To View LifeSticker"
                }

                
                return cell
            }
        } else if cid == "careplans" {
            /*
            if indexPath.row == 0 {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "bla")
                cell.textLabel?.text = "Get help with a condition you may have, before you head to the Hospital or Urgent Care!"
                return cell
            } else {
            */
            let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
            (cell as? LSQCellAddCollectionItem)?.collectionId = "careplans"
            (cell as? LSQCellAddCollectionItem)?.labelText = "Get Started"
            return cell
            //}
        } else if cid == "access-log" {
            // your summary rows for each item, theb
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla")
            let row: JSON = self.data!["access_log"][indexPath.row]
            if row["platform"].stringValue == "sms" {
                cell.textLabel?.text = row["scanner_phone_number"].string!
            } else {
                if let name = row["scanner_name"].string {
                    if row["is_provider"].boolValue {
                        // TODO: hook da thing bop son
                        // cell.accessoryType = UITableViewCellAccessoryType.DetailButton
                        cell.textLabel?.text = "\(name) (Health care provider)"
                    } else {
                        cell.textLabel?.text = "\(name)"
                    }
                    
                }
            }
            // yea son my son
            if let created_at = row["created_at"].string {
                // TODO: WTF audit trail substring
                let s = created_at.substring(to: created_at.index(created_at.startIndex, offsetBy: 10))
                cell.detailTextLabel?.text = s
                cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        } else if cid == "admin" {
            
            // oh well son
            let action = (config["actions"] as? [String])![indexPath.row]
            
            if action == "coverage" {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla")
                cell.textLabel?.text = "Valid Coverage"
                if let expirationString = self.data!["meta"]["coverage"]["end_date"].string {
                    let recurringCoverage = self.data!["meta"]["coverage"]["recurring"].boolValue
                    if recurringCoverage {
                        cell.detailTextLabel?.text = "Renewing on \(expirationString)"
                    }else {
                        cell.detailTextLabel?.text = "Expires on \(expirationString)"
                    }
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            } else {
                let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "donkey")
                if action == "assign" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "assign"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Assign LifeStickers"
                }
                if action == "rewnew" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "renew"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Renew Coverage"
                }
                if action == "replace" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "replace"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Get Replacement LifeStickers"
                }
                if action == "scanimport" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "scanimport"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "QA: Import via Scan"
                }
                if action == "claim" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "claim"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "QA: Claim"
                }
                if action == "onboarding-profile" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "onboarding-profile"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "QA: Onboarding Profile"
                }
                if action == "onboarding-medical" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "onboarding-medical"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "QA: Onboarding Medical"
                }
                if action == "onboarding-success" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "onboarding-success"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "QA: Onboarding Success"
                }
                if action == "checkout" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "checkout"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "QA: Checkout"
                }
                if action == "delete" {
                    (cell as? LSQCellAddCollectionItem)?.collectionId = "delete"
                    (cell as? LSQCellAddCollectionItem)?.labelText = "Delete Profile"
                    (cell as? LSQCellAddCollectionItem)?.deleteMode = true
                }
                return cell
            }
        }
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "bla")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var config: [String: AnyObject] = self.tableConfig[indexPath.section]
        let cell = self.tableView.cellForRow(at: indexPath)
        // this is a generic button cell workaround son
        if cell is LSQCellAddCollectionItem {
            if let collectionId:String = (cell as? LSQCellAddCollectionItem)?.collectionId {
                switch collectionId {
                case "notify-emergency-contacts":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.messageContacts,
                        object: self,
                        userInfo: nil
                        // do we need to send on the patient model or patientid, blabalablabla here?
                    )
                    break
                case "careplans":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.careplanIndex,
                        object: self,
                        userInfo: nil
                    )
                    break
                case "network-outbound":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.patientNetwork,
                        object: self,
                        userInfo: ["mode": "outbound"] // granter
                    )
                    break
                case "network-inbound":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.patientNetwork,
                        object: self,
                        userInfo: ["mode": "inbound"] // granter
                    )
                    break
                case "replace":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.checkout,
                        object: self,
                        userInfo: [
                            "mode": "replace",
                            ]
                    )
                    break
                case "renew":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.checkout,
                        object: self,
                        userInfo: [
                            "mode": "renew",
                            ]
                    )
                    break
                case "assign":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.checkout,
                        object: self,
                        userInfo: [
                            "mode": "assign",
                            ]
                    )
                    break
                case "delete":
                    NotificationCenter.default.post(
                        name: LSQ.notification.action.deletePatient,
                        object: self,
                        userInfo: nil
                    )
                    break
                case "scanimport":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.scanImport,
                        object: self,
                        userInfo: [
                            "mode": "bla",
                            ]
                    )
                    break
                case "onboarding-profile":
                    LSQOnboardingManager.sharedInstance.begin()
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.onboardingProfile,
                        object: self,
                        userInfo: nil
                    )
                    break
                case "onboarding-medical":
                    LSQOnboardingManager.sharedInstance.begin()
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.onboardingMedical,
                        object: self,
                        userInfo: nil
                    )
                    break
                case "onboarding-success":
                    LSQOnboardingManager.sharedInstance.begin()
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.onboardingSuccess,
                        object: self,
                        userInfo: nil
                    )
                    break
                case "checkout":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.checkout,
                        object: self,
                        userInfo: [
                            "mode": "assign",
                            ]
                    )
                    break
                case "claim":
                    LSQOnboardingManager.sharedInstance.begin()
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.onboardingScanLifesquare,
                        object: self,
                        userInfo: nil
                    )
                    break
                case "personal":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.profileEditPersonal,
                        object: self,
                        userInfo: nil
                    )
                    break
                case "medical":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.profileEditMedical,
                        object: self,
                        userInfo: nil
                    )
                    break
                case "contacts":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.profileEditContacts,
                        object: self,
                        userInfo: nil
                    )
                    break
                case "emergency":
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.profileEditEmergency,
                        object: self,
                        userInfo: nil
                    )
                    break
                default:
                    break
                }
                return
            }
        }
        
        
        if let cid: String = config["id"]! as? String {
            switch cid {
            case "setup":
                NotificationCenter.default.post(
                    name: LSQ.notification.action.continueSetup,
                    object: self,
                    userInfo: nil
                )
            case "lifesquare":
                NotificationCenter.default.post(
                    name: LSQ.notification.show.lifesquare,
                    object: self,
                    userInfo:[
                        "patientId": self.data!["profile"]["uuid"].string!
                    ]
                )
            case "network-inbound":
                NotificationCenter.default.post(
                    name: LSQ.notification.show.lifesquare,
                    object: self,
                    userInfo:[
                        "patientId": self.data!["network"]["granters"][indexPath.row]["granter_uuid"].string!,
                        ]
                )
            case "network-outbound-pending":
                let node: JSON = self.data!["network"]["auditors_pending"][indexPath.row]
                NotificationCenter.default.post(
                    name: LSQ.notification.action.answerConnectionRequest,
                    object: self,
                    userInfo:[
                        "granter_uuid": node["granter_uuid"].string!,
                        "auditor_uuid": node["auditor_uuid"].string!,
                        "auditor_name": node["auditor_name"].string!,
                        "is_provider": node["auditor_provider"].boolValue
                    ]
                )
                break
            case "emergency":
                if self.data!["emergency"].arrayValue.count > 0 {
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.patientFragment,
                        object: self,
                        userInfo: [
                            "patient_id": self.data!["profile"]["uuid"].string!,
                            "type": "emergency",
                            "data": self.data!["emergency"][indexPath.row].object,
                            "editMode": false // this attribute is pointless
                        ]
                    )
                }
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let config: [String: AnyObject] = self.tableConfig[indexPath.section]
        if config["id"]! as? String == "lifesquare" {
            return self.imageSize
        }
        if config["id"]! as? String == "setup" {
            return 88.0
        }
        return 44.0
    }
    
    // I HATE MY LIFE - SO MUCH
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.network.success,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                
                // only respond to the specific object and action
                if notification.userInfo!["object"] as? String == "patientnetwork" {
                    if notification.userInfo!["action"] as? String != "index" {
                        // meh
                        LSQPatientManager.sharedInstance.fetch()
                    }
                }
                if notification.userInfo!["object"] as? String == "collection.patient_contacts" {
                    // we added, deleted, blablabla one of dem contacts
                    // this is mad inefficient, since we're reloading an entire copy
                    // TODO: fix for network success :/
                    LSQPatientManager.sharedInstance.fetch()
                }
                // lol, and also, on emergency contacts son, yea son
                // but what about dat first name sync son
            }
        )
    
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.loaded.patient2, // TODO: it should be (deauthorized) but do that later
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // check if uuid matches though and then reload
                if notification.userInfo!["uuid"] as? String == self.data!["profile"]["uuid"].string! {
                    self.data = LSQPatientManager.sharedInstance.json!
                    self.doubleSecretInit()
                }
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.deauthorize, // TODO: it should be (deauthorized) but do that later
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.navigationController?.popToRootViewController(animated: false)
            }
        )
        
        // TODO: reload patient, so we can "pass the hotness" to our LifeSticker
        // UGGGGGG GUG UG UG UG UG UGU GUG UG UG UG UG
        // this makes me want to do a dispatch on the patient.loaded again, "BECAUSE"
        // we just can't keep asking the server for data
        // and we're not using a singleton model instance
        /*
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.loaded.patient2,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if notification.userInfo!["uuid"]! == self.data!["profile"]["uuid"].string! {
                    self.data = LSQPatientManager.sharedInstance.json!
                    self.doubleSecretInit()
                } else {
                }
            }
        )
         */
        
        // alpha scan data listeners
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.licenseCaptured, // TODO: it should be (deauthorized) but do that later
                object: nil,
                queue: OperationQueue.main
            ) { notification in
//                
//                var handle = setTimeout(1.0, block: { () -> Void in
//                    let alert: UIAlertController = UIAlertController(
//                        title: "License Captured",
//                        message: (notification.userInfo!["data"] as! String),
//                        preferredStyle: .alert)
//                    let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
//                    })
//                    alert.addAction(cancelAction)
//                    self.present(alert, animated: true, completion: nil)
//                })
//
                // what the flip zone
                
                NotificationCenter.default.post(
                    name: LSQ.notification.dismiss.scanImport,
                    object: notification.object,
                    userInfo: nil
                )
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
