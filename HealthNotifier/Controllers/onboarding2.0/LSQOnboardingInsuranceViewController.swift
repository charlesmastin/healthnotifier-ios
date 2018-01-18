//
//  LSQOnboardingInsuranceViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit

class LSQOnboardingInsuranceViewController : LSQOnboardingBaseViewController {
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var continueAction: UIBarButtonItem!
    
    var imageToUpload: UIImage?
    
    @IBAction func onContinue(_ sender: AnyObject?){
        if imageToUpload != nil {
            print("API NOT IMPLEMENTED!!!!!!!!!!!!!!!!")
            // we never implemented this on the server… OOOOOOOOPS
            self.removeObservers()
            NotificationCenter.default.post(
                name: LSQ.notification.action.nextOnboardingStep,
                object: self,
                userInfo: nil
            )
        } else {
            // if continuing
            self.removeObservers()
            NotificationCenter.default.post(
                name: LSQ.notification.action.nextOnboardingStep,
                object: self,
                userInfo: nil
            )
        }
    }
    
    @IBAction func onClear(_ sender: AnyObject?){
        self.clearPhoto()
    }
    
    func clearPhoto(){
        self.imageToUpload = nil
        self.photoView1.image = UIImage(named: "drivers_license")
        // toggle view states brolo
        self.clearButton.alpha = 0.0
        self.clearButton.isEnabled = false
        
        self.ctaButton?.alpha = 1.0
        self.ctaButton?.isEnabled = true
        
        // title bro
        self.continueAction.title = "Skip"
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        NotificationCenter.default.post(
            name: LSQ.notification.action.chooseCaptureMethod,
            object: self,
            userInfo: [
                "title": "Add Insurance Card",
                "message": "Capture the side with your membership details (name, group and policy numbers)."
            ] // currently chokes on nil though
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
    }
    
    @IBOutlet var photoView1: UIImageView!
    @IBOutlet var photoView2: UIImageView!
    
    // observers though, needs to be a protocol sonny bunzos
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: setup circlecroppers86™ MASK
        self.photoView1?.contentMode = UIViewContentMode.scaleAspectFit
        self.photoView2?.contentMode = UIViewContentMode.scaleAspectFit
        self.addObservers()
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
                self.imageToUpload = (notification.userInfo!["image"] as? UIImage)!
                self.photoView1?.image = (notification.userInfo!["image"] as? UIImage)!
                
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
