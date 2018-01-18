//
//  LSQCodeEntryViewController2.swift
//
//  Created by Charles Mastin on 12/1/16.
//

import Foundation
import UIKit
import SwiftyJSON
import CoreLocation

class LSQCodeEntryViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var codeView: LSQCodeEntryView!
    
    // FML
    var hackPresentingViewController: UIViewController? = nil
    //
    
    var captureMode: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.codeView?.codeField.delegate = self
        self.codeView?.codeField.addTarget(self, action: #selector(self.didChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.codeView?.codeField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LSQUser.currentUser.provider {
            LSQLocationManager.sharedInstance.start()
        }
        self.view.backgroundColor = LSQ.appearance.color.newBlue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if LSQUser.currentUser.provider {
            LSQLocationManager.sharedInstance.stop()
        }
    }

    
    @IBAction func actionSubmit() -> Void {
        self.submit()
    }
    
    // listen to the change
    func didChange(_ textField: UITextField) {
        if LSQ.validator.lifesquareCode(textField.text!) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // if we're a valid code
        if LSQ.validator.lifesquareCode(textField.text!) {
            self.submit()
        } else {
            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                preferredStyle = UIAlertControllerStyle.actionSheet
            }
            let alert: UIAlertController = UIAlertController(
                title: "\(textField.text!) is not a valid LifeSticker",
                message: "",
                preferredStyle: preferredStyle)
            
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                // nothing here
                // focus the text again??
            })
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 9
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    // CODE TO create optical space of groups of 3 :) Thank You Adam
    
    /*
     static CGFloat GROUP_KERN_AMOUNT = 10.;
 #pragma mark - UITextFieldDelegate methods
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 {
 if ([self isReturnCode:string])
 {
 [self submit];
 return NO;
 }
 
 if (string.length && ![LSQLifesquare isValidCodeCharacter:string]) return NO;
 
 NSMutableAttributedString *currentCode = [NSMutableAttributedString.alloc initWithString:textField.text];
 NSUInteger length = currentCode.string.length;
 NSUInteger splitPoint = 3;
 
 if (length >= 9 && string.length) return NO;
 
 for(NSUInteger i=splitPoint-1; i<length; i += splitPoint)
 {
 NSRange replaceRange = NSMakeRange(i, 1);
 NSMutableAttributedString *character = [currentCode attributedSubstringFromRange:replaceRange].mutableCopy;
 [character addAttribute:NSKernAttributeName value:@(GROUP_KERN_AMOUNT) range:NSMakeRange(0, 1)];
 [currentCode replaceCharactersInRange:replaceRange withAttributedString:character];
 }
 
 textField.attributedText = currentCode.copy;
 
 return YES;
 }
 */
 
    func submit() -> Void {
        // if code is valid
        // load it up
        let code: String = self.codeView.codeField.text!
        
        // this case seems unlikely
        if !LSQ.validator.lifesquareCode(code) {
            // do nothing on invalid codes,
            // blablabl
            var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                preferredStyle = UIAlertControllerStyle.actionSheet
            }
            let alert: UIAlertController = UIAlertController(
                title: "\(code) is not a valid LifeSticker",
                message: "",
                preferredStyle: preferredStyle)
            
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                // nothing here
                // focus the text again??
            })
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        if self.captureMode {
            NotificationCenter.default.post(
                name: LSQ.notification.hacks.lifesquareCodeCaptured,
                object: self,
                userInfo: [
                    "code": code,
                    "mode": "entry"
                ]
            )
            NotificationCenter.default.post(
                name: LSQ.notification.dismiss.captureLifesquareCode,
                object: self.hackPresentingViewController! // this is mad sketchy
            )
            return
        }
        
        var latitude: Double? = nil
        var longitude: Double? = nil
        if let location: CLLocation = LSQLocationManager.sharedInstance.lastLocation {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
        
        LSQAPI.sharedInstance.patientFromLifesquare(
            code,
            latitude: latitude,
            longitude: longitude,
            success: { response in
                let patient: JSON = JSON(response)
                let user: LSQUser = LSQUser.currentUser
                NotificationCenter.default.post(
                    name: LSQ.notification.analytics.event,
                    object: nil,
                    userInfo: [
                        "event": "Scan",
                        "attributes": [
                            "AccountId": user.uuid!,
                            "Provider": user.provider,
                            "PatientId": patient["PatientId"].string!
                        ]
                    ]
                )
                
                // ADD TO SCAN HISTORY SON
                LSQScanHistory.sharedInstance.addPatient([
                    "PatientId": patient["PatientId"].string! as AnyObject,
                    "Name": "\(patient["FirstName"].string!) \(patient["LastName"].string!)" as AnyObject,
                    "Address": patient["Residence"]["Address1"].string! as AnyObject,
                    "LifesquareLocation": patient["Residence"]["LifesquareLocation"].string! as AnyObject,
                    "ScanTime": NSDate.init()
                    ])
                
                // KICK DAT NOTIFICATION SON
                NotificationCenter.default.post(
                    name: LSQ.notification.show.lifesquare, // what about dis name fool
                    object: self,
                    userInfo: [
                        "patientId": patient["PatientId"].string!
                    ]
                )
                
            },
            failure: { response in
                var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                    preferredStyle = UIAlertControllerStyle.actionSheet
                }
                let alert: UIAlertController = UIAlertController(
                    title: "\(code) is not an active LifeSticker",
                    message: "",
                    preferredStyle: preferredStyle)
                
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    // nothing here
                })
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
                
            }
        )
    }
}
