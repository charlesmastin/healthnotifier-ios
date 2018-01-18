//
//  LSQCellFormAutocomplete.swift
//
//  Created by Charles Mastin on 10/31/16.
//

import Foundation
import UIKit

class LSQCellFormAutocomplete: UITableViewCell {
    
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var span: UILabel?
    @IBOutlet weak var label2: UITextField!
    
    // this is specifically a class because we wanted to type check, and because we needed the collectionId
    
    // this is just basically a serious time saver
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.value2, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //self.accessoryView = UITableViewCellAccessoryType.DisclosureIndicator
        //self.detailTextLabel?.textColor = LSQ.appearance.color.blueApple
        //self.detailTextLabel?.text = "+ Add Item"
        self.selectionStyle = UITableViewCellSelectionStyle.default
    }
    
    // LOL SON
    var autocompleteId: String = "meds"
    var id: String = "field"
    
    func setInitial(_ value: String) -> Void {
        self.span!.text = value
        self.label2!.text = value
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
                if notification.userInfo!["id"] as! String == self.id {
                    self.setInitial(String(describing: notification.userInfo!["value"]!))
                    //print(notification.userInfo!["autocompleteValue"]!)
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

    
}
