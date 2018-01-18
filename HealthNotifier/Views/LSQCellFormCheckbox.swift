//
//  LSQCellFormCheckbox.swift
//
//  Created by Charles Mastin on 10/25/16.
//

// CURRENT LIMITATION / DESIGN GOAL, only boolean, only one per attribute

import Foundation
import UIKit

class LSQCellFormCheckbox: UITableViewCell {
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var label2: UILabel?
    @IBOutlet weak var input: UISwitch?
    
    var id: String = "field"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.label2?.isHidden = true
        self.input?.addTarget(self, action: #selector(self.onChange(_:)), for: UIControlEvents.valueChanged)
    }
    
    // this is so misleading AF
    // but iOS already has setValue blabla so whatever
    func setInitial(_ value: Bool) -> Void {
        if value {
            self.input?.setOn(true, animated: false)
        }else {
            self.input?.setOn(false, animated: false)
        }
    }
    
    func onChange(_ switcheroo: UISwitch) -> Void {
        // value in text form, to be interpreted downstream SON
        NotificationCenter.default.post(
            name: LSQ.notification.form.field.change,
            object: self,
            userInfo: [
                "id": self.id,
                "value": switcheroo.isOn
            ]
        )
    }
    
}
