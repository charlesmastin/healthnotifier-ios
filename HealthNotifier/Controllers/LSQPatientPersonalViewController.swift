//
//  LSQPatientPersonalViewController.swift
//
//  Created by Charles Mastin on 8/3/16.
//

import Foundation
import UIKit
import SwiftyJSON
import Kingfisher

class LSQPatientPersonalViewController: UITableViewController, UINavigationControllerDelegate {
    
    // The entier "model" of the patient data
    var data: JSON = JSON.null
    var tableData: [[String: AnyObject]] = []
    var editMode: Bool = false
    var imageSize: CGFloat = 132.0
    var observationQueue: [AnyObject] = []
    
    deinit {
        self.removeObservers()
    }
    
    func addObservers() {
        self.observationQueue = []
    }
    
    func removeObservers() {
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    func tableDataInit(_ value: JSON){
        self.data = value
        
        
        // pending splitting this bad boy out into the wild son - aka an additional dedicated view, most likely this is placeholder
        
        // photo it up son buns
        var attributes: [[String: String]] = []
        let profile: JSON = self.data["profile"]
        
        /*
         Photo Son
         Charles Johnson Whacker
         36 years old Male
         Blood Type B+
         */
        
        // if we have the photo son otherwise, save da space son
        // we are explicitly handling, but we don't need toooo
        if let _: String = profile["photo_uuid"].string {
            attributes.append(
                [
                    "photo": "\((profile["photo_url"].string)!)&width=\(Int(self.imageSize * 2))&height=\(Int(self.imageSize * 2))"
                ]
            )
        } else {
            attributes.append(
                [
                    "photo": "\((profile["photo_url"].string)!)?width=\(Int(self.imageSize * 2))&height=\(Int(self.imageSize * 2))"
                ]
            )
        }
        // Fullname son
        if let fullname = profile["fullname"].string {
            attributes.append(
                ["name": "Name", "value": "\(fullname)"]
            )
        }
        
        // age and gender son buns, we def have age, maybe not gender
        if let age = profile["age"].string {
            if let gender = profile["gender"].string {
                let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "gender", value: gender)
                attributes.append(["name": "Age", "value": "\(age) \(formattedDonkey)"])
            } else {
                attributes.append(["name": "Age", "value": "\(age)"])
            }
        }
        
        // Blood type
        // TEMP workaround here
        if let donkey = profile["blood_type"].string {
            let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "blood_type", value: donkey)
            attributes.append(["name": "Blood Type", "value": "Blood Type \(formattedDonkey)"])
        }
        
        // profile
        self.tableData = []
        var n:[String: AnyObject] = [:]
        n["header"] = "Profile" as AnyObject
        n["id"] = "vitals" as AnyObject
        n["data"] = attributes as AnyObject
        self.tableData.append(n)
        
        // probably will crash
        if self.data["alert_medications"].exists() && (self.data["alert_medications"].array)!.count > 0 {
            var n:[String: AnyObject] = [:]
            n["header"] = "Alert Medications" as AnyObject
            n["id"] = "alert_medications" as AnyObject
            self.tableData.append(n)
        }
        
        if self.data["directives"].exists() && (self.data["directives"].array)!.count > 0 {
            var n:[String: AnyObject] = [:]
            n["header"] = "Directives" as AnyObject
            n["id"] = "directives" as AnyObject
            self.tableData.append(n)
        }
        
        if let biometrics_restricted = profile["biometrics_restricted"].bool {
            if biometrics_restricted == false {
                
                var attributes:[[String: String]] = []
                
                if let height = profile["height"].number {
                    attributes.append(["name": "Height", "value": "\(height) cm / \(LSQ.formatter.heightToImperial(Int(height)))"])
                }
                
                if let weight = profile["weight"].double {
                    attributes.append(["name": "Weight", "value": "\(Int(weight)) kg / \(LSQ.formatter.weightToImperial(weight)) lbs"])
                }
                
                // blood type TODO: formatting values api
                if let donkey = profile["blood_type"].string {
                    attributes.append(["name": "Blood Type", "value": "\(donkey)"])
                }
                // bp
                if let diastolic = profile["bp_diastolic"].number {
                    if let systolic = profile["bp_systolic"].number {
                        attributes.append(["name": "BP", "value": "\(diastolic)/\(systolic) mmHg"])
                    }
                }
                
                // pulse
                if let pulse = profile["pulse"].number {
                    attributes.append(["name": "Pulse", "value": "\(pulse) bpm"])
                }
                // hair
                if let hair = profile["hair_color"].string {
                    attributes.append(["name": "Hair", "value": "\(hair)"])
                }
                // eyes
                if let eye_color_both = profile["eye_color_both"].string {
                    attributes.append(["name": "Eyes", "value": "\(eye_color_both)"])
                }
                
                if attributes.count > 0 {
                    var n:[String: AnyObject] = [:]
                    n["header"] = "Biometrics" as AnyObject
                    n["id"] = "biometrics" as AnyObject
                    n["data"] = attributes as AnyObject
                    self.tableData.append(n)
                }
                
            }
        
        }
        
        if let demographics_restricted = profile["demographics_restricted"].bool {
            if demographics_restricted == false {
                
                var attributes:[[String: String]] = []
                
                if let birthdate = profile["birthdate"].string {
                    attributes.append(["name": "DOB", "value": "\(birthdate)"])
                }
                
                if let gender = profile["gender"].string {
                    let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "gender", value: gender)
                    attributes.append(["name": "Gender", "value": "\(formattedDonkey)"])
                }
                // race TODO: values api (client or server)
                if let ethnicity = profile["ethnicity"].string {
                    let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "ethnicity", value: ethnicity)
                    attributes.append(["name": "Race", "value": "\(formattedDonkey)"])
                }
                
                if attributes.count > 0 {
                    var n:[String: AnyObject] = [:]
                    n["header"] = "Demographics" as AnyObject
                    n["id"] = "demographics" as AnyObject
                    n["data"] = attributes as AnyObject
                    self.tableData.append(n)
                }
            }
        }
        
        let languages: Array<JSON> = self.data["languages"].arrayValue
        if languages.count > 0 {
            var attributes:[[String: String]] = []
            
            for language in languages {
                if let lang = language["title"].string {
                    if let proficiency = language["description"].string {
                        attributes.append(["name": "\(proficiency)", "value": "\(lang)"])
                    }
                }
            }
            
            if attributes.count > 0 {
                var n:[String: AnyObject] = [:]
                n["header"] = "Spoken Languages" as AnyObject
                n["id"] = "languages" as AnyObject
                n["data"] = attributes as AnyObject
                self.tableData.append(n)
            }

        }
        
        let addresses: Array<JSON> = self.data["addresses"].arrayValue
        if addresses.count > 0 {
            var attributes:[[String: String]] = []
                        
            for address in addresses {
                if let title = address["title"].string {
                    if let description = address["description"].string {
                        attributes.append(["name": "\(description)", "value": "\(title)"])
                    }
                    //attributes.append(["name": "\((address["residence_type"].string)!)", "value": "\(address1), \((address["city"].string)!), \((address["state_province"].string)!) \((address["postal_code"].string)!)"])
                }
            }
            
            if attributes.count > 0 {
                var n:[String: AnyObject] = [:]
                n["header"] = "Addresses" as AnyObject
                n["id"] = "addresses" as AnyObject
                n["data"] = attributes as AnyObject
                self.tableData.append(n)
            }
        }
        
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        
        tableView.register(UINib(nibName: "CellProfilePhoto", bundle: nil), forCellReuseIdentifier: "CellProfilePhoto")
        
        // override dat stuffs
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        // tuck it tuck it, move it up based on the empty grouped header area
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData[section]["header"] as? String
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // WTF
        // http://stackoverflow.com/questions/18880341/why-is-there-extra-padding-at-the-top-of-my-uitableview-with-style-uitableviewst
        let key = tableData[section]
        if key["id"] as? String == "vitals" {
            return CGFloat.leastNormalMagnitude // still visible, but smallest that isn't 0, lol zone hack central population 1
        }
        var height = UITableViewAutomaticDimension
        
        if section == 0, let header = tableView.headerView(forSection: section) {
            if let label = header.textLabel {
                // get padding below label
                let bottomPadding = header.frame.height - label.frame.origin.y - label.frame.height
                // use it as top padding
                height = label.frame.height + (2 * bottomPadding)
            }
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = tableData[section]
        if key["id"] as? String == "directives" {
            return (self.data["directives"].array)!.count
        }
        if key["id"] as? String == "alert_medications" {
            return (self.data["alert_medications"].array)!.count
        }
        return key["data"]!.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let config = self.tableData[indexPath.section]
        
        if config["id"] as? String == "vitals" && indexPath.row == 0 {
            return self.imageSize + 44
        }
        if config["id"] as? String == "vitals" {
            
            // if we are the last, or just in the middle
            if indexPath.row == config["data"]!.count - 1 {
                return 33.0
            }
            return 33.0
            
        }
        // TBD for address and multiline
        return 44.0
    }
    
    func handleTap(_ sender: UITapGestureRecognizer?) {
        let url:String = self.data["profile"]["photo_url"].string!
        NotificationCenter.default.post(
            name: LSQ.notification.show.patientPhoto,
            object: self,
            userInfo: [
                "URL": url
            ]
        )
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let key = self.tableData[indexPath.section]
        if key["id"] as? String == "vitals" {
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellProfilePhoto", for: indexPath) as! LSQProfileVitalsTableViewCell
                cell.backgroundColor = LSQ.appearance.color.stolenBlue
                cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.width/2.0, 0, tableView.bounds.width/2.0)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                let placeholder = UIImage(named: "selfie_image")
                cell.profilePhoto!.contentMode = UIViewContentMode.scaleAspectFill
                cell.profilePhoto!.kf.setImage(
                    with: URL(string: (key["data"] as! [[String:String]])[indexPath.row]["photo"]! as String),
                    placeholder: placeholder,
                    options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)]
                )
                
                // http://stackoverflow.com/questions/29173116/swift-mask-of-circle-layer-over-uiview
                let innerFrame = CGRect(x: 0, y: 0, width: self.imageSize - 2, height: self.imageSize - 2)
                let maskLayer = CAShapeLayer()
                let circlePath = UIBezierPath(roundedRect: innerFrame, cornerRadius: innerFrame.width)
                maskLayer.path = circlePath.cgPath
                maskLayer.fillColor = LSQ.appearance.color.blue.cgColor
                
                let strokeLayer = CAShapeLayer()
                strokeLayer.path = circlePath.cgPath
                strokeLayer.fillColor = UIColor.clear.cgColor
                strokeLayer.strokeColor = LSQ.appearance.color.white.cgColor
                strokeLayer.lineWidth = 2
                
                // add the layer
                cell.profilePhoto!.layer.addSublayer(maskLayer)
                cell.profilePhoto!.layer.mask = maskLayer
                cell.profilePhoto!.layer.addSublayer(strokeLayer)
                
                cell.profilePhoto!.isUserInteractionEnabled = true
                // tap handler son
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                // tap.delegate = self
                cell.profilePhoto!.addGestureRecognizer(tap)
                
                return cell
                
            } else {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell_bigtime")
                cell.backgroundColor = LSQ.appearance.color.stolenBlue
                //cell.separatorInset = UIEdgeInsetsZero
                //cell.preservesSuperviewLayoutMargins = false
                //cell.layoutMargins = UIEdgeInsetsZero
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.textLabel?.text = (key["data"] as! [[String: String]])[indexPath.row]["value"]! as String
                cell.textLabel?.textColor = LSQ.appearance.color.white
                cell.textLabel?.textAlignment = NSTextAlignment.center
                if indexPath.row == 1 {
                    // TODO: FONT SIZE
                    //cell.textLabel?.font = UIFont(name: (cell.textLabel?.font.fontName)!, size: 20.0)
                }
                return cell
            }
        } else {
            var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "cell_default")
            //cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
        
            if key["id"] as? String != "directives" && key["id"] as? String != "alert_medications" {
                // your typical row here son
                cell.textLabel?.text = (key["data"] as! [[String: String]])[indexPath.row]["name"]! as String
                cell.textLabel?.textColor = LSQ.appearance.color.gray0
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
                cell.detailTextLabel?.text = (key["data"] as! [[String: String]])[indexPath.row]["value"]! as String
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            }
            if key["id"] as? String == "directives" {
                if self.data["directives"][indexPath.row]["error"].exists() {
                    //cell.textLabel?.text = "Privacy Restricted Item"
                    cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
                    cell.detailTextLabel?.text = "Privacy Restricted - Ask patient"
                    // STRAIGHT UI abuse here
                    // too much?
                    cell.accessoryType = UITableViewCellAccessoryType.detailButton
                } else {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_directive")
                    if let category = self.data["directives"][indexPath.row]["category"].string {
                        let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("directive", attribute: nil, value: category)
                        cell.textLabel?.text = formattedDonkey
                    }
                    cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
                    if let pages = self.data["directives"][indexPath.row]["pages"].number {
                        if pages.intValue > 1 {
                            cell.detailTextLabel?.text = "\(pages) Pages"
                        } else {
                            cell.detailTextLabel?.text = "1 Page"
                        }
                    }
                    // cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                }
            }
            if key["id"] as? String == "alert_medications" {
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_alertmed")
                cell.textLabel?.text = self.data["alert_medications"][indexPath.row]["title"].string
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.accessoryType = UITableViewCellAccessoryType.detailButton
            }
            
            // SO THE COMPILER DOESN'T GET DEM PANTIES IN A BUNCH
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let key = self.tableData[indexPath.section]
        if key["id"] as? String == "vitals" {
            let size = self.view.bounds.size
            let rightInset = size.width > size.height ? size.width : size.height
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, rightInset)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // but for now, hit up dat first question group son!
        // hot damn hack
        let key: String = (self.tableData[indexPath.section]["id"] as? String)!
        if key == "directives" {
            
            if self.data["directives"][indexPath.row]["error"].exists() {
            } else {
                // DEFEND AGAINST PRIVACY SON SON SON SON SON SON SON
                // DRY UP DRY UP DRY UP
                NotificationCenter.default.post(
                    name: LSQ.notification.show.document,
                    object: self,
                    userInfo: [
                        "URL": "https://api.domain.com/api/v1/documents/\((self.data["directives"][indexPath.row]["uuid"].string)!)/#file-0" // TODO: complete mega super hack here
                    ]
                )
            }
            
        }
        
    }
    
}
