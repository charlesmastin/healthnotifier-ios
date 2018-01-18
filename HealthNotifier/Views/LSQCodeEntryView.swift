//
//  LSQCodeEntryView.swift
//
//  Created by Charles Mastin on 3/8/16.
//

import Foundation
import UIKit

class LSQCodeEntryView: UIView {
    @IBOutlet weak var codeField: UITextField!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        setup()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    // http://stackoverflow.com/questions/24036393/fatal-error-use-of-unimplemented-initializer-initcoder-for-class
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LSQCodeEntryView.tap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}
