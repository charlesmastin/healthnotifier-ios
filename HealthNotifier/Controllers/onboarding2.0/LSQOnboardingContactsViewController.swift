//
//  LSQOnboardingContactsViewController.swift
//
//  Created by Charles Mastin on 7/31/17.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQOnboardingContactsViewController : LSQOnboardingBaseViewController {
    
    var data: JSON? = nil
    var vcEmergency: LSQProfileEmergencyViewController? {
        return childViewControllers.flatMap({ $0 as? LSQProfileEmergencyViewController }).first
    }
    
    @IBOutlet var container: UIView!
    
    // consider base class implementation bro ho
    func exitOnboarding(){
        
        // do something a little different
        
        // this is too heavy handed, but we'll cross the bridge when we wire onboarding into regular patient setup flows in the app bro
        
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        
        let message: String = "Your profile and LifeSticker have not been setup. You may resume at any time."
        
        // message the user it was invlaid O lordy Lord
        let alert: UIAlertController = UIAlertController(
            title: "Incomplete Setup!",
            message: message,
            preferredStyle: preferredStyle)
        let okAction: UIAlertAction = UIAlertAction(title:"Exit Setup", style: UIAlertActionStyle.default, handler: { action in
            LSQAppearanceManager.sharedInstance.reset()
            self.dismissMe(animated: true, completion: nil)
            // OMG
            // TEMP hack for the bypass the cutoff lolzin
            if LSQUser.currentUser.patientsCount >= 1 {
                // TEMP LAST DITCH EFFOR HERE
                NotificationCenter.default.post(
                    name: LSQ.notification.show.tabController,
                    object: self
                )
                // meh meh meh meh
            }
        })
        
        alert.addAction(okAction)
        let cancelAction: UIAlertAction = UIAlertAction(title:"Continue Setup", style: UIAlertActionStyle.cancel, handler: { action in
            
        })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        if LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor != nil {
            self.view.backgroundColor = LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor!
        }
        //self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
        if self.resumed {
            backButton = UIBarButtonItem(title: "Exit Setup", style: .plain, target: self, action: #selector(LSQOnboardingContactsViewController.exitOnboarding))
            navigationItem.leftBarButtonItem = backButton
            backButton.isEnabled = true
        }
        
        self.renderContainer()
    }
    
    func renderContainer(){
        if LSQPatientManager.sharedInstance.json != nil {
            self.vcEmergency!.data = LSQPatientManager.sharedInstance.json!//self.data! // RISKY NUTS ON THIS SON? yea son
        }
        self.vcEmergency!.editMode = true
        self.vcEmergency!.showAddCell = false // yea brobrizzle
        self.vcEmergency!.configureTable()
        
        _ = setTimeout(0.5, block: { () -> Void in
            // DA FUK SON24
            print("oh snap2?")
            self.vcEmergency!.broadcastSize()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("OH SNAP IN HERE")
        LSQAppearanceManager.sharedInstance.defaultViewBackgroundColor = LSQ.appearance.color.newTeal // to jumpstart the rendering of the table cells though bro
        
        
        self.vcEmergency!.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        
        
        // blabla, and then into the table config brolo
        //self.vcEmergency!.view.backgroundColor = LSQ.appearance.color.newTeal
        //self.vcEmergency!.tableView.backgroundColor = UIColor.clear
        // header color scheme has to go deep dogs into the VC itself, ugg lolzin
        self.addObservers()
    }
    
    override func addObservers() {
        self.observationQueue = []
        
        // jimmy hack yourself silly son
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.containerSizeUpdate,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if notification.object != nil {
                    if notification.object is LSQProfileEmergencyViewController {
                        if let h = notification.userInfo!["height"] as? Int {
                            self.setContainerHeight(h + 44) // quick hack? meh wtf
                            // holy cow bro
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
    
    @IBAction func onContinue(_ sender: AnyObject?){
        
        // TODO: validation on 0 emergency contacts and skipping, throw an alert dialog
        // this is our main value prop at this point
        // meh
        // careful access to the data though
        let patient = self.vcEmergency?.data
        // this is sketchy and dangerous but on
        if patient!["emergency"].arrayValue.count == 0 {
            // OH SNAP
            let alert: UIAlertController = UIAlertController(
                title: "Proceed with no emergency contacts?",
                message: "You may enter them later but we recommend adding now.",
                preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title:"Proceed", style: UIAlertActionStyle.default, handler: { action in
                // delay so transition isn't bogged down
                _ = setTimeout(0.5, block: { () -> Void in
                    self.removeObservers()
                    NotificationCenter.default.post(
                        name: LSQ.notification.action.nextOnboardingStep,
                        object: self,
                        userInfo: nil
                    )
                })
            })
            alert.addAction(okAction)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        } else {
            self.removeObservers()
            NotificationCenter.default.post(
                name: LSQ.notification.action.nextOnboardingStep,
                object: self,
                userInfo: nil
            )
        }
        
        
    }
    
    @IBAction func onCta(_ sender: UIButton?){
        NotificationCenter.default.post(
            name: LSQ.notification.show.collectionItemForm,
            object: self,
            userInfo: [
                // this is the Add mode, aka no collectionItem
                // not the collectionitem.id the "id" aka name of the collection
                "collectionId": "emergency"
            ]
        )
    }
    
    // TODO: mixin, aka copy observer setup for emergency container view

}
