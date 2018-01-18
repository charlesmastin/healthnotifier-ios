//
//  LSQOnboardingPhotoViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit
import EZLoadingActivity

class LSQOnboardingPhotoViewController : LSQOnboardingBaseViewController {
    
    @IBOutlet weak var continueAction: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIButton!
    var profilePhoto: UIImage?
    
    @IBAction func onClear(_ sender: AnyObject?){
        self.clearPhoto()
    }
    
    func clearPhoto(){
        self.profilePhoto = nil
        self.photoView.image = UIImage(named: "profile_pic")
        // toggle view states brolo
        self.clearButton.alpha = 0.0
        self.clearButton.isEnabled = false
        
        self.ctaButton?.alpha = 1.0
        self.ctaButton?.isEnabled = true
        
        // title bro
        self.continueAction.title = "Skip"
    }
    
    @IBAction func onContinue(_ sender: AnyObject?){
        if self.profilePhoto != nil {
            self.submit()
        } else {
            print("TODO: alert to confirm skipping photo though brolo")
            // alert to confirm, mehemehehehehehehehe
            self.removeObservers()
            NotificationCenter.default.post(
                name: LSQ.notification.action.nextOnboardingStep,
                object: self,
                userInfo: nil
            )
        }
    }
    
    func submit(){
        // TODO: validation? meh meh meh
        
        // submit via the regular API bro bra
        
        var payload: [String: AnyObject] = [:]
        let fileContents: String = LSQ.formatter.imageToBase64(self.profilePhoto!, mode: "jpeg", compression: 0.5)
        payload["ProfilePhoto"] = [
            "Name": "ios-app-upload-image.jpg",
            "File": fileContents,
            "Mimetype": "image/jpeg"
            ] as AnyObject
        // TODO: crop dimensions son
        EZLoadingActivity.show("", disableUI: true)
        LSQAPI.sharedInstance.updateProfilePhoto(
            LSQPatientManager.sharedInstance.uuid!,
            data: payload as AnyObject,
            success: { response in
                EZLoadingActivity.hide(true, animated: true)
                self.removeObservers()
                NotificationCenter.default.post(
                    name: LSQ.notification.action.nextOnboardingStep,
                    object: self,
                    userInfo: nil
                )
            },
            failure: { response in
                EZLoadingActivity.hide(false, animated: true)
            }
        )
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        NotificationCenter.default.post(
            name: LSQ.notification.action.chooseCaptureMethod,
            object: self,
            userInfo: [
                // if less than 2, just do the thing directly, lol
                // "methods": ["photo", "library"],// this should be the default son
                "selfie": true // prefere
            ]
        )
    }
    
    // change the continue button / or CTA, etc etc
    
    @IBOutlet var photoView: UIImageView!
    
    // observers though, needs to be a protocol sonny bunzos
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: setup circlecroppers86™ MASK 
        self.photoView?.contentMode = UIViewContentMode.scaleAspectFit
        // scaleAspectFill
        self.addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //meh
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
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
    
    override func addObservers() {
        self.observationQueue = []
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.imageCaptured,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.profilePhoto = (notification.userInfo!["image"] as? UIImage)!
                self.photoView?.image = (notification.userInfo!["image"] as? UIImage)!
                
                // toggle view states brolo
                self.clearButton.alpha = 1.0
                self.clearButton.isEnabled = true
                
                self.ctaButton?.alpha = 0.0
                self.ctaButton?.isEnabled = false
                
                // title bro
                self.continueAction.title = "Continue"
                
            }
        )
        
    }
    
}
