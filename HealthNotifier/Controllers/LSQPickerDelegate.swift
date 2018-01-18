//
//  LSQPickerDelegate.swift
//
//  Created by Charles Mastin on 12/8/16.
//

import Foundation
import UIKit

class LSQPickerDelegate : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let picker: UIImagePickerController = UIImagePickerController()
    var presenter: UIViewController? = nil // this is a hack
    
    var mode: String = "photo" // or "library"
    var selfie: Bool = false // if true, we will initially present the front camera if it exists
    var allowEditing: Bool = false
    
    func showPicker(_ presentingViewController: UIViewController){
        self.picker.delegate = self
        self.picker.allowsEditing = self.allowEditing
        
        if self.mode == "photo" {
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.picker.cameraCaptureMode = .photo
            
            if self.selfie {
                if UIImagePickerController.availableCaptureModes(for: .front) != nil {
                    self.picker.cameraDevice = UIImagePickerControllerCameraDevice.front
                } else {
                    // for some reason we don't have a front cam?
                    if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                        self.picker.cameraDevice = UIImagePickerControllerCameraDevice.rear
                    }
                }
            } else {
                if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                    self.picker.cameraDevice = UIImagePickerControllerCameraDevice.rear
                }
            }
            // camera picker is ALWAYS FULLSCREEN SON
            self.picker.modalPresentationStyle = .fullScreen
            self.present(self.picker, animated: true, completion: nil)
        }
        
        if self.mode == "library" {
            self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                self.picker.modalPresentationStyle = .fullScreen
                self.present(self.picker, animated: true, completion: nil)
            } else {
                // must be an ipad son, or it could be a car play bro :)
                // TODO: sort this later
                
                // current it is wrecked, and won't blend the view properly and if the users clicks off but doesn't cancel, the view is stuck
                
                
                //self.picker.modalPresentationStyle = .Popover
                //self.picker.popoverPresentationController?.sourceView = presentingViewController.view
       
                
                //self.view.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)
                //self.view.opaque = false
                
                //self.picker.popoverPresentationController?.barButtonItem =
                self.present(self.picker, animated: true, completion: nil)
            }
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NotificationCenter.default.post(
            name: LSQ.notification.hacks.imageCaptured,
            object: self,
            userInfo: [
                "image": (info[UIImagePickerControllerOriginalImage] as? UIImage)!
            ]
        )
        self.close()
        //self.dismissViewControllerAnimated(false, completion: nil)
        //self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal func close(){
        // meh meh
        self.dismiss(animated: true, completion: {
            self.presenter?.dismiss(animated: true, completion: nil)
        })
        // self.presentedViewController?.dismissViewControllerAnimated(true, completion: {})
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.close()
    }
}
