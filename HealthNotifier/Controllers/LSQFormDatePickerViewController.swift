//
//  LSQFormDatePickerViewController.swift
//
//  Created by Charles Mastin on 12/8/16.
//

import Foundation
import UIKit

class LSQFormDatePickerViewController: UIViewController {
    var value: Date? = nil
    var id: String = "mydatefield"
    
    @IBOutlet weak var picker: UIDatePicker!
    @IBAction func actionDone(){
        NotificationCenter.default.post(
            name: LSQ.notification.form.field.change,
            object: self,
            userInfo: [
                "id": self.id,
                "value": LSQ.formatter.dateToString((self.picker?.date)!)
            ]
        )
        self.close()
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.value != nil {
            self.picker?.setDate(self.value!, animated: false)
        }
    }
}
