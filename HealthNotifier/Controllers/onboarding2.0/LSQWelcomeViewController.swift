//
//  LSQWelcomeViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit

class LSQWelcomeViewController : LSQOnboardingBaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = LSQ.appearance.color.newBlue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func onContinue(_ sender: UIButton?){
        NotificationCenter.default.post(
            name: LSQ.notification.show.login,
            object: self,
            userInfo: nil
        )
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        NotificationCenter.default.post(
            name: LSQ.notification.show.onboardingAccount,
            object: self,
            userInfo: nil
        )
    }
}
