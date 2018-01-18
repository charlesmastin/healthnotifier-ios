//
//  LSQOnboardingBaseViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit

class LSQOnboardingBaseViewController : UIViewController {
    
    var resumed: Bool = false
    
    // OMG make an extension for observable manager etc
    var observationQueue: [AnyObject] = []
    
    var backButton: UIBarButtonItem!
    
    @IBOutlet var continueButton: UIButton?
    @IBOutlet var cancelButton: UIButton?
    @IBOutlet var ctaButton: UIButton?
    
    // stubbed nav
    /*
    @IBAction func onContinue() {
        
    }
    */
    func addObservers() {
        print("base add observers non-op")
    }
    
    
    
    // background color
    
    // logo, blabla
    
    func removeObservers() {
        print("BASE REMOVE OBSERVERS!")
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    // TODO: this perhaps needs to be moved to viewDidUnload or something not sure of the entire context it can be rendered visually
    deinit {
        self.removeObservers()
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        print("base view will appear")
        super.viewWillAppear(animated)
        self.removeObservers()
        self.addObservers()
    }
     */
    /*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            print("MISTAKE OF THE YEAR")
            self.removeObservers()
        }
        if self.isMovingToParentViewController {
            print("VIEW GOING BYE BYE BYE BBB")
        }
    }
     */
}
