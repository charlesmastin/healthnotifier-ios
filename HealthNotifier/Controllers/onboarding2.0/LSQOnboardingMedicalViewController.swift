//
//  LSQOnboardingMedicalViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQOnboardingMedicalViewController : LSQOnboardingBaseViewController, UITextFieldDelegate {
    
    @IBOutlet var profileBloodType: UITextField!
    @IBOutlet var profilePulse: UITextField!
    @IBOutlet var profileBPDiastolic: UITextField!
    @IBOutlet var profileBPSystolic: UITextField!
    
    @IBOutlet var container: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var data: JSON? = nil
    var vcMedical: LSQPatientMedicalViewController? {
        return childViewControllers.flatMap({ $0 as? LSQPatientMedicalViewController }).first
    }
    
    // TODO: height of table based on content
    // https://stackoverflow.com/questions/35014362/sizing-a-container-view-with-a-controller-of-dynamic-size-inside-a-scrollview
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LSQAppearanceManager.sharedInstance.underlinedInputs = true
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
        
        self.renderContainer()
    }
    
    func renderContainer(){
        // hahahahahahahaha maybe now?
        if LSQPatientManager.sharedInstance.json != nil {
            self.vcMedical!.data = LSQPatientManager.sharedInstance.json!//self.data! // RISKY NUTS ON THIS SON? yea son
        }
        self.vcMedical!.editMode = true
        self.vcMedical!.configureTable()
        
        _ = setTimeout(0.5, block: { () -> Void in
            // DA FUK SON24
            print("oh snap2?")
            self.vcMedical!.broadcastSize()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // TODO: target specific views bro, because if we capture all this here stuff, we're gonna jack up our embeded view controller
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LSQOnboardingMedicalViewController.tap(_:)))
        //view.addGestureRecognizer(tapGesture)
        
        self.vcMedical!.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        
        // too soon? I guesss
        
        // blabla, and then into the table config brolo
        //self.vcMedical!.view.backgroundColor = LSQ.appearance.color.newTeal
        //self.vcMedical!.tableView.backgroundColor = UIColor.clear
        // header color scheme has to go deep dogs into the VC itself, ugg lolzin
        
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
        self.profileBPDiastolic.inputAccessoryView = customView
        self.profileBPSystolic.inputAccessoryView = customView
        self.profilePulse.inputAccessoryView = customView
        
        self.addObservers()
    }
        
    override func addObservers() {
        self.observationQueue = []
        
        // form field on change brolo, so ghetto town up in dis dis
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.form.field.change,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // get ghetto binding with it now
                if notification.userInfo!["id"] as? String == "bloodtype" {
                    DispatchQueue.main.async(){
                        self.profileBloodType?.text = notification.userInfo!["value"] as? String
                    }
                }
            }
        )
        
        // jimmy hack yourself silly son
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.containerSizeUpdate,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if notification.object != nil {
                    if notification.object is LSQPatientMedicalViewController {
                        if let h = notification.userInfo!["height"] as? Int {
                            self.setContainerHeight(h)
                        }
                    }
                }
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.loaded.patient3,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                // Ghetto workaround for state
                self.renderContainer()
            }
        )
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
    
    func tap(_ gesture: UITapGestureRecognizer) {
        // TODO: target specific views bro, because if we capture all this here stuff, we're gonna jack up our embeded view controller
        // UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        // resign any of our particular first responders brolo only holo
        self.profilePulse.resignFirstResponder()
        self.profileBPSystolic.resignFirstResponder()
        self.profileBPDiastolic.resignFirstResponder()
    }
    
    func setContainerHeight(_ height: Int){
        // meh
        // the container view?
        // or the view controller.view? wtf bro
        // id EmbedVCHeight
        if let c = self.container.constraint(withIdentifier: "EmbedVCHeight") {
            // do stuff with c
            c.constant = CGFloat(height)
            self.container.layoutIfNeeded()// mehzone brolo holo
        }
    }
    
    @IBAction func setH200(_ sender: AnyObject?){
        self.setContainerHeight(200)
    }
    
    @IBAction func setH800(_ sender: AnyObject?){
        self.setContainerHeight(800)
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
    
    func textFieldNext(_ barButtonItem: UIBarButtonItem){
        // oh hell
        let tf = self.firstResponder!
        if tf == self.profileBPSystolic {
            self.profileBPDiastolic.becomeFirstResponder()
            //self.scrollToView(self.profileBPDiastolic)
        } else if tf == self.profileBPDiastolic {
            self.profilePulse.becomeFirstResponder()
            //self.scrollToView(self.profilePulse)
        } else if tf == self.profilePulse {
            self.firstResponder?.resignFirstResponder()
            self.onPressBloodType()
            //self.animateScrollOffset(0.0)
            //self.textPass2.becomeFirstResponder()
            //self.scrollToView(self.textPass2)
        }
        
    }
    
    func textFieldPrev(_ barButtonItem: UIBarButtonItem){
        let tf = self.firstResponder!
        if tf == self.profilePulse {
            self.profileBPDiastolic.becomeFirstResponder()
            //self.firstResponder?.resignFirstResponder()
            //self.animateScrollOffset(0.0)
        } else if tf == self.profileBPDiastolic {
            self.profileBPSystolic.becomeFirstResponder()
            //self.scrollToView(self.textEmail)
        } else if tf == self.profileBPSystolic {
            self.firstResponder?.resignFirstResponder()
        }
    }
    
    func textFieldDone(_ barButtonItem: UIBarButtonItem){
        self.firstResponder?.resignFirstResponder()
        // scrollview reset though brolo
        // self.animateScrollOffset(0.0)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.profileBloodType {
            textField.returnKeyType = UIReturnKeyType.next
            self.onPressBloodType()
            return false
        } else {
            textField.returnKeyType = UIReturnKeyType.next
        }
        return true
    }
    
    func onPressBloodType() {
        // mock up example and then dupe it out
        // TODO: tap from the model definition bro balls
        let collectionInstance = LSQModelProfile()
        let field = collectionInstance.bloodType
        let value = LSQAPI.sharedInstance.getValueForName("patient", attribute: "blood_type", name: self.profileBloodType.text!)
        NotificationCenter.default.post(
            name: LSQ.notification.show.formSelect,
            object: self,
            userInfo: [
                "id": "bloodtype",
                "title": field.label,
                "value": value,
                "values": field.values
            ]
        )
    }
    
    @IBAction func onContinue(_ sender: AnyObject?){
        
        // validation meh, save the profile blood type bro
        // and continue doh, since da collection items are already saved
        if self.profilePulse.text != "" ||
            self.profileBPSystolic.text != "" ||
            self.profileBPDiastolic.text != "" ||
            self.profileBloodType.text != "" {
            
            // so hmm, we take some data set and then we chuck it back at the server though, merging these 4 fields in
            // transaction save
            let patient = self.vcMedical?.data
            var profileFragment = patient!["profile"]
            if self.profilePulse.text != "" {
                profileFragment["pulse"].int = Int(self.profilePulse.text!)
            }
            if self.profileBPSystolic.text != "" {
                profileFragment["bp_systolic"].int = Int(self.profileBPSystolic.text!)
            }
            if self.profileBPDiastolic.text != "" {
                profileFragment["bp_diastolic"].int = Int(self.profileBPDiastolic.text!)
            }
            if self.profileBloodType.text != "" {
                profileFragment["blood_type"].string = LSQAPI.sharedInstance.getValueForName("patient", attribute: "blood_type", name: self.profileBloodType.text!) as String
            }
            // oh brother, comedy central in the house son
            LSQAPI.sharedInstance.updateProfileWithCallbacks(
                profileFragment["uuid"].string!,
                data: profileFragment.object as AnyObject,
                success: { response in
                    // only thing we need to do here is return son really though really
                    // with callbacks though, sketchy AF
                    LSQPatientManager.sharedInstance.fetch()
                    self.continueToNextOnboardingStep()
                },
                failure: { response in
                    
                }
            )
            
            // however, we also have to obtain the VALUES API mapping for the blood type bro
            
            return
            
        }else {
            let patient = self.vcMedical?.data
            // general medical blbalabl
            if patient!["directives"].arrayValue.count == 0 &&
                patient!["medications"].arrayValue.count == 0 &&
                patient!["allergies"].arrayValue.count == 0 &&
                patient!["conditions"].arrayValue.count == 0 &&
                patient!["conditions"].arrayValue.count == 0 &&
                patient!["procedures"].arrayValue.count == 0 &&
                patient!["immunizations"].arrayValue.count == 0 &&
                patient!["documents"].arrayValue.count == 0 {
                
                // OH SNAP
                let alert: UIAlertController = UIAlertController(
                    title: "Proceed with no medical history?",
                    message: "You may enter it later and update at any time but we recommend adding it now.",
                    preferredStyle: .alert)
                let okAction: UIAlertAction = UIAlertAction(title:"Proceed", style: UIAlertActionStyle.default, handler: { action in
                    _ = setTimeout(0.5, block: { () -> Void in
                        self.continueToNextOnboardingStep()
                    })
                })
                alert.addAction(okAction)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                    
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
                return
            } else {
                self.continueToNextOnboardingStep()
            }
            
        }
        
        
        // TEMP TEMP TEMP TEMP
        
        
    }
    
    func continueToNextOnboardingStep(){
        self.removeObservers()
        // async data flow on deeze nuts
        // save the profile medical bits if anything exists, meh, might as well overwrite it anyhow, depending on if we allow peeps to go back and all that jazz
        NotificationCenter.default.post(
            name: LSQ.notification.action.nextOnboardingStep,
            object: self,
            userInfo: nil
        )
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        
    }
}
