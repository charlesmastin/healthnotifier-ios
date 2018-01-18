//
//  LSQOnboardingScanLifesquareViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQOnboardingScanLifesquareViewController : LSQOnboardingBaseViewController {
    
    var lifesquareCode: String = ""
    var lifesquareValid: Bool = false
    
    @IBOutlet weak var switchConfirm: UISwitch!
    @IBOutlet weak var continueAction: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.switchConfirm.addTarget(self, action: #selector(onChangeSwitch), for: UIControlEvents.valueChanged)
        self.switchConfirm.tintColor = UIColor.black.withAlphaComponent(0.3)
        self.switchConfirm.onTintColor = UIColor.black.withAlphaComponent(0.3)
        self.addObservers()
    }
    
    func onChangeSwitch(mySwitch: UISwitch){
        // conflicting validation on existing claims bro
        // intercept if
        if LSQOnboardingManager.sharedInstance.claimedLifesquare != nil {
            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                preferredStyle = UIAlertControllerStyle.actionSheet
            }
            // message the user it was invlaid O lordy Lord
            let alert: UIAlertController = UIAlertController(
                title: "Please Confirm",
                message: "You had begun to claim the LifeSticker \(LSQOnboardingManager.sharedInstance.claimedLifesquare!). Do you wish to request a new LifeSticker instead?",
                preferredStyle: preferredStyle)
            let okAction: UIAlertAction = UIAlertAction(title:"Request new LifeSticker", style: UIAlertActionStyle.default, handler: { action in
                self.lifesquareCode = ""
                if LSQOnboardingManager.sharedInstance.claimedLifesquare != nil {
                    LSQOnboardingManager.sharedInstance.clearLifesquare()
                }
                self.switchConfirm.isOn = true
                self.onChangeForm()
                self.removeObservers()
                NotificationCenter.default.post(
                    name: LSQ.notification.action.nextOnboardingStep,
                    object: self,
                    userInfo: nil
                )
            })
            
            alert.addAction(okAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                // do not change the form state… meh
                self.switchConfirm.isOn = false
                self.onChangeForm()
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.onChangeForm()
        }
        
        
    }
    
    func onChangeForm(){
        // establish the state bro
        if self.switchConfirm.isOn || self.lifesquareValid {
            self.continueAction?.isEnabled = true
        } else {
            self.continueAction?.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            print("MISTAKE OF THE YEAR when blankly applied")
            self.removeObservers()
        }
        if self.isMovingToParentViewController {
            print("VIEW GOING BYE BYE BYE BBB")
        }
    }
    
    @IBAction func onContinue(_ sender: AnyObject?){
        // aka only possible for da skipping son
        var valid: Bool = true
        // if we haven't confirmed or claimed
        if self.lifesquareCode == "" && !self.switchConfirm.isOn {
            valid = false
        }
        
        if !valid {
            // CONFIRM you don't have a lifesquare bro sauce
            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                preferredStyle = UIAlertControllerStyle.actionSheet
            }
            // message the user it was invlaid O lordy Lord
            let alert: UIAlertController = UIAlertController(
                title: "",
                message: "Please let us know if you have existing stickers or need new ones sent out.",
                preferredStyle: preferredStyle)
            let okAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                
            })
            
            alert.addAction(okAction)
            /*
            let cancelAction: UIAlertAction = UIAlertAction(title:"Yes", style: UIAlertActionStyle.cancel, handler: { action in
                NotificationCenter.default.post(
                    name: LSQ.notification.action.nextOnboardingStep,
                    object: self,
                    userInfo: nil
                )
            })
            alert.addAction(cancelAction)
            */
            self.present(alert, animated: true, completion: nil)
        } else {
            
            // asign to da bizzle
            self.removeObservers()
            NotificationCenter.default.post(
                name: LSQ.notification.action.nextOnboardingStep,
                object: self,
                userInfo: nil
            )
        }
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        self.switchConfirm.isOn = false
        self.onChangeForm()
        NotificationCenter.default.post(name: LSQ.notification.show.captureLifesquareCode, object: self)
    }
    
    override func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.lifesquareCodeCaptured,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                let code: String = (notification.userInfo!["code"] as? String)!
                // let mode: String = (notification.userInfo!["mode"] as? String)!
                self.validateLifesquareCode(code)
            }
        )
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.dismiss.captureLifesquareCode,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // cancel the op and close down the stuffs brolo
                // mehzone,
                // in here though, do simply the data statemanagement
            }
        )
    }
    
    func validateLifesquareCode(_ code: String) -> Void {
        print("!!!!!-----THIS WAS THE UNDOING OF EVERYTHING------!!!!!!!")
        print("CODE")
        print(code)
        // do something silly willy once we hit 9 characters son
        if code.characters.count == 9 {
            self.lifesquareCode = code.uppercased()
            // redraw this guy with the spinner so we can defocus dat keyboard input son
            self.validateOnServer()
        } else {
            self.lifesquareCode = ""
        }
        // if for some reason we went over the lines???
        
    }
    
    func generatePayload() -> AnyObject {
        let poopy: [[String : AnyObject]] = [
            [
                "PatientId": LSQPatientManager.sharedInstance.uuid! as AnyObject,
                "LifesquareId": self.lifesquareCode as AnyObject
            ]
        ]
        
        
//        let shipper: [String: AnyObject] = ["ResidenceId": self.shippingId! as AnyObject]
//        var cheds: [String: AnyObject] = ["AuthorizedTotal": self.amountDue as AnyObject]
//        if self.token != nil && self.token != "" {
//            cheds["Token"] = self.token as AnyObject?
//        } else {
//            cheds["CardId"] = self.cardId as AnyObject?
//        }
        
        let data: [String: AnyObject] = [
            "Patients": poopy as AnyObject,
//            "Shipping": shipper as AnyObject,
            "PromoCode": "" as AnyObject,
//            "Subscription": self.subscription as AnyObject,
//            "Payment": cheds as AnyObject
        ]
        var json: JSON = JSON(data)
        return json.object as AnyObject
    }
    
    func validateOnServer() -> Void {
        LSQAPI.sharedInstance.validateLifesquares(
            self.generatePayload(),
            success: { response in
                let json = JSON(response)
                if self.lifesquareCode != "" {
                    // we set something and so on
                    self.lifesquareValid = false
                    let p = json["Patients"][0]
                    if p["LifesquareId"].string == self.lifesquareCode {
                        if p["Valid"].boolValue {
                            
                            var message = "The LifeSticker \(self.lifesquareCode) is mine and I claim it."
                            
                            if let total = json["Total"].int {
                                if total <= 0 {
                                    message = "\(message) The annual subscription fee is free for the first year"
                                    if let org: String = p["SponsoringOrg"].string {
                                        message = "\(message) compliments of \(org)."
                                    } else {
                                        message = "\(message)."
                                    }
                                }
                            }
                            
                            // confirmation brizzle with forward momentum action brolo
                            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                                preferredStyle = UIAlertControllerStyle.actionSheet
                            }
                            // message the user it was invlaid O lordy Lord
                            let alert: UIAlertController = UIAlertController(
                                title: "Please Confirm",
                                message: message,
                                preferredStyle: preferredStyle)
                            let okAction: UIAlertAction = UIAlertAction(title:"Claim LifeSticker", style: UIAlertActionStyle.default, handler: { action in
                                self.lifesquareValid = true
                                // AT THIS POINT SHOW THE CONFIRMATION BRO BRIZZLE
                                // aka continue though
                                if let total = json["Total"].int {
                                    //print("saving total as")
                                    //print(total)
                                    LSQOnboardingManager.sharedInstance.amountDue = total
                                }
                                // handle the amount due, cache it into onboarding manager
                                
                                LSQOnboardingManager.sharedInstance.claimedLifesquare = p["LifesquareId"].string!
                                
                                self.removeObservers()
                                
                                // fetch the patient in order to cache the special message though brolo, so innefficient though
                                
                                NotificationCenter.default.post(
                                    name: LSQ.notification.action.nextOnboardingStep,
                                    object: self,
                                    userInfo: nil
                                )

                                //                          self.assignMethod = "new"
                                //NotificationCenter.default.post(name: LSQ.notification.show.captureLifesquareCode, object: self)
                                //                          self.tableView.reloadData()
                            })
                            
                            alert.addAction(okAction)
                            let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                                self.lifesquareCode = ""
                                self.lifesquareValid = false
                                self.onChangeForm()
                            })
                            alert.addAction(cancelAction)
                            
                            // blalablalb
                            if self.isBeingPresented {
                                // meh wtf son
                                _ = setTimeout(0.3, block: { () -> Void in
                                    self.present(alert, animated: true, completion: nil)
                                })
                            } else {
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            
                            // TODO: if there isn't an assigned promo code already on the server side bro sauce
                            // context about stuffs? meh
                            /*
                            NotificationCenter.default.post(
                                name: LSQ.notification.action.nextOnboardingStep,
                                object: self,
                                userInfo: nil
                            )
                            */
                            
                            // otherwise, to patient "confirm" or something or just tease success and push notifications and all that
                            self.onChangeForm()
                        }
                    }
                    if !self.lifesquareValid {
                        // basically, we didn't cut the mustard on the server with whatever we're attempting to "claim"
                        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                            preferredStyle = UIAlertControllerStyle.actionSheet
                        }
                        // message the user it was invlaid O lordy Lord
                        let alert: UIAlertController = UIAlertController(
                            title: "Invalid LifeSticker \(self.lifesquareCode)",
                            message: "We couldn’t find a claimable LifeSticker. Please try again or select 'I need LifeStickers'.",
                            preferredStyle: preferredStyle)
                        let okAction: UIAlertAction = UIAlertAction(title:"Try Again", style: UIAlertActionStyle.default, handler: { action in
//                          self.assignMethod = "new"
                            NotificationCenter.default.post(name: LSQ.notification.show.captureLifesquareCode, object: self)
//                          self.tableView.reloadData()
                        })
                        
                        alert.addAction(okAction)
                        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                            
                        })
                        alert.addAction(cancelAction)
                        
                        if self.isBeingPresented {
                            // meh wtf son
                            _ = setTimeout(0.3, block: { () -> Void in
                                self.present(alert, animated: true, completion: nil)
                            })
                        } else {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        //self.present(alert, animated: true, completion: nil)
                        
                        self.lifesquareCode = ""
//                        self.assignMethod = "new"
                        self.onChangeForm()
                    }
                    
                }
                
            },
            failure: { response in
                let alert: UIAlertController = UIAlertController(
                    title: "Validation Error",
                    message: "Unknown Error. Please try again or contact support@domain.com",
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    // TODO: focus first problem child?
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        )
    }

}
