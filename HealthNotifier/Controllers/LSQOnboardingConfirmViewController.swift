//
//  LSQOnboardingConfirmViewController.swift
//
//  Created by Charles Mastin on 9/14/17.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQOnboardingConfirmViewController : LSQOnboardingBaseViewController {
    
    @IBOutlet weak var infoLabel1: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    
    @IBAction func onContinue(_ sender: AnyObject?){
        self.confirm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // lolzin
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
    }
    
    var legacy: Bool = false
    
    // lifecycle son
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // build up the summary
        var blurb: String = "By continuing you are confirming your account details are accurate"
        
        if LSQOnboardingManager.sharedInstance.claimedLifesquare != nil {
            blurb = "\(blurb) and you are claiming the LifeSticker \(LSQOnboardingManager.sharedInstance.claimedLifesquare!)."
        } else {
            blurb = "\(blurb) and you are requesting a new LifeSticker."
        }
        
        if legacy {
            // oh hell, you already accepted that other stuff you sucker
            blurb = "By continuing you are confirming your account details are accurate."
            
            // KILL THE BACK BUTTON THOUGH
            backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(LSQOnboardingConfirmViewController.goBack))
            navigationItem.leftBarButtonItem = backButton
            backButton.isEnabled = false
        }
        
        self.infoLabel1.text = blurb
        
        // TODO: read from campaign meta data that will put additional content up in here, or just append it to the end of the blurb
        self.infoLabel2.isHidden = true
        
    }
    
    func goBack(){
        
    }
    
    func confirm(){
        EZLoadingActivity.show("", disableUI: true)
        LSQAPI.sharedInstance.confirmProfile(
            LSQPatientManager.sharedInstance.uuid!,
            success: { response in
                // TODO: ghetto as sauce on your sauce with slaw on the side™
                // now assign your LifeSticker lolzone x2, daisy chain your nodejs nesting for the win FML
                // this is gonna get hairmaster flexdollar crazytown mcgee though
                if self.legacy {
                    EZLoadingActivity.hide(true, animated: true)
                    LSQPatientManager.sharedInstance.fetch()
                    NotificationCenter.default.post(
                        name: LSQ.notification.action.nextOnboardingStep,
                        object: self,
                        userInfo: nil
                    )
                } else {
                    self.assignLifesquare()
                }
            },
            failure: { response in
                EZLoadingActivity.hide(false, animated: true)
                let alert: UIAlertController = UIAlertController(
                    title: "Server Error",
                    message: "Unable to confirm profile.",
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    // TODO: focus first problem child?
                })
                alert.addAction(cancelAction)
                alert.addAction(LSQ.action.support)
                self.present(alert, animated: true, completion: nil)
            }
        )
    }
    
    func assignLifesquare(){
        
        var lsq: AnyObject = "" as AnyObject
        if LSQOnboardingManager.sharedInstance.claimedLifesquare != nil {
            lsq = LSQOnboardingManager.sharedInstance.claimedLifesquare! as AnyObject
        }
        let poopy: [[String : AnyObject]] = [
            [
                "PatientId": LSQPatientManager.sharedInstance.uuid! as AnyObject,
                "LifesquareId": lsq // or Nil bro, meh meh meh
            ]
        ]
        var code: String = ""
        if LSQOnboardingManager.sharedInstance.promoCode != nil {
            code = LSQOnboardingManager.sharedInstance.promoCode!
        }
        let data: [String: AnyObject] = [
            "Patients": poopy as AnyObject,
            "PromoCode": code as AnyObject,
            // "Shipping": [], FML backend is going to choke dongs
        ]
        
        let payload: JSON = JSON(data)
        
        // dis is ghettog sauce on your sauce
        LSQAPI.sharedInstance.processLifesquares(
            payload.object as AnyObject,
            action: "assign",
            success: { response in
                
                // wait though OMG though
                // OH LOLZIN
                LSQPatientManager.sharedInstance.fetchWithCallbacks(success: {_ in
                    EZLoadingActivity.hide(true, animated: true)
                    NotificationCenter.default.post(
                        name: LSQ.notification.action.nextOnboardingStep,
                        object: self,
                        userInfo: nil
                    )
                }, failure: {_ in})
            },
            failure: { response in
                EZLoadingActivity.hide(false, animated: true)
                // TBD so many error cases though
                let alert: UIAlertController = UIAlertController(
                    title: "Server Error",
                    message: "Unable to assign LifeSticker",
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    // TODO: focus first problem child?
                })
                alert.addAction(cancelAction)
                alert.addAction(LSQ.action.support)
                self.present(alert, animated: true, completion: nil)
            }
        )
    }
}
