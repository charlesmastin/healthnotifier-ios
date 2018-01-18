//
//  LSQOnboardingPromoViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQOnboardingPromoViewController : LSQOnboardingBaseViewController, UITextFieldDelegate {
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var actionContinue: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
        //
        if LSQOnboardingManager.sharedInstance.promoCode != nil {
            self.codeField.text = LSQOnboardingManager.sharedInstance.promoCode
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.codeField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LSQOnboardingPromoViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    // meh
    func tap(_ gesture: UITapGestureRecognizer) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    func textFieldDidChange(_ textField: UITextField){
        //
        // a couple of things bro
        //
        if textField.text != "" {
            self.actionContinue.title = "Continue"
        } else {
            self.actionContinue.title = "Skip"
        }
    }
    
    func validateCode(code: String) -> Void {
        //
        // consider using only the promo API, but since this is our second phase query, we should also send the LifeSticker
        // so we know for sure if we need to continue for payment or not
        // vs doing that higher up as an additional query brolo
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
        let data: [String: AnyObject] = [
            "Patients": poopy as AnyObject,
            "PromoCode": code as AnyObject,
        ]
        
        let payload: JSON = JSON(data)
        
        LSQAPI.sharedInstance.validateLifesquares(
            (payload.object as AnyObject),
            success: { response in
                // but only if promo is valid brolo
                // inspect
                var valid: Bool = false
                
                let json = JSON(response)
                var price: String = ""
                var promomessage: String = ""
                // try syntax though, this is so angry hangry though
                if json["Promo"].exists() {
                    if let v: Bool = json["Promo"]["Valid"].bool {
                        if v {
                            valid = true
                            if let p = json["Promo"]["Price"].int {
                                price = LSQ.formatter.centsToDollars(p)
                                if p <= 0 {
                                    promomessage = "Annual coverage is complimentary."
                                    // check the organization so we can umm, better thank the org here
                                }
                                if p > 0 {
                                    promomessage = "Price of \(price) will be reflected upon checkout."
                                }
                            }
                        }
                    }
                } else {
                    
                }
                
                if valid {
                    // only if promo valid, begin comparison of total due, since we're coming a bit out of sequence here
                    if let total = json["Total"].int {
                        if total < LSQOnboardingManager.sharedInstance.amountDue {
                            LSQOnboardingManager.sharedInstance.amountDue = total
                        }
                    }
                    
                    LSQOnboardingManager.sharedInstance.promoCode = code
                    // alert it, because why the flip not bro, terrrrrrrrirble but this is our way out of using realtime checking and all that jazz though
                    // self.nextStep()
                    
                    var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                        preferredStyle = UIAlertControllerStyle.actionSheet
                    }
                    // message the user it was invlaid O lordy Lord
                    
                    
                    
                    let alert: UIAlertController = UIAlertController(
                        title: "Promo Applied",
                        message: promomessage,
                        preferredStyle: preferredStyle)
                    let okAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: { action in
                        self.nextStep()
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.presentInvalidCodeAlert()
                }
            },
            failure: { response in
                // alert invalid code, option to try again, or skip
                self.presentInvalidCodeAlert()
            }
        )
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = true
        if textField == self.codeField {
            if textField.text != "" {
                self.submit()
                textField.resignFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        return shouldReturn
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.codeField {
            textField.returnKeyType = UIReturnKeyType.done
        }
        return true
    }
    
    func presentInvalidCodeAlert(){
        self.actionContinue.title = "Skip"
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        // message the user it was invlaid O lordy Lord
        let alert: UIAlertController = UIAlertController(
            title: "No Valid Code Found",
            message: "",
            preferredStyle: preferredStyle)
        let okAction: UIAlertAction = UIAlertAction(title:"Try Again", style: UIAlertActionStyle.cancel, handler: { action in
            self.codeField.becomeFirstResponder()
        })
        
        alert.addAction(okAction)
        let cancelAction: UIAlertAction = UIAlertAction(title:"Skip", style: UIAlertActionStyle.default, handler: { action in
            LSQOnboardingManager.sharedInstance.promoCode = nil
            self.nextStep()
        })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func nextStep(){
        self.removeObservers()
        NotificationCenter.default.post(
            name: LSQ.notification.action.nextOnboardingStep,
            object: self,
            userInfo: nil
        )
    }
    
    func submit(){
        let code: String = (self.codeField?.text)!
        
        if code != "" {
            self.validateCode(code: code)
        } else {
            // move on
            // I guess we should prompt to blablalb
            LSQOnboardingManager.sharedInstance.promoCode = nil
            self.nextStep()
        }
    }
    
    @IBAction func onContinue(_ sender: AnyObject?){
        self.submit()
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        
    }

}
