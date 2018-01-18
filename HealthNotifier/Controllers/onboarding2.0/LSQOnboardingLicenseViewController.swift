//
//  LSQOnboardingLicenseViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation

import UIKit

class LSQOnboardingLicenseViewController : LSQOnboardingBaseViewController {
    
    // this is an exception, since we're looking to move it forward in a special way with a segueue, ugggg break from the norm up in here
    // that said we should incorporate the segue management there
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
    }
    
    @IBAction func onContinue(_ sender: AnyObject?){
        NotificationCenter.default.post(
            name: LSQ.notification.action.nextOnboardingStep,
            object: self,
            userInfo: nil
        )
        /*
        NotificationCenter.default.post(
            name: LSQ.notification.show.onboardingProfile,
            object: self,
            userInfo: nil
        )
        */
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        NotificationCenter.default.post(
            name: LSQ.notification.show.scanImport,
            object: self,
            userInfo: nil
        )
    }
}
