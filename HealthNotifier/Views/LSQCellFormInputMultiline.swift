//
//  LSQCellFormInputMultiline.swift
//
//  Created by Charles Mastin on 1/19/17.
//

import Foundation
import UIKit

class LSQCellFormInputMultiline: UITableViewCell, UITextViewDelegate {
    //@IBOutlet weak var label: UILabel?
    @IBOutlet weak var input: UITextView?
    
    var id: String = "field"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.input?.delegate = self
        // self.input?.addTarget(self, action: #selector(self.onChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func setInitial(_ value: String) -> Void {
        self.input?.text = value
    }
    
    func textViewDidChange(_ textView: UITextView) {
        NotificationCenter.default.post(
            name: LSQ.notification.form.field.change,
            object: self,
            userInfo: [
                "id": self.id,
                "value": textView.text!
            ]
        )
    }
    
}
