//
//  LSQInsuranceViewController.swift
//
//  Created by Charles Mastin on 10/12/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQInsuranceViewController: UITableViewController, UINavigationControllerDelegate {
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
            tableData?.append(["name": "Organization" as AnyObject, "value": kong as AnyObject])
            self.title = "Insurance"//\(kong!)" woot
        }
        // phone *uggg data attributes are so sauced
        if let kong = self.node["phone"].string {
            if kong != "" {
                tableData?.append(["name": "Phone" as AnyObject, "value": kong as AnyObject, "type": "phone" as AnyObject])
            }
        }
        
        if let kong = self.node["policy_code"].string {
            if kong != "" {
                tableData?.append(["name": "ID" as AnyObject, "value": kong as AnyObject])
            }
        }
        
        if let kong = self.node["group_code"].string {
            if kong != "" {
                tableData?.append(["name": "Group" as AnyObject, "value": kong as AnyObject])
            }
        }
        
        if let kong = self.node["policyholder_first_name"].string {
            var name:String = kong
            if let dong = self.node["policyholder_last_name"].string {
                name += " \(dong)"
            }
            if name != "" {
                tableData?.append(["name": "Policy holder" as AnyObject, "value": name as AnyObject])
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
        let rowData = self.tableData?[indexPath.row]
        cell.textLabel?.text = rowData!["value"] as? String
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
