//
//  LSQTouchTermsViewController.swift
//
//  Created by Charles Mastin on 5/26/17.
//

import Foundation
import UIKit

class LSQTouchTermsViewController:UIViewController {
    @IBAction func submit() -> Void {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(
                name: LSQ.notification.action.acceptTouchTerms,
                object: self
            )
        })
    }
    @IBAction func cancel() -> Void {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(
                name: LSQ.notification.action.declineTouchTerms,
                object: self
            )
        })
    }
}
