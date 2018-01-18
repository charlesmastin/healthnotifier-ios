//
//  LSQCheckoutViewController.swift
//
//  Created by Charles Mastin on 11/17/16.
//

// MVP operate on a single patient SON OKIE DOKEY

import Foundation
import UIKit
import SwiftyJSON
import Stripe
import EZLoadingActivity
import Alamofire
//
class LSQCheckoutViewController : UITableViewController, STPAddCardViewControllerDelegate {
    
    
    var mode: String = "assign"
    var patients: [JSON] = []
    var tableConfig: [[String: AnyObject]] = []
    var handle: AnyObject? = nil // timeout handle for promo live-validation
    
    // MVP for single patient
    // TODO: move into subview / container view controller
    var assignMethod: String = "" // new || claim,
    var lifesquareCode: String = ""
    var lifesquareValid: Bool = false
    //
    var promoCode: String = ""
    var promoValid: Bool = false
    var shippingId: Int? = nil
    var cardId: String? = nil
    var token: String? = nil
    
    // balls on balls son, misleading, but basically, don't let you change da LifeSticker
    // var readOnly: Bool = false
    // UX simplicity though?
    
    var requiresShipping: Bool = true
    
    var subscription: Bool = true // blablabla, a state variable although we also now have to chase the change state of the UI control, blabla
    var requiresPayment: Bool = true
    var amountDue: Int = 0 // based on calculations, in cents son
    
    // this seems unecessary, but we'll do it anyhow
    var addCardViewController: STPAddCardViewController? = nil
    
    func checkForShipping() -> Bool {
        //
        if self.requiresShipping && self.assignMethod == "new" {
            if self.shippingId == nil {
                let alert: UIAlertController = UIAlertController(
                    title: "No Shipping Found",
                    message: "We need to know your mailing address if you need new LifeStickers.",
                    preferredStyle: .alert)
                
                let okAction: UIAlertAction = UIAlertAction(title:"Add Address", style: UIAlertActionStyle.default, handler: { action in
                    //
                    // LOLZONE, this could work though maybe and then maybe not
                    //
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.collectionItemForm,
                        object: self,
                        userInfo: [
                            // this is the Add mode, aka no collectionItem
                            // not the collectionitem.id the "id" aka name of the collection
                            "collectionId": "addresses"
                        ]
                    )
                })
                alert.addAction(okAction)
                
                let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                    //self.assignMethod = ""
                    // meh meh meh
                    
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        //
        return true
    }
    
    @IBAction func done() {
        // it's gonna be 1 of 3 scenarios
        
        // basic payment validation
        // we shoudl have shut this whole op down if we need squares and don't have shipping yea son?
        if self.mode == "assign" && self.assignMethod == "" {
            let alert: UIAlertController = UIAlertController(
                title: "Please Confirm",
                message: "We need to know if you need a new LifeSticker or if you have been provided one to claim.",
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if !self.checkForShipping() {
            return
        }
        
        if self.amountDue > 0 && (self.token == nil && self.cardId == nil) {
            
            let alert: UIAlertController = UIAlertController(
                title: "Payment Details Missing",
                message: "",
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            // are we in a state of submit worthiness son?/
            // method name is generic
            let payload : AnyObject = self.generatePayload()
            
            EZLoadingActivity.show("", disableUI: true)
            LSQAPI.sharedInstance.processLifesquares(
                payload,
                action: self.mode,
                success: { response in
                    EZLoadingActivity.hide(true, animated: true)
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.checkoutSuccess,
                        object: self,
                        userInfo: [
                            "mode": self.mode,
                            "total": self.amountDue
                            // TODO: meta on payment, but that's in email son
                        ]
                    )
                    
                    // could be Apple Pay son
                    
                    var payment_method:String = ""
                    var payment_meta:String = ""
                    
                    if self.token != nil && self.token != "" {
                        payment_meta = "New"
                        payment_method = "Credit Card"
                    } else {
                        if self.cardId != nil {
                            payment_meta = "Saved"
                            payment_method = "Credit Card"
                        }
                    }
                    
                    let user: LSQUser = LSQUser.currentUser
                    
                    let attributes: [String: AnyObject] = [
                        "Mode": self.mode as AnyObject,
                        "Total": self.amountDue as AnyObject,
                        "PromoCode": self.promoCode as AnyObject,
                        "Subscription": self.subscription as AnyObject,
                        "PaymentMethod": payment_method as AnyObject,
                        "PaymentMeta": payment_meta as AnyObject,
                        "AccountId": user.uuid! as AnyObject,
                        "Provider": user.provider as AnyObject,
                        "PatientId": self.patients[0]["profile"]["uuid"].string! as AnyObject
                    ]
                    
                    NotificationCenter.default.post(
                        name: LSQ.notification.analytics.event,
                        object: nil,
                        userInfo: [
                            "event": "Checkout",
                            "attributes": attributes
                        ]
                    )
                    
                },
                failure: { response in
                    EZLoadingActivity.hide(false, animated: true)
                    var title: String = "Validation Error"
                    var messages:[String] = []
                    
                    if let theResponse = response as? Alamofire.DataResponse<Any> {
                        if theResponse.response?.statusCode == 400 {
                            messages.append("Invalid LifeStickers (not available or duplicate submissions). Please double check and try again, or choose \"I need LifeStickers\"")
                        }
                        if theResponse.response?.statusCode == 402 {
                            if theResponse.data != nil {
                                let json: JSON = JSON(data:theResponse.data!)
                                if json["errors"].exists() {
                                    for obj in json["errors"].arrayValue {
                                        messages.append(obj["message"].string!)
                                    }
                                }
                                // what kind of error are we son
                                title = "Payment Error"
                            }
                        }
                        if theResponse.response?.statusCode == 500 {
                            messages.append("There was an unexpected error")
                            // TODO: use the contact support error "kind" of alert
                            title = "Server Error"
                        }
                    }
                    
                    let alert: UIAlertController = UIAlertController(
                        title: title,
                        message: messages.joined(separator: "\n") ,
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
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        
        // listen for patient loaded or some crap for our special shipping address queue HOOK BROLO
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.replaceCollection,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                let collectionId: String = (notification.userInfo!["collection_id"] as? String)!
                print("yea son")
                if collectionId == "addresses" {
                    print("SOOOOON")
                    let json: JSON = JSON(notification.userInfo!["value"]!)
                    self.patients[0][collectionId] = json
                    self.doubleSecretInit()
                }
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.form.field.change,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                let attribute: String = (notification.userInfo!["id"] as? String)!
                if attribute == "promo" {
                    
                    self.promoCode = (notification.userInfo!["value"] as? String)!
                    // TODO: INTERVAL to not overload server and network son
                    
                    if self.promoCode.characters.count >= 3 {
                        if self.handle != nil {
                            self.handle!.invalidate()
                            self.handle = nil
                        }

                        self.handle = setTimeout(1.0, block: { () -> Void in
                            self.validateOnServer()
                        })
                    }
                    
                    // self.calculateAmountDue()
                }
                if attribute == "subscription" {
                    self.subscription = (notification.userInfo!["value"] as? Bool)!
                    // really just for that section though
                    self.tableView.reloadData()
                }
            }
        )
        
        // meh meh meh meh 1 use case here meh
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.dismiss.captureLifesquareCode,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if notification.userInfo != nil {
                    if let origin = notification.userInfo!["origin"] as? String {
                        if origin == "user" {
                            self.assignMethod = "new"
                            self.tableView.reloadData() // jank stank
                        }
                    }
                }
            }
        )
        
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
        
    }
    
    func removeObservers() {
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    // TODO: this perhaps needs to be moved to viewDidUnload or something not sure of the entire context it can be rendered visually
    deinit {
        self.removeObservers()
    }

    func validateLifesquareCode(_ code: String) -> Void {
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
    
    func obtainAllShipping() -> [JSON] {
        // for now, only operate on the single patient, in da future, we could obtain all of it
        return [JSON("TEST")]
    }
    
    func generatePayload() -> AnyObject {
        let poopy: [[String : AnyObject]] = [
            ["PatientId": (self.patients as [JSON])[0]["profile"]["uuid"].string! as AnyObject, "LifesquareId": self.lifesquareCode as AnyObject]
        ]
        var cheds: [String: AnyObject] = ["AuthorizedTotal": self.amountDue as AnyObject]
        if self.token != nil && self.token != "" {
            cheds["Token"] = self.token as AnyObject?
        } else {
            cheds["CardId"] = self.cardId as AnyObject?
        }
        var data: [String: AnyObject] = [
            "Patients": poopy as AnyObject,
            "PromoCode": self.promoCode as AnyObject,
            "Subscription": self.subscription as AnyObject,
            "Payment": cheds as AnyObject
        ]
        if self.shippingId != nil {
            data["Shipping"] = ["ResidenceId": self.shippingId! as AnyObject] as AnyObject
        }
        var json: JSON = JSON(data)
        return json.object as AnyObject
    }
    
    func validateOnServer() -> Void {
        LSQAPI.sharedInstance.validateLifesquares(
            self.generatePayload(),
            success: { response in
                var indexPaths: [IndexPath] = []
                
                let json = JSON(response)
                
                self.amountDue = json["Total"].int!
                
                if self.promoCode != "" {
                    //let cell: UITableViewCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection:2))!
                    if json["Promo"]["Valid"].boolValue {
                        self.promoValid = true
                        indexPaths.append(IndexPath(row: 0, section: 2))
                        // show dat accessory view son
                        //cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    }else {
                        self.promoValid = false
                        //cell.accessoryType = UITableViewCellAccessoryType.ALERT
                        // hide dat accessory view son
                    }
                }
                if self.lifesquareCode != "" {
                    // we set something and so on
                    self.lifesquareValid = false
                    let p = json["Patients"][0]
                    if p["LifesquareId"].string == self.lifesquareCode {
                        if p["Valid"].boolValue {
                            self.lifesquareValid = true
                            self.assignMethod = "claim"
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.none)
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
                            self.assignMethod = "new"
                            NotificationCenter.default.post(name: LSQ.notification.show.captureLifesquareCode, object: self)
                            self.tableView.reloadData()
                        })
                        
                        alert.addAction(okAction)
                        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                            
                        })
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                        
                        self.lifesquareCode = ""
                        self.assignMethod = "new"
                    }
                    
                }
                var focusPromo: Bool = false
                // SPECIAL CASE FOR UPDATING PROMO CODE IN REALTIME SON
                let firstResponder = UIResponder.getCurrentFirstResponder()
                if firstResponder is UITextField {
                    focusPromo = true
                }
                
                self.determineTableState()
                
                if focusPromo && !self.promoValid {
                    firstResponder?.becomeFirstResponder()
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
    
    func doubleSecretInit() -> Void {
        
        // 
        self.amountDue = 0
        // if we have more than 1 residence select the first - or whatever has mailing in it yea son
        // let's face it, we should never be "HERE" if we don't have at least one residence, but somehow
        // we must protect against a crash
        let addresses: Array<JSON> = self.patients[0]["addresses"].arrayValue
        if addresses.count > 0 {
            self.shippingId = addresses[0]["patient_residence_id"].int
            for address in addresses {
                if address["mailing_address"].boolValue {
                    self.shippingId = address["patient_residence_id"].int
                }
            }
        } else {
            // BAD TIMES NO MAILY MAILY
        }
        
        let cards: Array<JSON> = self.patients[0]["meta"]["available_cards"].arrayValue
        if cards.count > 0 {
            self.cardId = cards[0]["id"].string
        }
        
        // calculate dem initial amountDue son
        // yea, this may very well explode all up in yo face son
        if self.mode == "assign" || self.mode == "renew" {
            for patient in self.patients {
                self.amountDue += patient["meta"]["coverage_cost"].int!
            }
        }
        if self.mode == "replace" {
            for patient in self.patients {
                self.amountDue += patient["meta"]["replacement_cost"].int!
            }
        }
        
        if self.patients[0]["profile"]["lifesquare_id"].string != nil {
            self.lifesquareCode = self.patients[0]["profile"]["lifesquare_id"].string!
        }
        
        self.determineTableState()
    }
    
    
    
    func determineTableState() -> Void {
        self.tableConfig = []
        
        var numAddresses: Int = 0
        // realistically this should be stored in the class instance at some reduced state
        // proper acquisition of this data son
        if self.patients.count > 0 {
            let addresses: Array<JSON> = self.patients[0]["addresses"].arrayValue
            numAddresses = addresses.count
        }
        
        var numCards: Int = 0
        // proper acquisition of this data son
        if self.patients.count > 0 {
            let cards: Array<JSON> = self.patients[0]["meta"]["available_cards"].arrayValue
            numCards = cards.count
        }
        
        if self.mode == "assign" {
            // only a summary now brosef brobass
            
            self.tableConfig.append(
                [
                    "id": "assign" as AnyObject,
                    "header": "Assign LifeStickers" as AnyObject
                ]
            )
            
        }
        // precalculate the num of addresses son
        self.tableConfig.append(
            [
                "id": "shipping" as AnyObject,
                "header": "Shipping Address" as AnyObject,
                "numAddresses": numAddresses as AnyObject
            ]
        )
        if self.mode == "assign" {
            // promo summary
            
            
            self.tableConfig.append(
                [
                    "id": "promo" as AnyObject,
                    "header": "Promo Code" as AnyObject
                ]
            )
            
            // depending on the other states
            self.tableConfig.append(
                [
                    "id": "plan" as AnyObject,
                    "header": "Plan Level" as AnyObject
                ]
            )
        }
        if self.mode == "assign" || self.mode == "renew" {
            if requiresPayment && self.amountDue > 0 {
                self.tableConfig.append(
                    [
                        "id": "subscription" as AnyObject,
                        "header": "Subscription" as AnyObject
                    ]
                )
            }
        }
        self.tableConfig.append(
            [
                "id": "totals" as AnyObject,
                "header": "Amount Due" as AnyObject
            ]
        )
        if requiresPayment && self.amountDue > 0 {
            // precalculate the num of cards
            self.tableConfig.append(
                [
                    "id": "payment" as AnyObject,
                    "header": "Payment Information" as AnyObject,
                    "numCards": numCards as AnyObject
                ]
            )
            
        }
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.tableView.register(UINib(nibName: "CellFormCheckbox", bundle: nil), forCellReuseIdentifier: "CellFormCheckbox")
        self.tableView.register(UINib(nibName: "CellFormInput", bundle: nil), forCellReuseIdentifier: "CellFormInput")
        self.addObservers()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableConfig.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableConfig[section]["header"]! as? String
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var config: [String: AnyObject] = self.tableConfig[section]
        if config["id"]! as? String == "subscription" {
            if self.subscription {
                return "Your card will be charged annually to ensure your coverage is always active. You may cancel at any time."
            } else {
                return ""
            }
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var config: [String: AnyObject] = self.tableConfig[section]
        if config["id"]! as? String == "assign" {
            return 2
        }
        if config["id"]! as? String == "shipping" {
            
            // TODO: get this as the discreet available shipping addresses SON
            // yup number of addresses
            var count: Int = 0
            // TODO THIS IS GONNA FAIL BALL BUSTERS EDITION STYLE
            count = (config["numAddresses"] as? Int)!
            return count
        }
        if config["id"]! as? String == "promo" {
            return 1
        }
        if config["id"]! as? String == "plan" {
            return 2
        }
        if config["id"]! as? String == "subscription" {
            return 1
        }
        if config["id"]! as? String == "totals" {
            return 1
        }
        if config["id"]! as? String == "payment" {
            var count: Int = 0
            // TODO THIS IS GONNA FAIL BALL BUSTERS EDITION STYLE
            count = (config["numCards"] as? Int)!
            // if we entered a new card, aka token is set
            if self.token != nil {
                count += 1 // TODO: SOR THIS OUT NOW
            }
            // + Add New Card son
            count += 1
            return count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var config: [String: AnyObject] = self.tableConfig[indexPath.section]
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "bla")
        
        
        // first pass and cheesing it out
        if config["id"]! as? String == "assign" {
            // create the ummm programatic view container and all that for the container view
            // ok
            // cell.textLabel?.text = "LifeSticker Assign Container View Son"
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = "I need LifeStickers"
                if self.assignMethod == "new" {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
            if indexPath.row == 1 {
                
                cell.detailTextLabel?.text = "I already have LifeStickers"
                if self.lifesquareCode != "" && self.lifesquareValid {
                    // DEFAULT CELL STYLE SON
                    let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "bla_image")
                    let placeholder = UIImage(named: "qrcode")
                    cell.imageView?.contentMode = UIViewContentMode.scaleAspectFill
                    let imageSize = 44.0
                    let imageURL: String = "\(LSQAPI.sharedInstance.api_root)lifesquares/\(self.lifesquareCode)/image?width=\(Int(imageSize * 2))&height=\(Int(imageSize * 2))"
                    cell.imageView?.kf.setImage(
                        with: URL(string: imageURL),
                        placeholder: placeholder,
                        options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)]
                    )
                    cell.textLabel?.text = "Claiming \(self.lifesquareCode)"
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    return cell
                }
                // this will never be called
                if self.assignMethod == "claim" {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
            // This is straight retired son
            if indexPath.row == 2 {
                // TODO: placeholder son son son son son
                cell = Forms.generateDefaultInputCell(
                    self.tableView,
                    indexPath: indexPath,
                    id: "lifesquareCode", label: "LifeSticker Code",
                    initialValue: self.lifesquareCode,
                    required: true
                )
                // TODO: what the son son son
                (cell as? LSQCellFormInput)?.input?.keyboardType = UIKeyboardType.namePhonePad
                (cell as? LSQCellFormInput)?.input?.autocapitalizationType = UITextAutocapitalizationType.allCharacters
                
                if self.lifesquareCode != "" {
                    if self.lifesquareValid {
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.detailButton
                    }
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            }
        }
        if config["id"]! as? String == "promo" {
            // input field son
            cell = Forms.generateDefaultInputCell(
                self.tableView,
                indexPath: indexPath,
                id: "promo", label: "Promo Code",
                initialValue: self.promoCode,
                required: false
            )
            if self.promoCode != "" {
                if self.promoValid {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.detailButton
                }
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        if config["id"]! as? String == "plan" {
            
            if indexPath.row == 0 {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla2")
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.textLabel?.text = "Personal"
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.text = "-Your health care information moves with you\n-Critical health information is accessible to others with assigned viewing privileges in times of need\n-Online support"
                
                // cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell.detailTextLabel?.sizeToFit()
                return cell
            }
            if indexPath.row == 1 {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla2")
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.textLabel?.text = "Enterprise"
                cell.detailTextLabel?.text = "Contact enterprise@domain.com for more information."
                cell.detailTextLabel?.textColor = LSQ.appearance.color.gray0
                return cell
            }
        }
        if config["id"]! as? String == "subscription" {
            cell = Forms.generateDefaultCheckboxCell(
                self.tableView,
                indexPath: indexPath,
                id: "subscription", label: "Auto-renew coverage?",
                initialValue: self.subscription,
                required: false
            )
        }
        if config["id"]! as? String == "totals" {
            // cell.textLabel
            cell.detailTextLabel?.text = "\(LSQ.formatter.centsToDollars(self.amountDue))"
        }
        if config["id"]! as? String == "payment" {
            let count = (config["numCards"] as? Int)!
            // TODO: this logic is umm redundant
            if count > 0 {
                // not sure how this will work with apple pay on file
                if indexPath.row < count {
                    let address = self.patients[0]["meta"]["available_cards"][indexPath.row]
                    let brand: String = address["brand"].string!
                
                    //cell.imageView?.image = UIImage(named:"stp_card_\(brand.lowercaseString).png")
                    //cell.imageView?.image = UIImage(contentsOfFile: "stp_card_visa.png")
                    cell.textLabel?.text = brand
                    cell.detailTextLabel?.text = "Ending in \(address["last4"].string!)"
                    // TODO: check which is currentl the selected card and show the checkbox if so son
                    if self.cardId == address["id"].string {
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    }
                } else {
                    if self.token != nil && (indexPath.row == count){
                        cell.detailTextLabel?.text = "Newly added card"
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    } else {
                        cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "payment")
                        (cell as? LSQCellAddCollectionItem)?.labelText = "+ Add Credit Card"
                    }
                }
            }else {
                // F this is buggy bro
                if self.token != nil && indexPath.row == 0 {
                    cell.detailTextLabel?.text = "Newly added card"
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "payment")
                    (cell as? LSQCellAddCollectionItem)?.labelText = "+ Add Credit Card"
                }
            }
            // if we have more than one and we're not at the end
            // map it to a card
            // currently this requires us to go "BACK TO THE LOGIC"
            // ugg son
            // else show the addnew cell son
        }
        if config["id"]! as? String == "shipping" {
            let addresses: Array<JSON> = self.patients[0]["addresses"].arrayValue
            let address: JSON = addresses[indexPath.row]
            cell.textLabel?.text = address["description"].string!
            cell.detailTextLabel?.text = address["title"].string!
            // cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "addresses")
            if self.shippingId == address["patient_residence_id"].int {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var config: [String: AnyObject] = self.tableConfig[indexPath.section]
        let cell = self.tableView.cellForRow(at: indexPath)
        if cell is LSQCellAddCollectionItem {
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "payment" {
                self.addCard()
            }
            return
        }
        
        if config["id"]! as? String == "assign" {
            if indexPath.row == 0 {
                //
                // TODO: claiming based on OnboardingManager
                //
                //
                //
                //
                //
                
                self.assignMethod = "new"
                self.lifesquareCode = ""
                self.lifesquareValid = false
                self.doubleSecretInit() // LOL THIS IS COMEDY, but it get's the job done
            }
            if indexPath.row == 1 {
                self.assignMethod = "claim"
                NotificationCenter.default.post(name: LSQ.notification.show.captureLifesquareCode, object: self)
                self.tableView.reloadData()
            }
        }
        
        if config["id"]! as? String == "shipping" {
            //var shippingId: Int? = nil
            let addresses: Array<JSON> = self.patients[0]["addresses"].arrayValue
            let address: JSON = addresses[indexPath.row]
            self.shippingId = address["patient_residence_id"].int
            self.tableView.reloadData()
        }
        
        if config["id"]! as? String == "plan" {
            if indexPath.row == 1 {
                LSQ.launchers.email("enterprise@domain.com")
            }
        }
        
        if config["id"]! as? String == "payment" {
            //var shippingId: Int? = nil
            let cards: Array<JSON> = self.patients[0]["meta"]["available_cards"].arrayValue
            
            if self.token != nil {
                //
                // DID we click on a card index if so, zero that out and suck it up
                // we already checked for the + Add Card link up above son
                if indexPath.row < cards.count {
                    let card: JSON = cards[indexPath.row]
                    self.cardId = card["id"].string
                    self.token = nil
                } else {
                    // do nothing, we clicked on our "NEW CARD"
                }
                //
            } else {
                // do your thing son
                let card: JSON = cards[indexPath.row]
                self.cardId = card["id"].string
            }
            
            
            self.tableView.reloadData()
        }
        // ok what if we're just doing the whole we're a card
        // we're an address etc thing
    }
    
    func addCard() {
        // OK, we might have to scrap dis if we can't hide the remember me save for use in other apps bit, lolzor
        self.addCardViewController = STPAddCardViewController()
        self.addCardViewController!.delegate = self
        let info: STPUserInformation = STPUserInformation()
        let user:LSQUser = LSQUser.currentUser
        info.email = user.email
        // NOT SURE if we want to send this to Stripe
        /*
        if user.phone != nil {
            info.phone = user.phone
        }
        */
        self.addCardViewController!.prefilledInformation = info
        
        // STPAddCardViewController must be shown inside a UINavigationController.
        let navigationController = UINavigationController(rootViewController: self.addCardViewController!)
        self.present(navigationController, animated: true, completion: nil)
        
        // prefill email and umm hide that input
        // umm don't show the save for use in other apps checkbox
    }
    
    // MARK: STPAddCardViewControllerDelegate
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // this is ok
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        self.token = token.tokenId
        self.cardId = nil
        self.tableView.reloadData() // TODO: greedy?
        
        self.addCardViewController!.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var config: [String: AnyObject] = self.tableConfig[indexPath.section]
        if config["id"]! as? String == "plan" {
            if indexPath.row == 0 {
                return 110.0
            }
            if indexPath.row == 1 {
                return 66.0
            }
        }
        if config["id"]! as? String == "promo" {
            return 56.0
        }
        return 44.0
    }
}
