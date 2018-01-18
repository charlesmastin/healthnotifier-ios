//
//  LSQEmergencyContactViewController.swift
//
//  Created by Charles Mastin on 10/12/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQEmergencyContactViewController: UITableViewController, UINavigationControllerDelegate {
    // data comes in as JSON fragment
    var node: JSON!
    // basically just do the customized table rendering here
    var tableData: [[String: AnyObject]]? = nil
    
    // handle generic close action son, lol, don't need it, because we're a pushed View Controller YE YE EYEYEYEYE
    
    func tableDataInit(_ value: JSON){
        self.node = value
        tableData = []
        
        // name use (title helper for now)
        if let kong = self.node["title"].string {
            tableData?.append(["name": "Name" as AnyObject, "value": kong as AnyObject])
            self.title = "Contact"//\(kong!)"
        }
        /*
        if self.data?["first_name"] != nil && self.data?["last_name"] != nil {
            if let donkey = self.data?["first_name"] {
                if let kong = self.data?["last_name"] {
                    tableData?.append(["name": "Name", "value": "\(donkey) \(kong)"])
                }
            }
        }
        */
        
        if let kong = self.node["contact_relationship"].string {
            if kong != "" {
                let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("patient_contact", attribute: "relationship", value: kong)
                tableData?.append(["name": "Relationship" as AnyObject, "value": "\(formattedDonkey)" as AnyObject])
            }
        }
        
        // phone *uggg data attributes are so sauced
        if let kong = self.node["home_phone"].string {
            if kong != "" {
                tableData?.append(["name": "Phone" as AnyObject, "value": kong as AnyObject, "type": "phone" as AnyObject])
            }
        }
        
        if let kong = self.node["mobile_phone"].string {
            if kong != "" {
                tableData?.append(["name": "Phone" as AnyObject, "value": kong as AnyObject, "type": "phone" as AnyObject])
            }
        }
        
        // email ??
        if let kong = self.node["email"].string {
            if kong != "" {
                tableData?.append(["name": "Email" as AnyObject, "value": kong as AnyObject, "type": "email" as AnyObject])
            }
        }
        
        // power of attorney
        if let kong = self.node["power_of_attorney"].bool {
            if kong {
                tableData?.append(["name": "Power of Attorney" as AnyObject, "value": "Yes" as AnyObject])
            }
        }
        
        // next of kin, blablabla
        if let kong = self.node["next_of_kin"].bool {
            if kong {
                tableData?.append(["name": "Next of Kin" as AnyObject, "value": "Yes" as AnyObject])
            }
        }
        
        self.tableView.reloadData()
    }

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.tableData?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla")
        // TODO: FLIPPED STYLE ON DEEZE NUTS
        let rowData = self.tableData?[indexPath.row]
        cell.textLabel?.text = rowData!["value"] as? String
        cell.detailTextLabel?.text = rowData!["name"] as? String
        cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
        if rowData!["type"] != nil && (rowData!["type"] as! String == "phone" || rowData!["type"] as! String == "email") {
            // cell.accessoryType = UITableViewCellAccessoryType
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // super questionable hack zone for handling calling
        let rowData = self.tableData?[indexPath.row]
        if rowData!["type"] != nil && rowData!["type"] as! String == "phone" {
            LSQ.launchers.phone(rowData!["value"] as! String)
        }
        if rowData!["type"] != nil && rowData!["type"] as! String == "email" {
            LSQ.launchers.email(rowData!["value"] as! String)
        }
    }

}
