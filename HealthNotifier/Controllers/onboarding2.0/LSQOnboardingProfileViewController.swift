//
//  LSQOnboardingProfileViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQOnboardingProfileViewController : LSQOnboardingBaseViewController, UITextFieldDelegate {
    
    // TODO: FML on optionals and access though
    
    @IBOutlet var profileFirstName: UITextField!
    @IBOutlet var profileLastName: UITextField!
    @IBOutlet var profileMiddleName: UITextField!
    @IBOutlet var profileDob: UITextField!
    
    // residence
    @IBOutlet var residenceAddress1: UITextField!
    @IBOutlet var residenceAddress2: UITextField!
    @IBOutlet var residenceCity: UITextField!
    @IBOutlet var residenceState: UITextField!
    @IBOutlet var residencePostal: UITextField!
    @IBOutlet var residenceCountry: UITextField!
    // demographics though
    @IBOutlet var profileGender: UITextField!
    @IBOutlet var profileHairColor: UITextField!
    @IBOutlet var profileEyeColor: UITextField!
    @IBOutlet var profileWeight: UITextField!
    @IBOutlet var profileHeight: UITextField!
    var profileHeightValue: Int?
    
    @IBOutlet var labelTitle: UILabel!
    
    @IBOutlet var buttonContinue: UIBarButtonItem!
    
    @IBOutlet var contentView: UIView!
    // organ donor though
    
    var created: Bool = false

    var importedJson: JSON? = nil
    @IBOutlet var licenseImage: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    func exitOnboarding(){
        
        // do something a little different
        
        // this is too heavy handed, but we'll cross the bridge when we wire onboarding into regular patient setup flows in the app bro
        
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        
        var message: String = ""
        if LSQUser.currentUser.patientsCount == 0 {
            message = "Your profile and LifeSticker have not been setup. To resume setup, please login first."
        } else {
            message = "Your profile was not created."
        }
        
        // message the user it was invlaid O lordy Lord
        let alert: UIAlertController = UIAlertController(
            title: "Incomplete Setup!",
            message: message,
            preferredStyle: preferredStyle)
        let okAction: UIAlertAction = UIAlertAction(title:"Exit Setup", style: UIAlertActionStyle.default, handler: { action in
            self.removeObservers()
            LSQAppearanceManager.sharedInstance.reset()
            // TODO: THIS IS NOT EFFECTIVE ENOUGH
            // this is crash worthy bro
            // TODO: so not sure what API do get the data from
            // disgusting disgusting check for the main tab controller
            if LSQUser.currentUser.patientsCount == 0 {
                LSQScanHistory.sharedInstance.purgeKeychain()
                LSQUser.currentUser.purgeKeychain()
                LSQTouchAuthManager.sharedInstance.purgeKeychain()
                NotificationCenter.default.post(
                    name: LSQ.notification.action.logout,
                    object: self
                )
            } else {
                self.dismissMe(animated: true, completion: nil)
                if self.importedJson != nil && LSQUser.currentUser.patientsCount >= 1 {
                    // TEMP LAST DITCH EFFOR HERE
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.tabController,
                        object: self
                    )
                    // meh meh meh meh
                }
            }
        })
        
        alert.addAction(okAction)
        let cancelAction: UIAlertAction = UIAlertAction(title:"Continue Setup", style: UIAlertActionStyle.cancel, handler: { action in
            
        })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TEMP TEMP TEMP
        // FIXME: meh
        if self.tabBarController != nil || self.parent?.tabBarController != nil {
            self.tabBarController?.hidesBottomBarWhenPushed = true
        }
        
        LSQAppearanceManager.sharedInstance.underlinedInputs = true
        
        
        // we could use a super top level default clearing call here, lolzin
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LSQOnboardingProfileViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        // LOLO BROLO
        
        // hacks to confirm validation in "realtime" on required inputs
        self.profileFirstName.addTarget(self, action: #selector(LSQOnboardingProfileViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.profileLastName.addTarget(self, action: #selector(LSQOnboardingProfileViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        // LOLZONE
        
        // actually make this the Exit Setup
        backButton = UIBarButtonItem(title: "Exit Setup", style: .plain, target: self, action: #selector(LSQOnboardingProfileViewController.exitOnboarding))
        navigationItem.leftBarButtonItem = backButton
        backButton.isEnabled = true
        
        // TODO: build from a UI utils library
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
        profileFirstName.inputAccessoryView = customView
        profileMiddleName.inputAccessoryView = customView
        profileLastName.inputAccessoryView = customView
        profileWeight.inputAccessoryView = customView
        residenceAddress1.inputAccessoryView = customView
        residenceAddress2.inputAccessoryView = customView
        residenceCity.inputAccessoryView = customView
        residencePostal.inputAccessoryView = customView
        
        // lolzin
        self.addObservers()
        
    }
    
    // TODO: UIview scroll to focus brolo
    
    func textFieldNext(_ barButtonItem: UIBarButtonItem){
        // oh hell
        let tf = self.firstResponder!
        if tf == self.profileFirstName {
            self.profileMiddleName.becomeFirstResponder()
            self.scrollToView(self.profileMiddleName)
        } else if tf == self.profileMiddleName {
            self.profileLastName.becomeFirstResponder()
            self.scrollToView(self.profileLastName)
        } else if tf == self.profileLastName {
            self.profileLastName.resignFirstResponder()
            self.onPressDob()
        } else if tf == profileWeight {
            self.profileWeight.resignFirstResponder()
            self.onPressHairColor()
        } else if tf == self.residenceAddress1 {
            self.residenceAddress2.becomeFirstResponder()
            self.scrollToView(self.residenceAddress2)
        } else if tf == self.residenceAddress2 {
            self.residenceCity.becomeFirstResponder()
            self.scrollToView(self.residenceCity)
        } else if tf == self.residenceCity {
            self.residenceCity.resignFirstResponder()
            self.onPressState()
        } else if tf == self.residencePostal {
            self.residencePostal.resignFirstResponder()
            self.onPressCountry()
        }
    }
    
    func textFieldPrev(_ barButtonItem: UIBarButtonItem){
        let tf = self.firstResponder!
        if tf == self.profileFirstName {
            self.profileFirstName.resignFirstResponder()
            self.onPressCountry()
        } else if tf == self.profileMiddleName {
            self.profileFirstName.becomeFirstResponder()
            self.scrollToView(self.profileFirstName)
        } else if tf == self.profileLastName {
            self.profileMiddleName.becomeFirstResponder()
            self.scrollToView(self.profileMiddleName)
        } else if tf == profileWeight {
            self.profileWeight.resignFirstResponder()
            self.onPressHeight()
        } else if tf == self.residenceAddress1 {
            self.residenceAddress1.resignFirstResponder()
            self.onPressEyeColor()
        } else if tf == self.residenceAddress2 {
            self.residenceAddress1.becomeFirstResponder()
            self.scrollToView(self.residenceAddress1)
        } else if tf == self.residenceCity {
            self.residenceAddress2.becomeFirstResponder()
            self.scrollToView(self.residenceAddress2)
        } else if tf == self.residencePostal {
            self.residencePostal.resignFirstResponder()
            self.onPressState()
        }
    }
    
    // TODO: combine the focus effort up in this bizzle, meh, meh mehzone
    
    func textFieldDone(_ barButtonItem: UIBarButtonItem){
        self.firstResponder?.resignFirstResponder()
    }
    
    func textFieldDidChange(_ textField: UITextField){
        self.onFormChangeHandler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // lolzin
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        LSQAppearanceManager.sharedInstance.underlinedInputs = true
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
        if self.importedJson != nil {
            self.populateWithJson(json: self.importedJson!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = setTimeout(0.5, block: { () -> Void in
            //self.hideCTA()
        })
    }
    
    func hideCTA(){
        self.licenseImage.isHidden = true
        self.ctaButton?.isHidden = true
        if let c = self.contentView.constraint(withIdentifier: "CFirstNameTop") {
            c.constant = CGFloat(50)
        }
        if let c = self.contentView.constraint(withIdentifier: "CMiddleNameTop") {
            c.constant = CGFloat(50)
        }
        if let c = self.contentView.constraint(withIdentifier: "CProfileTop") {
            c.constant = CGFloat(20)
        }
        self.contentView.layoutIfNeeded()
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    override func addObservers() {
        print("ADD THE MF OBSERVERS")
        self.observationQueue = []
        
        // form field on change brolo, so ghetto town up in dis dis
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.form.field.change,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // get ghetto binding with it now
                if notification.userInfo!["id"] as? String == "birthdate" {
                    // string value, no need to store raw date, ish?w
                    DispatchQueue.main.async(){
                        self.profileDob.text = notification.userInfo!["value"] as? String
                    }
                }
                if notification.userInfo!["id"] as? String == "height" {
                    // JW ON YOUR JW OPTIONAL MOTHER F
                    let formattedDonkey = LSQ.formatter.heightToImperial(Int((notification.userInfo!["value"] as? String)!)!)
                    self.profileHeightValue = Int((notification.userInfo!["value"] as? String)!)!
                    DispatchQueue.main.async(){
                        self.profileHeight.text = formattedDonkey
                    }
                }
                if notification.userInfo!["id"] as? String == "gender" {
                    let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "gender", value: (notification.userInfo!["value"] as? String)!)
                    DispatchQueue.main.async(){
                        self.profileGender.text = formattedDonkey
                    }
                }
                if notification.userInfo!["id"] as? String == "haircolor" {
                    let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "hair_color", value: (notification.userInfo!["value"] as? String)!)
                    DispatchQueue.main.async(){
                        self.profileHairColor.text = formattedDonkey
                    }
                }
                if notification.userInfo!["id"] as? String == "eyecolor" {
                    let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "eye_color", value: (notification.userInfo!["value"] as? String)!)
                    DispatchQueue.main.async(){
                        self.profileEyeColor.text = formattedDonkey
                    }
                }
                if notification.userInfo!["id"] as? String == "state" {
                    let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("state", attribute: nil, value: (notification.userInfo!["value"] as? String)!)
                    DispatchQueue.main.async(){
                        self.residenceState.text = formattedDonkey
                    }
                }
                if notification.userInfo!["id"] as? String == "country" {
                    let formattedDonkey = LSQAPI.sharedInstance.getNameForValue("country", attribute: nil, value: (notification.userInfo!["value"] as? String)!)
                    DispatchQueue.main.async(){
                        self.residenceCountry.text = formattedDonkey
                    }
                }
                self.onFormChangeHandler()
            }
        )
    }
    
    func onFormChangeHandler(){
        // are all required fields filled brolo
        let validationResults: [String: AnyObject] = self.validateForm()
        if validationResults["valid"] as! Bool == false {
            self.buttonContinue?.isEnabled = false
        }else {
            self.buttonContinue?.isEnabled = true
        }
    }
    
    func onSave(){
        
        // format date back to the other format, lol son - yuggins
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let d = dateFormatter.date(from: self.date!)
//        let outputFormat = DateFormatter()
//        outputFormat.dateFormat = "MM/dd/yyyy"
        
        EZLoadingActivity.show("", disableUI: true)
        // TODO: validation an all that
        // TODO: flat json vs nested objects lolzin
        
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
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            EZLoadingActivity.hide(false, animated: true)
            return
        }
        
        var data: [String : AnyObject] =
            [
                "first_name": self.profileFirstName.text as AnyObject,
                "last_name": self.profileLastName.text as AnyObject,
                "birthdate": self.profileDob.text as AnyObject, // TODO: format?
            ]
        if self.profileMiddleName.text != "" {
            data["middle_name"] = self.profileMiddleName.text as AnyObject
        }
        if self.profileGender.text != "" {
            data["gender"] = LSQAPI.sharedInstance.getValueForName("patient", attribute: "gender", name: self.profileGender.text!) as AnyObject
        }
        if self.profileHeightValue != nil {
            data["height"] = self.profileHeightValue as AnyObject
        }
        // TODO: cast to int, although our server is helping your laziness out
        if self.profileWeight.text != "" {
            data["weight"] = LSQ.formatter.weightToMetric(Int(self.profileWeight.text!)!) as AnyObject
        }
        if self.profileEyeColor.text != "" {
            data["eye_color"] = LSQAPI.sharedInstance.getValueForName("patient", attribute: "eye_color", name: self.profileEyeColor.text!) as AnyObject
        }
        if self.profileHairColor.text != "" {
            data["hair_color"] = LSQAPI.sharedInstance.getValueForName("patient", attribute: "hair_color", name: self.profileHairColor.text!) as AnyObject
        }
        
        if self.residenceAddress1.text != "" {
            let residence: [String: AnyObject] = [
                "address_line1": self.residenceAddress1.text as AnyObject,
                "address_line2": self.residenceAddress2.text as AnyObject,
                "city": self.residenceCity.text as AnyObject,
                "state_province": LSQAPI.sharedInstance.getValueForName("state", attribute: nil, name: self.residenceState.text!) as AnyObject,
                "postal_code": self.residencePostal.text as AnyObject,
                "country": LSQAPI.sharedInstance.getValueForName("country", attribute: nil, name: self.residenceCountry.text!) as AnyObject, // #MERICASON
            ]
            data["residence"] = residence as AnyObject // hashtagtypecastingfordays
        }
        EZLoadingActivity.hide(true, animated: true)
        
        LSQAPI.sharedInstance.createPatientBasic(
            data as AnyObject,
            success:{ response in
                self.removeObservers()
                EZLoadingActivity.hide(true, animated: true)
         
                // read the patient_id(uuid) that came back and assign it into our session yo!
                let j = JSON(response)
                
                // possible race conditions?
                print("NEW PATIENT UUID = \(j["uuid"].string!)")
                
                LSQPatientManager.sharedInstance.uuid = j["uuid"].string!
                LSQPatientManager.sharedInstance.fetch()
                LSQUser.currentUser.fetch()
                
                self.created = true
                
                // yea son
                NotificationCenter.default.post(
                    name: LSQ.notification.action.nextOnboardingStep,
                    object: self,
                    userInfo: nil
                )
             },
            failure:{ response in
                EZLoadingActivity.hide(true, animated: true)
                // TODO: let the people know it bailed though
                // oh you'll know, silent fail for dayZ
             }
        )
    }
    
    @IBAction func onContinue(_ sender: AnyObject?){
//        NotificationCenter.default.post(
//            name: LSQ.notification.action.nextOnboardingStep,
//            object: self,
//            userInfo: nil
//        )
         self.onSave()
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        self.removeObservers()
        NotificationCenter.default.post(
            name: LSQ.notification.show.scanImport,
            object: self,
            userInfo: nil
        )
    }
    
    // map to all possible IBOutlets
    // THERE SHOULD NEVER BE A CASE FOR PRE-POPULATING THIS FORM, exception local storage during onboarding fails… meh
    // this state of UI should never render populated since it's impossible to skip this step on any platform.
    
    //
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
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.scrollView.contentOffset.y = CGFloat(y)
            }, completion: nil)
        }
        // self.scrollView.contentOffset = CGPoint(x: 0.0, y: y)
    }
    
    
    func populateWithJson(json: JSON) -> Void {
        
        // TODO: make this work for restoring the natural profile object, and also the incoming blabla
        // since the api is not currently in use, we can do something there. to hack it
        
        // check top "results" node again, just for sursies
        // consider cleanup at the API level though
        // now change the label to the friendly value bablabla
        self.labelTitle?.text = "We found the following from your license."
        self.hideCTA()
        if let fname = json["results"]["first_name"].string {
            self.profileFirstName.text = fname
        }
        if let mname = json["results"]["middle_name"].string {
            profileMiddleName.text = mname
        }
        if let lname = json["results"]["last_name"].string {
            profileLastName.text = lname
        }
        if let dob = json["results"]["birthdate"].string {
            profileDob.text = dob
        }
        if let gender = json["results"]["gender"].string {
            profileGender.text = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "gender", value: gender)
        }
        if let address1 = json["results"]["address_line1"].string {
            residenceAddress1.text = address1
        }
        if let city = json["results"]["city"].string {
            residenceCity.text = city
        }
        if let state = json["results"]["state_province"].string {
            residenceState.text = LSQAPI.sharedInstance.getNameForValue("state", attribute: nil, value: state)
        }
        if let postal = json["results"]["postal_code"].string {
            residencePostal.text = postal
        }
        if let country = json["results"]["country"].string {
            residenceCountry.text = LSQAPI.sharedInstance.getNameForValue("country", attribute: nil, value: country)
        }
        
        if let height = json["results"]["height"].int {
            //profileHeight?.text = "\(height)"
            profileHeightValue = LSQ.formatter.inchesToCentimeters(height)
            profileHeight.text = "\(LSQ.formatter.heightToImperial(LSQ.formatter.inchesToCentimeters(height)))"
        }
        
        if let weight = json["results"]["weight"].int {
            profileWeight.text = "\(weight)"
            //profileWeight?.text = "\(weight) lbs"
        }
        
        if let hairColor = json["results"]["hair_color"].string {
            profileHairColor.text = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "hair_color", value: hairColor)
        }
        
        if let eyeColor = json["results"]["eye_color"].string {
            profileEyeColor.text = LSQAPI.sharedInstance.getNameForValue("patient", attribute: "eye_color", value: eyeColor)
        }
        
        self.onFormChangeHandler()
    }
    
    // FML Keyboard UX and all that jazz
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = true
        if textField == self.profileFirstName {
            self.profileMiddleName.becomeFirstResponder()
            self.scrollToView(self.profileMiddleName)
        } else if textField == self.profileMiddleName {
            self.profileLastName.becomeFirstResponder()
            self.scrollToView(self.profileLastName)
        } else if textField == self.profileLastName {
            self.profileDob.becomeFirstResponder()
        } else if textField == self.profileWeight {
            self.profileHairColor.becomeFirstResponder()
        } else if textField == self.residenceAddress1 {
            self.residenceAddress2.becomeFirstResponder()
            self.scrollToView(self.residenceAddress2)
        } else if textField == self.residenceAddress2 {
            self.residenceCity.becomeFirstResponder()
            self.scrollToView(self.residenceCity)
        } else if textField == self.residenceCity {
            self.residenceState.becomeFirstResponder()
        } else if textField == self.residencePostal {
            self.residenceCountry.becomeFirstResponder()
        }
        return shouldReturn
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.profileFirstName {
            self.scrollToView(self.profileFirstName)
        }
        if textField == self.residenceAddress1 {
            self.scrollToView(self.residenceAddress1)
        }
        if textField == self.profileWeight {
            self.scrollToView(self.profileWeight)
        }
        if textField == self.residencePostal {
            self.scrollToView(self.residencePostal)
        }
        if textField == self.profileGender {
            textField.returnKeyType = UIReturnKeyType.next
            self.onPressGender()
            return false
        } else if textField == self.profileDob {
            textField.returnKeyType = UIReturnKeyType.next
            self.onPressDob()
            return false
        } else if textField == self.profileHeight {
            textField.returnKeyType = UIReturnKeyType.next
            self.onPressHeight()
            return false
        } else if textField == self.profileHairColor {
            textField.returnKeyType = UIReturnKeyType.next
            self.onPressHairColor()
            return false
        } else if textField == self.profileEyeColor {
            textField.returnKeyType = UIReturnKeyType.next
            self.onPressEyeColor()
            return false
        } else if textField == self.residenceState {
            textField.returnKeyType = UIReturnKeyType.next
            self.onPressState()
            return false
        } else if textField == self.residenceCountry {
            textField.returnKeyType = UIReturnKeyType.next
            self.onPressCountry()
            return false
        } else {
            textField.returnKeyType = UIReturnKeyType.next
        }
        return true
    }
    
    // TODO: on change though brolo, more realtime on this bitch
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.onFormChangeHandler()
    }
    
    

    
    
    // onpress dob
    // IBaction or just method, meh meh
    func onPressDob() {
        var userInfo: [String: AnyObject] = [
            "id": "birthdate" as AnyObject,
            "title": "Select Birthdate" as AnyObject
        ]
        if self.profileDob.text != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            userInfo["value"] = dateFormatter.date(from: self.profileDob.text!) as AnyObject?
        }
        NotificationCenter.default.post(
            name: LSQ.notification.show.formDatePicker,
            object: self,
            userInfo: userInfo
        )
    }
    
    // onpress height
    func onPressHeight() {
        let collectionInstance = LSQModelProfile()
        let field = collectionInstance.height
        var userInfo: [String: AnyObject] = [
            "id": "height" as AnyObject,
            "title": field.label as AnyObject
        ]
        if self.profileHeightValue != nil {
            userInfo["value"] = self.profileHeightValue! as AnyObject?
        }
        // serialize existing height from CM son, this is a bit sketchy since we're now losing precision, WTF AMERICANS
        NotificationCenter.default.post(
            name: LSQ.notification.show.formHeightPicker,
            object: self,
            userInfo: userInfo
        )
    }
    
    // onpress weignt
    
    // onpress gender
    func onPressGender() {
        // mock up example and then dupe it out
        // TODO: tap from the model definition bro balls
        let collectionInstance = LSQModelProfile()
        let field = collectionInstance.gender
        let value = LSQAPI.sharedInstance.getValueForName("patient", attribute: "gender", name: self.profileGender.text!)
        NotificationCenter.default.post(
            name: LSQ.notification.show.formSelect,
            object: self,
            userInfo: [
                "id": "gender",
                "title": field.label,
                "value": value, // TODO Current Value Son
                "values": field.values
            ]
        )
    }
    
    // onpress hair
    func onPressHairColor() {
        // mock up example and then dupe it out
        // TODO: tap from the model definition bro balls
        let collectionInstance = LSQModelProfile()
        let field = collectionInstance.hairColor
        let value = LSQAPI.sharedInstance.getValueForName("patient", attribute: "hair_color", name: self.profileHairColor.text!)
        NotificationCenter.default.post(
            name: LSQ.notification.show.formSelect,
            object: self,
            userInfo: [
                "id": "haircolor",
                "title": field.label,
                "value": value, // TODO Current Value Son
                "values": field.values
            ]
        )
    }
    
    // onpress eye
    func onPressEyeColor() {
        // mock up example and then dupe it out
        // TODO: tap from the model definition bro balls
        let collectionInstance = LSQModelProfile()
        let field = collectionInstance.eyeColor
        let value = LSQAPI.sharedInstance.getValueForName("patient", attribute: "eye_color", name: self.profileEyeColor.text!)
        NotificationCenter.default.post(
            name: LSQ.notification.show.formSelect,
            object: self,
            userInfo: [
                "id": "eyecolor",
                "title": field.label,
                "value": value, // TODO Current Value Son
                "values": field.values
            ]
        )
    }
    
    // onpress state? meh meh, FML international
    func onPressState() {
        // DEPENDING ON CURRENT COUNTRY VALUE BRO
        // mock up example and then dupe it out
        // TODO: tap from the model definition bro balls
        let collectionInstance = LSQModelPatientResidence()
        let field = collectionInstance.stateSelect
        let value = LSQAPI.sharedInstance.getValueForName("state", attribute: nil, name: self.residenceState.text!)
        NotificationCenter.default.post(
            name: LSQ.notification.show.formSelect,
            object: self,
            userInfo: [
                "id": "state",
                "title": field.label,
                "value": value, // TODO Current Value Son
                "values": field.values
            ]
        )
    }
    
    // onpress country, put it first though, as US, blablabla
    func onPressCountry() {
        // mock up example and then dupe it out
        // TODO: tap from the model definition bro balls
        let collectionInstance = LSQModelPatientResidence()
        let field = collectionInstance.country
        let value = LSQAPI.sharedInstance.getValueForName("country", attribute: nil, name: self.residenceCountry.text!)
        NotificationCenter.default.post(
            name: LSQ.notification.show.formSelect,
            object: self,
            userInfo: [
                "id": "country",
                "title": field.label,
                "value": value, // TODO Current Value Son
                "values": field.values
            ]
        )
    }
    
    func validateForm() -> [String: AnyObject] {
        var errors: [[String: AnyObject]] = []
        
        if self.profileFirstName.text == "" {
            // do the email validation as well tie into dat static LSQ
            errors.append([
                "object": self.profileFirstName,
                "message": "First name is required" as AnyObject
            ])
        }
        
        if self.profileLastName.text == "" {
            // do the email validation as well tie into dat static LSQ
            errors.append([
                "object": self.profileLastName,
                "message": "Last name is required" as AnyObject
            ])
        }
        // dob son, from the widget though ain't no thang
        if self.profileDob.text == "" {
            // do the email validation as well tie into dat static LSQ
            errors.append([
                "object": self.profileDob,
                "message": "Date of birth is required" as AnyObject
            ])
        }
        
        // TODO: validate our FIRST account profile is 18 years of age or older SON!!!!
        
//        if self.date == nil {
//            errors.append([
//                "object": self.dobField,
//                "message": "Must be at least 18 years old to register" as AnyObject
//                ])
//        } else {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            let d = dateFormatter.date(from: self.date!)
//            let age: Int = LSQ.formatter.ageFromBirthday(d!)
//            // oh my, this is probably double trouble here
//            if age < 18 {
//                errors.append([
//                    "object": self.dobField,
//                    "message": "Must be 18 years or older." as AnyObject
//                    ])
//            }
//        }
        
        // well form some stuffs
        // the height / weight, all that should be handled by the widgets though
        // if address line 1 is present, then go into full validation mode on the address
        if self.residenceAddress1.text != "" {
            // require the full set of residence data at this point
            // city
            if self.residenceCity.text == "" {
                errors.append([
                    "object": self.residenceCity,
                    "message": "City required if adding residence" as AnyObject
                ])
            }
            // state
            if self.residenceState.text == "" {
                errors.append([
                    "object": self.residenceState,
                    "message": "State required if adding residence" as AnyObject
                ])
            }
            // postal
            if self.residencePostal.text == "" {
                errors.append([
                    "object": self.residencePostal,
                    "message": "Postal Code required if adding residence" as AnyObject
                ])
            }
            // country
            if self.residenceCountry.text == "" {
                errors.append([
                    "object": self.residenceCountry,
                    "message": "Country required if adding residence" as AnyObject
                ])
            }
        }
        
        return [
            "valid": errors.count == 0 ? true as AnyObject : false as AnyObject,
            "errors": errors as AnyObject
        ]
    }
}
