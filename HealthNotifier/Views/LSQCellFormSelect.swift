//
//  LSQCellFormSelect.swift
//
//  Created by Charles Mastin on 10/25/16.
//

import Foundation
import UIKit

class LSQCellFormSelect: UITableViewCell {
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var span: UILabel?
    @IBOutlet weak var label2: UITextField!
    
    var id: String = "field"
    //
    var value: String = ""
    var values: [[String: AnyObject]] = []

    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectionStyle = UITableViewCellSelectionStyle.default
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
    
    deinit {
        self.removeObservers()
    }

    func setInitial(_ value: String) -> Void {
        var found: Bool = false
        for obj in self.values {
            if obj["value"] as? String == value {
                self.span?.text = String(describing: obj["name"]!)
                self.label2.text = String(describing: obj["name"]!)
                found = true
            }
        }
        if !found {
//            self.span?.text = "–"
            self.label2.text = ""
        }
    }
    
}
