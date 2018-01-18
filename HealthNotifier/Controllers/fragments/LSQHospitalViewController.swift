//
//  LSQHopsitalViewController.swift
//
//  Created by Charles Mastin on 10/12/16.
//

import Foundation
import UIKit
import SwiftyJSON



class LSQHospitalViewController: UITableViewController, UINavigationControllerDelegate {
    // data comes in as JSON fragment
    var data: AnyObject? = nil
    var node: JSON!
    // basically just do the customized table rendering here
    var tableData: [[String: AnyObject]]? = nil
    
    func tableDataInit(_ value: JSON){
        //self.data = value
        self.node = value
        
        tableData = []
        
        // name use (title helper for now)
        if let kong = self.node["title"].string {
            if kong != "" {
                tableData?.append(["name": "Name" as AnyObject, "value": kong as AnyObject])
                self.title = "Hospital"//\(kong!)"
            }
        }
        
        // MEGA SUPER MEGA CLASS FOR ALL THE THINGS
        // prentending to be a Physician son
        // CRASH WORTHY EDITION
        // TODO: needs values API
        //if self.data?["care_provider_class"] != nil {
        if let kong = self.node["care_provider_class"].string {
            if kong != "" {
                tableData?.append(["name": "Specialty" as AnyObject, "value": kong as AnyObject])
            }
        }
        //}
        
        // phone *uggg data attributes are so sauced
        
        if let kong = self.node["phone"].string {
            if kong != "" {
                tableData?.append(["name": "Phone" as AnyObject, "value": kong as AnyObject, "type": "phone" as AnyObject])
            }
        }
        
        
        if let kong = self.node["phone1"].string {
            if kong != "" {
                tableData?.append(["name": "Phone" as AnyObject, "value": kong as AnyObject, "type": "phone" as AnyObject])
            }
        }
        
        //if self.data?["medical_facility_name"] != nil {
        if let kong = self.node["medical_facility_name"].string {
            if kong != "" {
                tableData?.append(["name": "Facility" as AnyObject, "value": kong as AnyObject])
            }
        }
        //}
        
        
        if let kong = self.node["address_line1"].string {
            var address = ""
            var lines = 0
            if kong != "" {
                address += kong
                lines += 1
            }
            if let dong = self.node["address_line2"].string {
                address += "\n\(dong)"
                lines += 1
            }
            if let dong = self.node["city"].string {
                address += "\n\(dong)"
                lines += 1
            }
            if let dong = self.node["state_province"].string {
                address += ", \(dong)"
            }
            if let dong = self.node["postal_code"].string {
                address += " \(dong)"
            }
            
            // TODO: embed a map in da future son
            tableData?.append(["name": "Address" as AnyObject, "value": "\(address)" as AnyObject, "type": "address" as AnyObject, "lines": lines as AnyObject])
            
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowData = self.tableData?[indexPath.row]
        if rowData!["type"] != nil && rowData!["type"] as! String == "address" {
            return 88.0
        }
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla")
        let rowData = self.tableData?[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = rowData!["value"] as? String
        cell.textLabel?.sizeToFit()
        cell.detailTextLabel?.text = rowData!["name"] as? String
        
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
