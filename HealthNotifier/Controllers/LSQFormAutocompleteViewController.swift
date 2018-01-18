//
//  LSQFormAutocompleteViewController.swift
//
//  Created by Charles Mastin on 10/31/16.
//

import Foundation
import UIKit
import SwiftyJSON

/*
// Simple usage
let handle = setTimeout(0.35, block: { () -> Void in
    // do this stuff after 0.35 seconds
})

// Later on cancel it
handle.invalidate()
*/

class LSQFormAutocompleteViewController : UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var results: Array<JSON> = [] // what the f son
    var prefilledResults: Array<JSON> = []
    var id: String = "fieldid"
    var value: String = "astringversionofthevalue"
    var autocompleteId: String = "medication"
    var handle: AnyObject? = nil
    
    // async messaging for results
    var observationQueue: [AnyObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LSQOnboardingManager.sharedInstance.active {
            // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        //self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.title = self.autocompleteId.capitalized
        self.searchBar.placeholder = "Search by name"
        self.searchBar.delegate = self
        // set the focus to the searchBar son
        // if we have prefill, else
        // TODO: but why does the search bar dissappear
        self.prefill()
    }
    
    //
    func prefill(){
        // if cached results, use those bro
        
        var category:String = ""
        if self.autocompleteId == "medication" || self.autocompleteId == "therapy" {
            category = "medication"
        }
        if self.autocompleteId == "allergy" || self.autocompleteId == "allergen" {
            category = "allergy"
        }
        if self.autocompleteId == "immunization" {
            category = "immunization"
        }
        if self.autocompleteId == "device" {
            category = "device"
        }
        if self.autocompleteId == "condition" {
            category = "condition"
        }
        if self.autocompleteId == "procedure" {
            category = "procedure"
        }
        if category == "" {
            self.searchBar.becomeFirstResponder()
        } else {
            // common loading, then cache the results bro
            LSQAPI.sharedInstance.getPopularTerms(
                LSQPatientManager.sharedInstance.uuid!,
                category: category,
                success: { response in
                    let j:JSON = JSON(response)
                    var r:[JSON] = []
                    for (index, object) in j["results"] {
                        r.append(object)
                    }
                    self.prefilledResults = r
                    self.tableView.reloadData()
                },
                failure: { response in
                    // meh
                }
            )
        }
        //self.searchBar.becomeFirstResponder()
    }
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.loaded.autocomplete,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // inspect the action of the payload or something son to ensure it's an autocomplete request
                // also we should pass along a request token for dis, or some form of calling object yea son
                // so we know it was intended for this here class
                self.handleResults(notification.userInfo!["results"]! as AnyObject)
            }
        )
        // the clear observer so we can reset the prefil brolo
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

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: performance test this
        if self.handle != nil {
            self.handle?.invalidate()
            self.handle = nil
        }
        if searchText == "" {
            self.results = []
            self.prefill()
            self.tableView.reloadData()
        } else {
            self.handle = setTimeout(0.35, block: { () -> Void in
                // do this stuff after 0.35 seconds
                // meh, this seems like the problem here
                self.fetchResults(searchText)
            })
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.fetchResults(searchBar.text!)
    }
    
    // this is not executed because we're not doing the SearchBarController thingy
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.results = []
        self.prefill()
        self.tableView.reloadData()
    }
    
    func fetchResults(_ query: String) -> Void {
        // tap dat LSQAPI2, look for a nice JW on the API endpoint
        LSQAPI.sharedInstance.getAutocomplete(self.autocompleteId, query: query)
    }
    
    // if we need to transform the datastructure for any reason before reloading the table
    func handleResults(_ results: AnyObject) -> Void {
        // TODO: this data coming from the API is WAY WAY WAY WAY WAY WAY too specific to the query
        var r = JSON(results)
        if r["combinations"].exists() {
            self.results = r["combinations"].arrayValue
        } else {
            self.results = []
        }
        self.prefilledResults = []
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // hook the other guy
        if self.prefilledResults.count > 0 {
            return self.prefilledResults.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //let config: [String: AnyObject] = self.tableConfig[section]
        if self.prefilledResults.count > 0 {
            if let name = self.prefilledResults[section]["name"].string {
                return name
            }
        }
        if self.results.count > 0 {
            return "Search Results"
        } else {
            // only if there was a search term though
            if self.searchBar.text != "" {
                return "No Matches Found"
            }
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.prefilledResults.count > 0 {
            // this is almost certainly crashworthy
            let v = self.prefilledResults[section]["items"].arrayValue
            return v.count
        }
        return self.results.count
    }
    
    // cell for row son
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell_default")
        if self.results.count > 0 {
            cell.textLabel?.text = self.results[indexPath.row]["title"].string!
        }
        if self.prefilledResults.count > 0 {
            if let v = self.prefilledResults[indexPath.section]["items"][indexPath.row]["title"].string {
                cell.textLabel?.text = v
            }
        }
        // TODO: set the accessory view checkbox if we're the current value son
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // GHETTO 2 DA MAX BRO
        if self.prefilledResults.count > 0 {
            NotificationCenter.default.post(
                name: LSQ.notification.form.field.change,
                object: self,
                userInfo: [
                    "id": self.id,
                    "value": self.prefilledResults[indexPath.section]["items"][indexPath.row]["title"].string!,
                    // OVERLOAD YOUR SHIZ
                    "autocompleteValue": self.prefilledResults[indexPath.section]["items"][indexPath.row].object
                ]
            )
        }
        if self.results.count > 0 {
            NotificationCenter.default.post(
                name: LSQ.notification.form.field.change,
                object: self,
                userInfo: [
                    "id": self.id,
                    "value": self.results[indexPath.row]["title"].string!,
                    // OVERLOAD YOUR SHIZ
                    "autocompleteValue": self.results[indexPath.row].object
                ]
            )
        }
        self.close()
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
}
