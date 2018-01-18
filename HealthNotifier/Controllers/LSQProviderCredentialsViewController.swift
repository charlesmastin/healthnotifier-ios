//
//  LSQProviderCredentialsViewController.swift
//
//  Created by Charles Mastin on 2/24/16.
//

import Foundation
import UIKit
import EZLoadingActivity

// UITextFieldDelegate

class LSQProviderCredentialsViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var formTable: UITableView?
    
    // TODO: ! vs ? on your conditional times
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var boardField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var expirationField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var extensionField: UITextField!
    
    @IBOutlet weak var licensePhotoField1: UITextField?
    @IBOutlet weak var licensePhotoField2: UITextField?
    @IBOutlet weak var licensePhotoCell1: UITableViewCell?
    @IBOutlet weak var licensePhotoCell2: UITableViewCell?
    @IBOutlet weak var selectedImageView1: UIImageView!
    @IBOutlet weak var selectedImageView2: UIImageView!
    var imageIndex: Int? = nil
    var image1: UIImage?
    var image2: UIImage?
    
    var date: String? = nil
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.form.field.change,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if (notification.userInfo!["id"] as? String) == "expiration" {
                    self.date = notification.userInfo!["value"]! as? String
                    self.expirationField?.text = notification.userInfo!["value"]! as? String
                }
                if (notification.userInfo!["id"] as? String) == "state" {
                    self.stateField?.text = notification.userInfo!["value"]! as? String
                }
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.imageCaptured,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if self.imageIndex == 1 {
                    self.image1 = (notification.userInfo!["image"] as? UIImage)!
                    self.selectedImageView1.contentMode = .scaleAspectFit
                    self.selectedImageView1.image = self.image1
                    self.licensePhotoField1?.isHidden = true
                }
                if self.imageIndex == 2 {
                    self.image2 = (notification.userInfo!["image"] as? UIImage)!
                    self.selectedImageView2.contentMode = .scaleAspectFit
                    self.selectedImageView2.image = self.image2
                    self.licensePhotoField2?.isHidden = true
                }
            }
        )
    }
    
    func removeObservers() {
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        

        // picker.delegate = self
    }
    
    deinit {
        self.removeObservers()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            // pass in existing value if available son, lolzors
            self.boardField.resignFirstResponder()
            
            NotificationCenter.default.post(
                name: LSQ.notification.show.formSelect,
                object: self,
                userInfo: [
                    "id": "state",
                    "title": "Licensing State",
                    "value": (self.stateField?.text)!,
                    "values": LSQAPI.sharedInstance.getValues("state")
                ]
            )
        }
        if indexPath.section == 0 && indexPath.row == 3 {
            var userInfo: [String: AnyObject] = [
                "id": "expiration" as AnyObject,
                "title": "License Expiration" as AnyObject
            ]
            if self.date != nil {
                // YES THIS IS A LITTLE SILLY
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                userInfo["value"] = dateFormatter.date(from: self.date!) as AnyObject?
            }
            NotificationCenter.default.post(
                name: LSQ.notification.show.formDatePicker,
                object: self,
                userInfo: userInfo
            )
        }
        if indexPath.section == 0 && indexPath.row == 4 {
            self.imageIndex = 1
            NotificationCenter.default.post(
                name: LSQ.notification.action.chooseCaptureMethod,
                object: self,
                userInfo: [
                    : // naa son
                ]
            )
        }
        if indexPath.section == 0 && indexPath.row == 5 {
            self.imageIndex = 2
            NotificationCenter.default.post(
                name: LSQ.notification.action.chooseCaptureMethod,
                object: self,
                userInfo: [
                    : // naa son
                ]
            )
        }
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIButton){
        self.close()
    }
    
    @IBAction func submitAction(_ sender: UIButton){
        //NotificationCenter.default.post(name: LSQ.notification.show.providerRegistrationSuccess, object: self)
        self.submit()
    }
    
    func submit(){
        // why not
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
        let validationResults: [String: AnyObject] = self.validateForm()
        
        if validationResults["valid"] as! Bool == false {
            var messages: [String] = []
            for (_, value) in (validationResults["errors"]! as? [[String: AnyObject]])!.enumerated() {
                messages.append(value["message"] as! String)
            }
            // build up an alert, ideally, listing specific issues
            // put in the actual alert SON
            let alert: UIAlertController = UIAlertController(
                title: "Validation Errors",
                message: messages.joined(separator: "\n"),
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                // TODO: focus the first field in the response
                // let's iterate and stop at the first UITextField we find
                // THIS WILL CRASH if we have any non UITextFields in our error array
                guard let field:UITextField = (validationResults["errors"] as! [[String: AnyObject]])[0]["object"] as? UITextField else {
                    // do nothing, this is a hack to avoid crashing
                    return
                }
                field.becomeFirstResponder()
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let d = dateFormatter.date(from: self.date!)
        let outputFormat = DateFormatter()
        outputFormat.dateFormat = "MM/dd/yyyy"
        
        // wow, that's some OTT syntax ehh, we heard you like optionals so we put some optionals on your optionals
        var data: [String : AnyObject] =
        [
            // TODO: better design the API to not need this attribute or at least bake it in the URL or something? perhaps
            "LicenseNumber": self.numberField!.text! as AnyObject,
            "LicenseBoard": self.boardField!.text! as AnyObject,
            "State": self.stateField!.text! as AnyObject,
            "Expiration": outputFormat.string(from: d!) as AnyObject,
            "SupervisorName": self.nameField!.text! as AnyObject,
            "SupervisorEmail": self.emailField!.text! as AnyObject,
            "SupervisorPhone": self.phoneField!.text! as AnyObject,
            "SupervisorExt": self.extensionField!.text! as AnyObject,
            // "CredentialFiles": []
        ]
        
        var files: [[String: AnyObject]] = []
        if self.image1 != nil {
            let fileContents: String = LSQ.formatter.imageToBase64(self.image1!, mode: "jpeg", compression: 0.7)
            files.append([
                "Name": "ios-app-upload-image.jpg" as AnyObject,
                "File": fileContents as AnyObject,
                "Mimetype": "image/jpeg" as AnyObject
            ])
        }
        if self.image2 != nil {
            let fileContents: String = LSQ.formatter.imageToBase64(self.image2!, mode: "jpeg", compression: 0.7)
            files.append([
                "Name": "ios-app-upload-image.jpg" as AnyObject,
                "File": fileContents as AnyObject,
                "Mimetype": "image/jpeg" as AnyObject
                ])
        }
        
        if files.count > 0 {
            data["CredentialFiles"] = files as AnyObject?
        }

        // TODO: type of function, hmm, not sure at all
        LSQAPI.sharedInstance.registerProvider(
            data as AnyObject,
            success: { response in
                EZLoadingActivity.hide(true, animated: true)
                
                LSQUser.currentUser.fetch()
                
                
                NotificationCenter.default.post(name: LSQ.notification.show.providerRegistrationSuccess, object: self)
                NotificationCenter.default.post(name: LSQ.notification.analytics.event, object: nil, userInfo:[
                    "event": "Register Provider",
                    "attributes": [
                        "AccountId": LSQUser.currentUser.uuid!,
                        "Provider": false,
                        
                        // TODO: later
                        // "Files": 0,
                        // "InputDuration": 0,
                        // "TransferDuration": 0
                    ]
                ])
                
                //self.close()
                
            }, failure: { response in
                EZLoadingActivity.hide(false, animated: true)
                
                let alert: UIAlertController = UIAlertController(
                    title: "Server Error",
                    message: "Our server had a problem saving your credentials. Please try again or contact us at support@domain.com.",
                    preferredStyle: .alert)
                // wootsy colins
                alert.addAction(LSQ.action.support)
                
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                    
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
        })
        EZLoadingActivity.show("", disableUI: true)

    }
    
    func validateForm() -> [String: AnyObject] {
        var errors: [[String: AnyObject]] = []
        
        if self.numberField.text == "" {
            errors.append([
                "object": self.numberField,
                "message": "License number is required" as AnyObject
            ])
        }
        
        if self.boardField.text == "" {
            errors.append([
                "object": self.boardField,
                "message": "Issuing board is required" as AnyObject
            ])
        }
        
        if self.stateField.text == "" {
            errors.append([
                "object": self.stateField,
                "message": "Issuing state is required" as AnyObject
            ])
        }
        
        if self.date == nil {
            errors.append([
                "object": self.expirationField,
                "message": "License expiration is required" as AnyObject
            ])
        }
        
        if self.nameField.text == "" {
            errors.append([
                "object": self.nameField,
                "message": "Supervisor name is required" as AnyObject
            ])
        }
        
        //
        if !LSQ.validator.email(self.emailField.text!) {
            // do the email validation as well tie into dat static LSQ
            errors.append([
                "object": self.emailField,
                "message": "Supervisor email is required" as AnyObject
            ])
        }
        
        if self.phoneField.text == "" {
            errors.append([
                "object": self.phoneField,
                "message": "Supervisor phone is required" as AnyObject
            ])
        } else if !(self.phoneField.text?.isPhoneNumber)! {
            errors.append([
                "object": self.phoneField,
                "message": "A valid supervisor phone is required" as AnyObject
            ])
        }
        
        // ext not required
        
        // files not required at this point
        
        
        
        return [
            "valid": errors.count == 0 ? true as AnyObject : false as AnyObject,
            "errors": errors as AnyObject
        ]
    }
    
    // Keyboard UX Stuffs
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // this is hilarious because we never change the return
        // because the form design doesn't end with a submittable field type, lul #fail
        let shouldReturn = true
        if textField == self.numberField {
            self.boardField.becomeFirstResponder()
        } else if textField == self.boardField {
            self.boardField.resignFirstResponder()
            let rowToSelect: IndexPath = IndexPath(row:2, section: 0)
            self.tableView.scrollToRow(at: rowToSelect, at: UITableViewScrollPosition.middle, animated: true)
            self.tableView(self.tableView, didSelectRowAt: rowToSelect)
        } else if textField == self.stateField {
            let rowToSelect: IndexPath = IndexPath(row:3, section: 0)
            self.tableView.scrollToRow(at: rowToSelect, at: UITableViewScrollPosition.middle, animated: true)
            self.tableView(self.tableView, didSelectRowAt: rowToSelect)
        } else if textField == self.nameField {
            self.emailField.becomeFirstResponder()
            let rowToSelect: IndexPath = IndexPath(row:3, section: 1)
            self.tableView.scrollToRow(at: rowToSelect, at: UITableViewScrollPosition.middle, animated: true)
        } else if textField == self.emailField {
            self.phoneField.becomeFirstResponder()
            let rowToSelect: IndexPath = IndexPath(row:3, section: 1)
            self.tableView.scrollToRow(at: rowToSelect, at: UITableViewScrollPosition.middle, animated: true)
        } else if textField == self.phoneField {
            // can't be focused because there is no next button on keypad, lul
            // need that Safari like Forms stepper control, bla bla
            self.extensionField.becomeFirstResponder()
        }
        return shouldReturn
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // change it up chimmy changas
        if textField == self.numberField {
            textField.returnKeyType = UIReturnKeyType.next
        }
        if textField == self.boardField {
            textField.returnKeyType = UIReturnKeyType.next
        }
        if textField == self.stateField {
            textField.returnKeyType = UIReturnKeyType.next
        }
        if textField == self.nameField {
            // do your scroll down maybe
            textField.returnKeyType = UIReturnKeyType.next
        }
        if textField == self.emailField {
            textField.returnKeyType = UIReturnKeyType.next
        }
        if textField == self.phoneField {
            textField.returnKeyType = UIReturnKeyType.next
        }
        if textField == self.extensionField {
            textField.returnKeyType = UIReturnKeyType.go
        }
        return true
    }
    
}
