//
//  LSQNearbyViewController.swift
//
//  Created by Charles Mastin on 3/19/16.
//

import Foundation
import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire
import EZLoadingActivity

class LSQNearbyViewController: UITableViewController, UISearchBarDelegate {
    
    var patientsJson: JSON?
    var patientsLoaded: Bool = false
    var patientsLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Search"
        // self.tableView = UITableView(frame: self.tableView.frame, style: .Grouped)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LSQNearbyViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LSQLocationManager.sharedInstance.start()
        // listen for updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LSQNearbyViewController.handleLocationUpdate(_:)),
            name: LSQ.notification.location.update,
            object: nil
        )
        // immediately fire of a request to get data, because we might have a cached location
        // TODO: don't do this just like this, and branch based on having seacrh terms input
        // also pull to refresh will help here, as we don't need to reissue the load unless we have a significant change
        // we should store the notion of had significant change on our Location Manager as well
        self.fetchResults()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LSQLocationManager.sharedInstance.stop()
        // stop listening for updates here as well
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTable: UITableView!
    
    @IBAction func updateLocationResults(_ sender: AnyObject?) {
        // grab latest location, and re-render table, specific with location results
        // not sure if we even need this other than to zero out the search terms
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.fetchResults()
    }
    
    @IBAction func refresh(_ refreshControl: UIRefreshControl) {
        // lock this in some blocking business :) for now, just a cheesy class variable
        // vs checking the underlying AFN since we don't have a reference to that shiz
        if !self.patientsLoading {
            self.fetchResults(self.searchBar.text!.lowercased())
        } else {
            // TODO: throw in a timer, or queue
        }
        refreshControl.endRefreshing()
    }
    
    func handleLocationUpdate(_ notification: Notification?) {
        // this can be a race condition or annoying UX glitch if we're midway through querying a regular search
        // and we suddendly receive a location update, just sayin
        if !self.patientsLoading {
            self.fetchResults()
        } else {
            // TODO: throw in a timer, or queue
        }
    }
    
    func fetchResults(_ query:String = "") {
        
        // TODO: first case of needing to store a reference to our callback son
        func success(_ response: AnyObject) -> Void {
            EZLoadingActivity.hide(true, animated: true)
            
            self.patientsLoading = false
            self.patientsJson = JSON(response as! [AnyHashable: Any])
            self.patientsLoaded = true
            self.resultsTable?.reloadData()
            
            let user: LSQUser = LSQUser.currentUser
            var event: String = "Nearby"
            if query != "" {
                event = "Search"
            }
            
            // TODO: replace with some inline blank states!
            if self.patientsJson?["Lifesquares"].arrayValue.count == 0 {
                
                if event == "Nearby" {
                    // Do nothing
                    // message = ""
                    // TODO: in the future we could promp to enable location services if they are off?
                }
                if event == "Search" {
                    let title: String = "No LifeStickers Found"
                    let message: String = "Please refine your terms. First and Last name, email, or street address"
                    var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                        preferredStyle = UIAlertControllerStyle.actionSheet
                    }
                    let alert: UIAlertController = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: preferredStyle)
                    
                    let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                        // nothing here
                    })
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            NotificationCenter.default.post(
                name: LSQ.notification.analytics.event,
                object: self,
                userInfo: [
                    "event": event,
                    "attributes": [
                        "AccountId": user.uuid!,
                        "Provider": user.provider,
                        "Results": (self.patientsJson?["Lifesquares"].arrayValue.count)!
                    ]
                ]
            )
        }
        
        func failure(_ response: AnyObject) -> Void {
            self.patientsLoading = false
            EZLoadingActivity.hide(false, animated: true)
        }
        
        if query != "" {
            // regular search
            // ok, method signature cleanup in the calling if not nil basically
            if let location: CLLocation = LSQLocationManager.sharedInstance.lastLocation {
                LSQAPI.sharedInstance.searchLifesquares(
                    query,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    success: success,
                    failure: failure
                )
            } else {
                LSQAPI.sharedInstance.searchLifesquares(
                    query,
                    success: success,
                    failure: failure
                )
            }
            
            EZLoadingActivity.show("", disableUI: false)
            self.patientsLoading = true
        } else {
            // nearby
            if let location: CLLocation = LSQLocationManager.sharedInstance.lastLocation {
                
                LSQAPI.sharedInstance.nearbyLifesquares(
                    location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    success: success,
                    failure: failure
                )
                
                EZLoadingActivity.show("", disableUI: false)
                self.patientsLoading = true
            } else {
                // we didn't have a location yet, just chill, it will come
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // self.fetchResults(searchText.lowercaseString)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.fetchResults(self.searchBar.text!.lowercased())
    }
    
    // MARK: Table stuffs
    
    // TODO: handle no results found text
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // tremendous hack here
        if self.patientsLoaded {
            return (self.patientsJson?["Lifesquares"].count)!
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LSQLifesquareDetailsViewCell = self.resultsTable.dequeueReusableCell(withIdentifier: "LSQSearchResultCell", for: indexPath) as! LSQLifesquareDetailsViewCell
        /*
        if cell {
            
        } else {
            self.resultsTable.registerClass(LSQLifesquareDetailsViewCell.classForCoder(), forCellReuseIdentifier: "LSQSearchResultCell")
            var cell = LSQLifesquareDetailsViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "LSQSearchResultCell")
        }
        */
        var name: String = "Unknown Name"
        var address: String = "Unknown Address"
        var lifesquareLocation: String = "Unknown"
        if self.patientsJson != nil {
            if let patient = self.patientsJson?["Lifesquares"][indexPath.row] {
                if let firstname = patient["FirstName"].string {
                    if let lastname = patient["LastName"].string {
                        name = firstname + " " + lastname
                    }
                }
                if patient["Residence"] != JSON.null {
                    address = ""
                    if let address1 = patient["Residence"]["Address1"].string {
                        if address1 != "" {
                            address = address1
                        }
                    }
                    if let address2 = patient["Residence"]["Address2"].string {
                        if address2 != "" {
                            address = address + " " + address2
                        }
                    }
                    if let city = patient["Residence"]["City"].string {
                        if city != "" {
                            address = address + ", " + city
                        }
                    }
                    if let state = patient["Residence"]["State"].string {
                        if state != "" {
                            address = address + ", " + state
                        }
                    }
                    if let postal = patient["Residence"]["Postal"].string {
                        if postal != "" {
                            address = address + " " + postal
                        }
                    }
                    // API defaults to empty string in this case but we could be more fault tolerant for a null json value
                    if let loc = patient["Residence"]["LifesquareLocation"].string {
                        lifesquareLocation = loc
                    }
                }
            }
        }
        
        cell.titleTextLabel!.text = name
        cell.addressTextLabel!.text = address
        cell.locationTextLabel!.text = "LifeSticker Location: " + lifesquareLocation
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchBar.text == "" {
            if self.patientsLoaded && self.patientsJson != nil && self.patientsJson?["Lifesquares"] != JSON.null {
                if let count = self.patientsJson?["Lifesquares"].arrayValue.count {
                    return "Nearby LifeStickers (\(count))"
                } else {
                    return "Nearby LifeStickers"
                }
            }else {
                return "Nearby LifeStickers"
            }
        } else {
            if self.patientsLoaded && self.patientsJson != nil && self.patientsJson?["Lifesquares"] != JSON.null {
                if let count = self.patientsJson?["Lifesquares"].arrayValue.count {
                    return "LifeStickers Matching Search (\(count))"
                } else {
                    return "LifeStickers Matching Search"
                }
            }else {
                return "LifeStickers Matching Search"
            }
        }
    }
    
}
