//
//  LSQOnboardingAccountViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit
import EZLoadingActivity
import SwiftyJSON
import Alamofire

class LSQOnboardingAccountViewController : LSQOnboardingBaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPhone: UITextField!
    @IBOutlet weak var textPass: UITextField!
    @IBOutlet weak var textPass2: UITextField!
    
    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var termsButton: UIButton!
    
    @IBOutlet weak var buttonContinue: UIBarButtonItem?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LSQLoginViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)

        // that said, we're not going to really have components here at this point, so this is heavy handed somewhat
        self.fieldsA = [
            self.textEmail!,
            self.textPhone!,
            self.textPass!,
            //self.textPass2!
        ]
        
        self.termsSwitch?.addTarget(self, action: #selector(onChangeSwitch), for: UIControlEvents.valueChanged)
        
        let customView = UIToolbar()
        let previousButton: UIBarButtonItem = UIBarButtonItem(title: "Prev", style: .plain, target: nil, action: nil)
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: " ▼ ", style: .done, target: nil, action: nil)
        previousButton.isEnabled = true
        previousButton.target = self
        previousButton.action = #selector(self.textFieldPrev(_:))
        nextButton.isEnabled = true
        nextButton.target = self
        nextButton.action = #selector(self.textFieldNext(_:))
        doneButton.target = self
        doneButton.action = #selector(self.textFieldDone(_:))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        customView.items = [previousButton, nextButton, flexibleSpace, doneButton]
        customView.sizeToFit()
        
        // meh
        self.textEmail.inputAccessoryView = customView
        self.textPhone.inputAccessoryView = customView
        self.textPass.inputAccessoryView = customView
        //self.textPass2.inputAccessoryView = customView
        
        self.termsSwitch.tintColor = UIColor.black.withAlphaComponent(0.3)
        self.termsSwitch.onTintColor = UIColor.black.withAlphaComponent(0.3)
        
        self.addObservers()
    }
    
    func textFieldNext(_ barButtonItem: UIBarButtonItem){
        // oh hell
        let tf = self.firstResponder!
        if tf == self.textEmail {
            self.textPhone.becomeFirstResponder()
            self.scrollToView(self.textPhone)
        } else if tf == self.textPhone {
            self.textPass.becomeFirstResponder()
            self.scrollToView(self.textPass)
        } else if tf == self.textPass {
            self.firstResponder?.resignFirstResponder()
            self.animateScrollOffset(0.0)
            //self.textPass2.becomeFirstResponder()
            //self.scrollToView(self.textPass2)
        }
        
    }
    
    func textFieldPrev(_ barButtonItem: UIBarButtonItem){
        let tf = self.firstResponder!
        if tf == self.textEmail {
            self.firstResponder?.resignFirstResponder()
            self.animateScrollOffset(0.0)
        } else if tf == self.textPhone {
            self.textEmail.becomeFirstResponder()
            self.scrollToView(self.textEmail)
        } else if tf == self.textPass {
            self.textPhone.becomeFirstResponder()
            self.scrollToView(self.textPhone)
        }
    }
    
    func textFieldDone(_ barButtonItem: UIBarButtonItem){
        self.firstResponder?.resignFirstResponder()
        // scrollview reset though brolo
        self.animateScrollOffset(0.0)
    }
    
    func animateScrollOffset(_ y:CGFloat) -> Void {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.scrollView.contentOffset.y = y
            }, completion: nil)
        }
    }
    
    // TODO: move to library bro
    func scrollToView(_ v:UIView){
        // parent view container blabla
        // meh meh meh
        var y:Double = 0.0
        // obtain the y position son, maybe though????
        y = Double(v.frame.origin.y)
        
        if y - 44 > 0 {
            y = y - 44
        }
        // https://stackoverflow.com/questions/33919031/smooth-move-of-the-contentoffset-uiscrollview-swift
        self.animateScrollOffset(CGFloat(y))
        // self.scrollView.contentOffset = CGPoint(x: 0.0, y: y)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LSQAppearanceManager.sharedInstance.underlinedInputs = true
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
    }
    
    override func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.acceptTerms,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.termsSwitch?.isOn = true
                // does not trigger on change brolo
                self.onFormChangeHandler()
            }
        )
    }
    
    
    
    // sequence of fields, for the purpose of handling next and done, except we will not submit, but close focus so we can "see the terms bro"
    var fieldsA:[UITextField] = []
    
    // Keyboard UX Stuffs
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = true
        if textField == self.textEmail {
            self.textPhone.becomeFirstResponder()
            self.scrollToView(self.textPhone)
        } else if textField == self.textPhone {
            self.textPass.becomeFirstResponder()
            self.scrollToView(self.textPass)
        } else if textField == self.textPass {
            // reset the scroll though
            textField.resignFirstResponder()
            self.animateScrollOffset(0.0)
        }
        return shouldReturn
    }
    
    func onChangeSwitch(mySwitch: UISwitch){
        // resign the responders just in case bro
        // todo: extension for class first responder that is not the UIswitch though, hahaha
        self.zapResponders()
        self.onFormChangeHandler()
    }
    
    func zapResponders(){
        self.textEmail.resignFirstResponder()
        self.textPass.resignFirstResponder()
        self.textPhone.resignFirstResponder()
        self.animateScrollOffset(0.0)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.onFormChangeHandler()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.textEmail {
            textField.returnKeyType = UIReturnKeyType.next
        } else if textField == self.textPass {
            textField.returnKeyType = UIReturnKeyType.done
        } else {
            textField.returnKeyType = UIReturnKeyType.next
        }
        return true
    }
    
    @IBAction func onTerms(_ sender: UIButton?){
        // we might need this in the future as a notification
        // TODO: use a generic webview modal in the future
        // this isn't great UX, but it gets the job done
        // UIApplication.shared.openURL(URL(string: "https://www.domain.com/terms/")!)
        self.zapResponders()
        NotificationCenter.default.post(
            name: LSQ.notification.show.terms,
            object: self,
            userInfo: nil
        )
    }
    
    func onFormChangeHandler(){
        if termsSwitch.isOn {
            self.buttonContinue?.isEnabled = true
        } else {
            self.buttonContinue?.isEnabled = false
        }
        // until we have realtime visual errors, we can't really do this pattern
        // use it only for terms checked
        //print("on change it up son")
        /*
        // no alerts per say, but simply manage state of continue button though
        let validationResults: [String: AnyObject] = self.validateForm()
        // we need to enable it so our
        if validationResults["valid"] as! Bool == false {
            print("meh")
            self.buttonContinue?.isEnabled = false
        }else {
            print("uea son")
            self.buttonContinue?.isEnabled = true
        }
         */
    }
    
    func validateForm() -> [String: AnyObject] {
        var errors: [[String: AnyObject]] = []
        
        if !LSQ.validator.email((self.textEmail?.text!)!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            // do the email validation as well tie into dat static LSQ
            errors.append([
                "object": self.textEmail!,
                "message": "Email is required" as AnyObject
            ])
        }
        
        if (self.textPhone?.text!)! == "" {
            errors.append([
                "object": self.textPhone!,
                "message": "Mobile phone is required" as AnyObject
            ])
        } else if !(self.textPhone?.text?.isPhoneNumber)! {
            errors.append([
                "object": self.textPhone!,
                "message": "A valid mobile phone is required" as AnyObject
            ])
        }
        
        // validate the input format against a regex, double check that with the server side
        if !LSQ.validator.password((self.textPass?.text!)!) {
            errors.append([
                "object": self.textPass!,
                "message": "Password must be at least 8 characters long and contain either a number or a symbol e.g. #!*" as AnyObject
            ])
        }
        
        /*
        if (self.textPass?.text != self.textPass2?.text) {
            errors.append([
                "object": self.textPass2!,
                "message": "Passwords do not match" as AnyObject
            ])
        }
        */
        if self.termsSwitch?.isOn == false {
            errors.append([
                "object": self.termsSwitch!,
                "message": "Please review and agree to our Terms of Use" as AnyObject
            ])
        }
        
        return [
            "valid": errors.count == 0 ? true as AnyObject : false as AnyObject,
            "errors": errors as AnyObject
        ]
    }
    
    // straight up ghetto temp placeholder violators to the 9th level of hell
    @IBAction func onBack(_ sender: AnyObject?){
        NotificationCenter.default.post(
            name: LSQ.notification.show.welcome,
            object: self,
            userInfo: nil
        )
    }
    
    func onSave(){
        EZLoadingActivity.show("", disableUI: true)
        // quick n dirty submission
        // ain't got time for validation here
        let email:String = (self.textEmail?.text!)!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone:String = (self.textPhone?.text!)!.trimmingCharacters(in: .whitespacesAndNewlines) // TODO: regex this more and deal with international blabla
        let pass1:String = (self.textPass?.text!)!.trimmingCharacters(in: .whitespacesAndNewlines)
        // let pass2:String = (self.textPass2?.text!)!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // presence checks, and type checks, memheheheh
        let validationResults: [String: AnyObject] = self.validateForm()
        
        if validationResults["valid"] as! Bool == false {
            // self.validationFails += 1
            
            var messages: [String] = []
            for (_, value) in (validationResults["errors"]! as? [[String: AnyObject]])!.enumerated() {
                messages.append(value["message"] as! String)
            }
            
            let alert: UIAlertController = UIAlertController(
                title: "Validation Errors",
                message: messages.joined(separator: "\n") ,
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                guard let field:UITextField = (validationResults["errors"] as! [[String:AnyObject]])[0]["object"] as? UITextField else {
                    // do nothing, this is a hack to avoid crashing
                    return
                }
                field.becomeFirstResponder()
                self.scrollToView(field)
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            EZLoadingActivity.hide(false, animated: true)
            return
        }
        // let's be crystal clear vs a leading ! because all those stupid optionals blend together
        if self.termsSwitch?.isOn == false {
            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                preferredStyle = UIAlertControllerStyle.actionSheet
            }
            let alert: UIAlertController = UIAlertController(
                title: "Almost There",
                message: "Please review and agree to our Terms of Use",
                preferredStyle: preferredStyle)
            // UX decision? offer link to review, and opt in action, lol, i decline oTT
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                // resign first responder
                self.resignFirstResponder()
                // TODO: option for launching the terms???
            })
            alert.addAction(cancelAction)
            EZLoadingActivity.hide(false, animated: true)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // optimized for swift compiler
        var data: [String: String] = [:]
        data["email"] = email
        data["phone"] = phone
        data["password"] = pass1
        
        // wait for the success
        LSQAPI.sharedInstance.registerUserBasic(
            data as AnyObject,
            success:{ response in
                EZLoadingActivity.hide(true, animated: true)
                // TODO: FML nested networking with callback blocks, is the death of this app
                // ALSO, we have literally 3 of these various networking calls, oh well, FML
                LSQAPI.sharedInstance.getAccessToken(
                    self.textEmail?.text as String!,
                    password: self.textPass?.text as String!,
                    success: { response in
                        // meh meh meh meh
                        let persisted = LSQUser.currentUser.processAccessToken(response: response)
                        if persisted {
                            NotificationCenter.default.post(
                                name: LSQ.notification.action.nextOnboardingStep,
                                object: self,
                                userInfo: nil
                            )
                            LSQUser.currentUser.loaded = true // GHETTO HACK TO AVOID THE FIRST RUN BS, OMG SON
                            LSQUser.currentUser.fetch()
                        } else {
                            // we had an error with the token, or we were unable to persist, or something
                            // see this is sketchy in this context, perhaps we need to process here?
                            // well yes we do
                        }
                },
                    failure: { response in
                        // present this is some way or form, neg
                        // NotificationCenter.default.post(name: LSQ.notification.auth.deauthorize, object: nil)
                    }
                )
                
                // NotificationCenter.default.post(name: LSQ.notification.dismiss.registration, object: self)
                
                // let j = JSON(response)
                
                // ternary town
                //var photoSent: Bool = false
                //if self.capturedImage != nil {
                //    photoSent = true
                //}
                
                // turn around and authenticate via the oauth API
            },
            failure: { response in
                // (response: Alamofire.DataResponse<Any>)
                EZLoadingActivity.hide(true, animated: true)
                            
                var title: String = "Server Error"
                var message: String = "Our server had a problem getting you registered. Please try again or contact us at support@domain.com."
                
                var isExistingAccount: Bool = false
                
                if let theResponse = response as? Alamofire.DataResponse<Any> {
                    if theResponse.response?.statusCode == 400 {
                        title = "Validation Error"
                        // baseline
                        message = "Our system may have found an existing account with that email"
                        
                        // check
                        if theResponse.data != nil {
                            let json: JSON = JSON(data: theResponse.data!)
                            if let m = json["message"].string {
                                message = m
                                // 400 could be existing account and present login, or it could be bum mobile phone, lol decisions
                                // lol bro, potentially too much status code overloading
                                if message.contains("email") {
                                    isExistingAccount = true
                                }
                            }
                        }
                    }
                }
                
                var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                    preferredStyle = UIAlertControllerStyle.actionSheet
                }
                let alert: UIAlertController = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: preferredStyle)
                // wootsy colins
                
                if isExistingAccount {
                    
                    let loginAction: UIAlertAction = UIAlertAction(title:"Attempt Login", style: UIAlertActionStyle.default, handler: { action in
                        NotificationCenter.default.post(
                            name: LSQ.notification.show.login,
                            object: self,
                            userInfo:["email": self.textEmail?.text as Any]
                        )
                    })
                    alert.addAction(loginAction)
                    
                    /*
                     let forgotAction: UIAlertAction = UIAlertAction(title:"Forgot Password", style: UIAlertActionStyle.Default, handler: { action in
                     //
                     })
                     alert.addAction(forgotAction)
                     */
                    
                } else {
                    //alert.addAction(LSQ.action.support)
                }
                
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    if isExistingAccount {
                        //self.emailField.becomeFirstResponder()
                    } else {
                        //self.phoneField.becomeFirstResponder()
                    }
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        )
        
        // save some stuffs to our onboarding manager
        
        // then do this
//        NotificationCenter.default.post(name: LSQ.notification.analytics.event, object: nil, userInfo:[
//            "event": "Register User",
//            "attributes": [
//
//                "AccountId": j["account_id"].string!,
//                "PatientId": j["patient_id"].string!,
//
//                "ValidationFails": self.validationFails,
//                "Photo": photoSent,
//                "ViewDuration": self.durationTimer!.stop()
//            ]
//            ])
    }
    
    @IBAction func onContinue(_ sender: AnyObject?){
        /*
        NotificationCenter.default.post(
            name: LSQ.notification.action.nextOnboardingStep,
            object: self,
            userInfo: nil
        )
        */
        self.onSave()
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        self.animateScrollOffset(0.0)
    }
}
