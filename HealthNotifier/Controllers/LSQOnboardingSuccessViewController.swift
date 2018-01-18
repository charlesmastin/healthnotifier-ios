//
//  LSQOnboardingSuccessViewController.swift
//
//  Created by Charles Mastin on 9/10/17.
//

import Foundation
import UIKit

class LSQOnboardingSuccessViewController : LSQOnboardingBaseViewController {
    
    @IBOutlet weak var txtTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(LSQOnboardingSuccessViewController.goBack))
        navigationItem.leftBarButtonItem = backButton
        backButton.isEnabled = false
    }
    
    func goBack(){
        // do nothing bro
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // LSQAppearanceManager.sharedInstance
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
        
        // put in the text ok which should trigger a reload brolo
        //
        //
        // JW TO THE MAX
        if LSQPatientManager.sharedInstance.json != nil {
            if let txt: String = LSQPatientManager.sharedInstance.json!["meta"]["campaign"]["post_signup_memo"].string {
                if txt != "" {
                    self.txtTitle.text = txt
                }
            }
        }
    }
    
    @IBAction func onContinue(_ sender: AnyObject?){
        NotificationCenter.default.post(
            name: LSQ.notification.action.nextOnboardingStep,
            object: self,
            userInfo: nil
        )
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        NotificationCenter.default.post(
            name: LSQ.notification.show.lifesquare,
            object: self,
            userInfo:[
                "patientId": LSQPatientManager.sharedInstance.uuid!,
                "reload": true
            ]
        )
        /*
        NotificationCenter.default.post(
            name: LSQ.notification.action.nextOnboardingStep,
            object: self,
            userInfo: nil
        )
         */
    }
    
}

