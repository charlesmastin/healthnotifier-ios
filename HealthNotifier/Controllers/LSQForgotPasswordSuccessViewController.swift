//
//  LSQForgotPasswordSuccessViewController.swift
//
//  Created by Charles Mastin on 3/1/16.
//

import Foundation
import UIKit

class LSQForgotPasswordSuccessViewController: UIViewController {
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //self.view.backgroundColor = LSQ.appearance.ui.defaultViewBackgroundColor
    }
    
    @IBAction func login(_ sender: UIButton?) {
        NotificationCenter.default.post(name: LSQ.notification.show.login, object: self)
    }
}
