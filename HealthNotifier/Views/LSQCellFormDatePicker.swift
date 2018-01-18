//
//  LSQCellFormDatePicker.swift
//
//  Created by Charles Mastin on 12/8/16.
//

import Foundation
import UIKit

class LSQCellFormDatePicker: UITableViewCell {
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var span: UILabel?
    @IBOutlet weak var label2: UITextField!
    var id: String = "field"
    //
    var value: String = ""
    // allow future
    // min date
    // max date
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectionStyle = UITableViewCellSelectionStyle.default
    }
    var observationQueue: [AnyObject] = []
    // lul zone
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.form.field.change,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if notification.userInfo!["id"] as! String == self.id {
                    // OMG SON, passing dates as strings, it works though k story
                    self.setInitial(String(describing: notification.userInfo!["value"]!))
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
    
    func setInitial(_ value: String) -> Void {
        self.span?.text = value
        self.label2.text = value
    }
}
