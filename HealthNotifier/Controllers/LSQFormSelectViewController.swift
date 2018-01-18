//
//  LSQFormSelectViewController.swift
//
//  Created by Charles Mastin on 10/25/16.
//

import Foundation
import UIKit

class LSQFormSelectViewController: UITableViewController, UINavigationControllerDelegate {
    // one would think this is a highly commoditized default view controller ready made from Apple, for convenience sake
    // one would be wrong
    // f you apple
    // ------------------------------
    // render a list from our dataprovider
    // show initial state
    // set title
    // handle press and send a notification with the value
    var id: String = "donkdank"
    // RISKY you drink dank
    var value: String = "astringversionofthevalue"
    var values: [[String: AnyObject]] = []
    
    // LSQAPI.sharedInstance.getValues("state").map { [$0["name"]! as! String, $0["value"]! as! String] }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LSQOnboardingManager.sharedInstance.active {
            // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
        }
    }
    
    func pumpWeasel(_ values: [[String: AnyObject]]) {
        self.values = values
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.values.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell_default")
        
        let v: String = (self.values[indexPath.row]["value"])! as! String
        cell.textLabel?.text = self.values[indexPath.row]["name"] as? String
        
        // YEA SON!
        if let description: String = self.values[indexPath.row]["short_description"] as? String {
            cell.detailTextLabel?.text = description
        }
        
        if self.value == v {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(
            name: LSQ.notification.form.field.change,
            object: self,
            userInfo: [
                "id": self.id,
                "value": self.values[indexPath.row]["value"]! // TODO: this is now busted for ints
            ]
        )
        self.close()
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }

}
