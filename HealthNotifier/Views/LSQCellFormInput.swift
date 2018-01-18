//
//  LSQCellFormInput.swift
//
//  Created by Charles Mastin on 10/25/16.
//

import Foundation
import UIKit

class LSQCellFormInput: UITableViewCell {
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var input: UITextField?
    
    var id: String = "field"
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectionStyle = UITableViewCellSelectionStyle.none        
        self.input?.addTarget(self, action: #selector(self.onChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    func setInitial(_ value: String) -> Void {
        self.input?.text = value
    }
    
    func onChange(_ textField: UITextField) -> Void {
        // value in text form, to be interpreted downstream SON
        NotificationCenter.default.post(
            name: LSQ.notification.form.field.change,
            object: self,
            userInfo: [
                "id": self.id,
                "value": textField.text!
            ]
        )
    }
}
