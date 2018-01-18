//
//  LSQRoutesForms.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit
import AVFoundation
import SwiftyJSON

class LSQRoutesForms : LSQRouter {
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.collectionItemForm,
                object: nil,
                queue: OperationQueue.main,
                using: self.showCollectionItemFormScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.formSelect,
                object: nil,
                queue: OperationQueue.main,
                using: self.showFormSelectScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.formDatePicker,
                object: nil,
                queue: OperationQueue.main,
                using: self.showFormDatePickerScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.formHeightPicker,
                object: nil,
                queue: OperationQueue.main,
                using: self.showFormHeightPickerScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.formAutocomplete,
                object: nil,
                queue: OperationQueue.main,
                using: self.showFormAutocompleteScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.chooseCaptureMethod,
                object: nil,
                queue: OperationQueue.main,
                using: self.chooseCaptureMethod
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.captureImage,
                object: nil,
                queue: OperationQueue.main,
                using: self.captureImage
            )
        )
    }
    
    func showCollectionItemFormScreen(notification: Notification) {
        print("whatt?")
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQEditCollectionItemViewController = sb.instantiateViewController(withIdentifier: "EditCollectionItemViewController") as! LSQEditCollectionItemViewController
        let pvc: UIViewController = notification.object as! UIViewController
        vc.patientUuid = LSQPatientManager.sharedInstance.uuid!
        vc.collectionId = (notification.userInfo!["collectionId"] as? String)!
        if notification.userInfo!["collectionItem"] != nil {
            let json = JSON(notification.userInfo!["collectionItem"]!)
            vc.collectionItem = json
        } else {
            vc.modeCreate = true
        }
        vc.doubleSecretInit()
        
        // so we have edit and add mode yo
        // this is based on presence of the "object" in the userInfo that we be a passing son
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        
        if pvc.isEmbeded {
            pvc.navigationController?.pushViewController(vc, animated: true) {
                // vc.title = (notification.userInfo!["collectionId"] as? String)!
            }
        } else {
            let navigationController = UINavigationController(rootViewController: vc)
            pvc.present(navigationController, animated: true, completion: {
                //
            })
        }
        
    }
    
    func showFormSelectScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQFormSelectViewController = sb.instantiateViewController(withIdentifier: "FormSelectViewController") as! LSQFormSelectViewController
        let pvc: UIViewController = notification.object as! UIViewController
        
        vc.title = (notification.userInfo!["title"] as? String)!
        vc.id = (notification.userInfo!["id"] as? String)!
        vc.value = (notification.userInfo!["value"] as? String)!
        
        if pvc.isEmbeded {
            pvc.navigationController?.pushViewController(vc, animated: true) {
                vc.pumpWeasel((notification.userInfo!["values"] as? [[String: AnyObject]])!)
            }
        } else {
            let navigationController = UINavigationController(rootViewController: vc)
            pvc.present(navigationController, animated: true, completion: {
                vc.pumpWeasel((notification.userInfo!["values"] as? [[String: AnyObject]])!)
            })
        }
    }
    
    func showFormDatePickerScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQFormDatePickerViewController = sb.instantiateViewController(withIdentifier: "FormDatePickerViewController") as! LSQFormDatePickerViewController
        let pvc: UIViewController = notification.object as! UIViewController
        
        vc.title = (notification.userInfo!["title"] as? String)!
        vc.id = (notification.userInfo!["id"] as? String)!
        if let d: Date = notification.userInfo!["value"] as? Date {
            vc.value = d
        }
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        
        if pvc.isEmbeded {
            pvc.navigationController?.pushViewController(vc, animated: true) {
                
            }
        } else {
            let navigationController = UINavigationController(rootViewController: vc)
            pvc.present(navigationController, animated: true, completion: {
                //
            })
        }
    }
    
    func showFormHeightPickerScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQFormHeightPickerViewController = sb.instantiateViewController(withIdentifier: "FormHeightPickerViewController") as! LSQFormHeightPickerViewController
        let pvc: UIViewController = notification.object as! UIViewController
        
        vc.title = (notification.userInfo!["title"] as? String)!
        vc.id = (notification.userInfo!["id"] as? String)!
        
        if let d: Int = notification.userInfo!["value"] as? Int {
            vc.value = d // in centimeters son
        }
        
        if pvc.isEmbeded {
            pvc.navigationController?.pushViewController(vc, animated: true) {
                
            }
        } else {
            let navigationController = UINavigationController(rootViewController: vc)
            pvc.present(navigationController, animated: true, completion: {
                //
            })
        }
        
    }
    
    func showFormAutocompleteScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQFormAutocompleteViewController = sb.instantiateViewController(withIdentifier: "FormAutocompleteViewController") as! LSQFormAutocompleteViewController
        let pvc: UIViewController = notification.object as! UIViewController
        
        vc.id = (notification.userInfo!["id"] as? String)!
        vc.title = (notification.userInfo!["title"] as? String)!
        vc.value = (notification.userInfo!["value"] as? String)!
        vc.autocompleteId = (notification.userInfo!["autocompleteId"] as? String)!
        
        if pvc.isEmbeded {
            pvc.navigationController?.pushViewController(vc, animated: true) {
                
            }
        } else {
            let navigationController = UINavigationController(rootViewController: vc)
            pvc.present(navigationController, animated: true, completion: {
                //
            })
        }
    }
    
    //
    func chooseCaptureMethod(notification: Notification) {
        let vc: UIViewController = notification.object as! UIViewController
        var userInfo: [String:AnyObject] = [:]
        var title: String = "Capture Image"
        var message: String? = nil
        // TODO: write more defensively
        if let t: String = notification.userInfo!["title"] as? String {
            title = t
        }
        if let t: String = notification.userInfo!["message"] as? String {
            message = t
        }
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        let alert: UIAlertController = UIAlertController(
            title: title, // TODO: configurable
            message: message, // TODO: configurable
            preferredStyle: preferredStyle)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let cameraAction: UIAlertAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default, handler: { action in
                userInfo["mode"] = "photo" as AnyObject?
                // generate the selfie bit son
                if let selfie: Bool = notification.userInfo!["selfie"] as? Bool {
                    if selfie {
                        userInfo["selfie"] = true as AnyObject?
                    }
                }
                NotificationCenter.default.post(
                    name: LSQ.notification.action.captureImage,
                    object: vc,
                    userInfo: userInfo
                )
            })
            alert.addAction(cameraAction)
        } else {
            // it's really no bueno at this point though, don't make a big deal, but also maybe we show this
            let noCameraAction: UIAlertAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default, handler: { action in
                
            })
            noCameraAction.isEnabled = false
            alert.addAction(noCameraAction)
        }
        
        
        let galleryAction: UIAlertAction = UIAlertAction(title: "Choose From Library", style: UIAlertActionStyle.default, handler: { action in
            // check if blbalbal
            userInfo["mode"] = "library" as AnyObject?
            NotificationCenter.default.post(
                name: LSQ.notification.action.captureImage,
                object: vc,
                userInfo: userInfo
            )
        })
        alert.addAction(galleryAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
        })
        alert.addAction(cancelAction)
        
        /*
         if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
         self.popOver = UIPopoverController(contentViewController: imagePickerController)
         self.popOver?.presentPopoverFromRect(self.productImage.bounds, inView: self.productImage, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
         }
         */
        
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    func captureImage(notification: Notification) {
        let pvc: UIViewController = notification.object as! UIViewController
        let pd: LSQPickerDelegate = LSQPickerDelegate()
        pd.presenter = pvc
        
        // selfie
        if let selfie: Bool = notification.userInfo!["selfie"] as? Bool {
            if selfie {
                pd.selfie = true
            }
        }
        
        if let mode:String =  notification.userInfo!["mode"] as? String {
            pd.mode = mode
        }
        
        // allowEditing
        pvc.present(pd, animated: true, completion: {
            pd.showPicker(pvc)
        })
        
        // TODO: listen for the no device found or whatnot message, and toss back to the caller
        
    }
}
