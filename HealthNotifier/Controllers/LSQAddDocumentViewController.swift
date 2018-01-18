//
//  LSQAddDocument2ViewController.swift
//
//  Created by Charles Mastin on 3/14/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

// do I need to import this, I guess not, but why not

class LSQAddDocumentViewController : UITableViewController, UINavigationControllerDelegate {
    var mode: String? = nil
    var patientId: String? = nil
    var docFiles: [AnyObject] = []
    let picker = UIImagePickerController()
    
    var privacy: String = "provider"
    var privacyOptions: [AnyObject] = []
    var documentType: String? = nil
    var documentTypes: [AnyObject] = []
    
    var data: JSON = JSON.null // because why not
    var editMode: Bool = false
    var imageSize: Float = 88.0
    
    var tableConfig: [[String: AnyObject]] = []
    var nameField: LSQModelFieldC? = nil
    var valName: String = ""
    
    // don't go gangbusters on stopping it because the init of it blocks the interaction layer
    var durationTimer: LSQDurationTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove da button in the context doh
        // this really is WRONG, and needs to be an introspection on the windowing context of this viewcontroller
        if LSQOnboardingManager.sharedInstance.active {
            // this is kinda risky
        } else {
            self.navigationItem.leftBarButtonItems = nil
        }
        
        //self.picker.delegate = self
        // override dat stuffs
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        
        self.tableView.register(LSQCellAddCollectionItem.self, forCellReuseIdentifier: "CellAddCollectionItem")
        self.tableView.register(UINib(nibName: "CellFormCheckbox", bundle: nil), forCellReuseIdentifier: "CellFormCheckbox")
        self.tableView.register(UINib(nibName: "CellFormInput", bundle: nil), forCellReuseIdentifier: "CellFormInput")
        
        self.privacyOptions = LSQAPI.sharedInstance.getValues("privacy") as [AnyObject]
        
        // bla
        if self.mode == "document" {
            self.navigationItem.title = "Add Document"
            self.documentTypes = LSQAPI.sharedInstance.getValues("document") as [AnyObject]
            self.nameField = LSQModelFieldC()
            self.nameField?.label = "Name"
            self.nameField?.property = "title"
            self.nameField?.required = false
            
        } else {
            self.navigationItem.title = "Add Directive"
            self.documentTypes = LSQAPI.sharedInstance.getValues("directive") as [AnyObject]
        }
        self.addObservers()
        
        if self.data != JSON.null {
            self.editMode = true
            self.privacy = self.data["privacy"].string!
            self.documentType = self.data["category"].string!
            if let title = self.data["title"].string {
                // just in case son
                self.valName = title
            }
            if self.mode == "document" {
                self.navigationItem.title = "Edit Document"
            } else {
                self.navigationItem.title = "Edit Directive"
            }
            // don't bother with the files, because we will access a different view chunk in the renderer
            
            // set title, kinda hard when we have multiple
        }
        
        self.doubleSecretInit()
        
    }
    
    internal func doubleSecretInit() {
        self.tableConfig = []
        if self.mode == "document" {
            self.tableConfig.append(
                [
                    "id": "name" as AnyObject,
                    "header": "" as AnyObject
                ]
            )
        }
        if !self.editMode {
            self.tableConfig.append(
                [
                    "id": "files" as AnyObject,
                    "header": "Pages" as AnyObject
                ]
            )
        }
        
        if self.editMode {
            
            self.tableConfig.append(
                [
                    "id": "files-readonly" as AnyObject,
                    "header": "Preview" as AnyObject
                ]
            )
            
        }
        
        self.tableConfig.append(
            [
                "id": "type" as AnyObject,
                "header": "Category" as AnyObject
            ]
        )
        self.tableConfig.append(
            [
                "id": "privacy" as AnyObject,
                "header": "Privacy" as AnyObject
            ]
        )
        if self.editMode {
            self.tableConfig.append(
                [
                    "id": "delete" as AnyObject,
                    "header": "" as AnyObject
                ]
            )
        }
        self.tableView.reloadData()
    }
    
    // mapped so we can remove this at buildtime if running in normal navigation controller push view context
    // the alternative was to construct it all programmatically for the modal condition, meh
    @IBOutlet var cancelButton: UIBarButtonItem?
    // this is just for the non navigation push context, so we can close
    // aka modal launching son!
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    // meh not sure why this exists anymore?
    @IBAction func cancel(_ sender: AnyObject?) {
        self.close()
    }
    
    @IBAction func done(_ sender: AnyObject?) {
        if !self.editMode {
            let isValid:Bool = self.validateForm()
            if isValid {
                self.submitForm()
            }
        } else {
            // there is no way to make the form invalid son
            self.submitForm()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableConfig.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableConfig[section]["header"]! as? String
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var config: [String: AnyObject] = self.tableConfig[section]
        if config["id"]! as? String == "files" {
            return "Please take a photo of each page of your document and upload here."
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var config: [String: AnyObject] = self.tableConfig[section]
        if config["id"]! as? String == "name" {
            return 1
        }
        if config["id"]! as? String == "files" {
            return self.docFiles.count + 1
        }
        if config["id"]! as? String == "files-readonly" {
            return 1 // TODO: hook the actual rows based on an additional load from the server
        }
        if config["id"]! as? String == "type" {
            return self.documentTypes.count
        }
        if config["id"]! as? String == "privacy" {
            return self.privacyOptions.count
        }
        if config["id"]! as? String == "delete" {
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var config: [String: AnyObject] = self.tableConfig[indexPath.section]
        if let cid: String = config["id"]! as? String {
            if cid == "delete" {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell_default")
                cell.detailTextLabel?.text = "Delete"
                cell.detailTextLabel?.textColor = UIColor.red
            } else if cid == "name" {
                let field = self.nameField
                let cell = Forms.generateDefaultInputCell(tableView, indexPath: indexPath, id: field!.property, label: field!.label, initialValue: self.valName, required: field!.required)
                (cell as! LSQCellFormInput).input?.autocapitalizationType = .words
                return cell
            } else if cid == "files" {
                // file
                if indexPath.row == self.docFiles.count {
                    let cell = Forms.generateAddCollectionItemCell(self.tableView, indexPath: indexPath, collectionId: "addfile")
                    if self.docFiles.count == 0 {
                        (cell as? LSQCellAddCollectionItem)?.labelText = "+ Add First Page"
                    } else {
                        (cell as? LSQCellAddCollectionItem)?.labelText = "+ Add Additional Page"
                    }
                    return cell
                } else {
                    let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "image")
                    cell.imageView?.image = self.docFiles[indexPath.row] as? UIImage
                    cell.textLabel?.text = "Page \(indexPath.row + 1) of \(self.docFiles.count)"
                    cell.textLabel?.textColor = UIColor.gray
                    return cell
                }
            } else if cid == "files-readonly" {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell_default")
                let placeholder = UIImage(named: "selfie_image")
                cell.imageView!.contentMode = UIViewContentMode.scaleAspectFill
                cell.imageView!.kf.setImage(
                    with: URL(string: "\(self.data["thumbnail_url"].string!)?width=\(Int(self.imageSize * 2))&height=\(Int(self.imageSize * 2))"),
                    placeholder: placeholder,
                    options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)]
                )
                return cell
            } else if cid == "type" {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "bla")
                cell.textLabel?.text = self.documentTypes[indexPath.row]["name"] as? String
                if self.documentTypes[indexPath.row]["value"] as? String == self.documentType {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
                return cell
            } else if cid == "privacy" {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "bla")
                cell.textLabel?.text = self.privacyOptions[indexPath.row]["name"] as? String
                cell.detailTextLabel?.text = self.privacyOptions[indexPath.row]["short_description"] as? String
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                if self.privacyOptions[indexPath.row]["value"] as? String == self.privacy {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var config: [String: AnyObject] = self.tableConfig[indexPath.section]
        let cell = self.tableView.cellForRow(at: indexPath)
        if cell is LSQCellAddCollectionItem {
            if (cell as? LSQCellAddCollectionItem)?.collectionId == "addfile" {
                NotificationCenter.default.post(
                    name: LSQ.notification.action.chooseCaptureMethod,
                    object: self,
                    userInfo: [
                        : // pass along selfie if we want to make that available, otherwise, it is what it is
                        // potentially pass along some id or something, for this request, but come on, it's not like
                        // we will have multiple active listeners - famous last works
                    ]
                )
            }
            return
        }
        /*
        if config["id"]! as? String == "files" {
            if self.docFiles.count == 0 || (self.docFiles.count > 0 && indexPath.row == self.docFiles.count) {
                //self.chooseDefaultPicker()
            } else {
                // offer something up like full view on document?
            }
        }
        */
        if config["id"]! as? String == "files-readonly" {
            NotificationCenter.default.post(
                name: LSQ.notification.show.document,
                object: self,
                userInfo: [
                    "URL": "\(LSQAPI.sharedInstance.api_root)documents/\((self.data["uuid"].string)!)/#file-0" // TODO: complete mega super hack here
                ]
            )
        }
        if config["id"]! as? String == "type" {
            self.documentType = self.documentTypes[indexPath.row]["value"] as? String
            // update dat table rendering son
            self.tableView.reloadData()
        }
        if config["id"]! as? String == "privacy" {
            self.privacy = self.privacyOptions[indexPath.row]["value"] as! String
            // update dat table son
            self.tableView.reloadData()
        }
        if config["id"]! as? String == "delete" {
            self.confirmDelete()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var config: [String: AnyObject] = self.tableConfig[indexPath.section]
        if config["id"]! as? String == "files" && self.docFiles.count > 0 && indexPath.row < self.docFiles.count {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var config: [String: AnyObject] = self.tableConfig[indexPath.section]
        if config["id"]! as? String == "name" {
            return 56.0
        }
        if config["id"]! as? String == "privacy" {
            return 66.0
        }
        if config["id"]! as? String == "files-readonly" {
            return CGFloat(self.imageSize)
        }
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // we can restore the fancy deleting when we sort out the event flow at another point in time
            self.docFiles.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            Timer.scheduledTimer(timeInterval: TimeInterval(0.3), target: self, selector: #selector(LSQAddDocumentViewController.rerenderFileCells), userInfo: nil, repeats: false)
            // we have to update the other rows after this is complete
        }
    }
    
    func rerenderFileCells() {
        var section:Int = 0
        if self.mode == "document" {
            section = 1
        }
        var indexPaths: [IndexPath] = []
        for i in 0...self.docFiles.count {
            indexPaths.append(IndexPath(row: i, section: section))
        }
        self.tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
    }
    
    func validateForm() -> Bool {
        // does not conform to other validateForm specs, but it works
        if self.documentType == nil {
            let alert: UIAlertController = UIAlertController(
                title: "Oops",
                message: "Please select a Document Type",
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                // nothing here
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if self.docFiles.count == 0 {
            let alert: UIAlertController = UIAlertController(
                title: "Oops",
                message: "You need at least 1 file to proceed",
                preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                //self.chooseDefaultPicker()
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func submitForm() {
        
        if !self.editMode {
            self.durationTimer = LSQDurationTimer()
            
            var files: [[String: AnyObject]] = []
            let transferSize: Int = 0
            
            for f in self.docFiles {
                // transferSize += f.bytes
                let fileContents: String = LSQ.formatter.imageToBase64(f as! UIImage, mode: "jpeg", compression: 0.7)
                files.append([
                    "Name": "ios-app-upload-image.jpg" as AnyObject,
                    "File": fileContents as AnyObject,
                    "Mimetype": "image/jpeg" as AnyObject
                    ])
            }
            
            var data: [String: AnyObject] = [
                "PatientId": self.patientId! as AnyObject,
                "Files": files as AnyObject,
                "DirectiveType": self.documentType! as AnyObject, // LOL on that name/attribute mismatch
                "Privacy": self.privacy as AnyObject
            ]
            
            if self.mode == "document" {
                data["Title"] = self.valName as AnyObject?
            }
            
            LSQAPI.sharedInstance.addDocument(
                data as AnyObject,
                success: { response in
                    EZLoadingActivity.hide(true, animated: true)
                    
                    let user: LSQUser = LSQUser.currentUser
                    
                    LSQPatientManager.sharedInstance.fetch()
                    
                    NotificationCenter.default.post(
                        name: LSQ.notification.analytics.event,
                        object:nil,
                        userInfo:
                        [
                            "event": "Document Add",
                            "attributes": [
                                "AccountId": user.uuid!,
                                "Provider": user.provider,
                                "PatientId": self.patientId!,
                                "Type": self.documentType!,
                                "Privacy": self.privacy,
                                "Source": self.mode!,
                                "Files": self.docFiles.count,
                                "Size": transferSize,
                                "TransferDuration": (self.durationTimer?.stop())!
                            ]
                        ]
                    )
                    
                    self.close()
                    
                }, failure: { response in
                    let _ = self.durationTimer?.stop()
                    EZLoadingActivity.hide(false, animated: true)
                    
                    // FIXME: untested code here, looks good though
                    var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                        preferredStyle = UIAlertControllerStyle.actionSheet
                    }
                    // alert here
                    let alert: UIAlertController = UIAlertController(
                        title: "Server Error",
                        message: "There was a problem saving your document and our staff has been notified",
                        preferredStyle: preferredStyle)
                    
                    // wootsy colins
                    alert.addAction(LSQ.action.support)
                    
                    let cancelAction: UIAlertAction = UIAlertAction(title:"Try Again", style: UIAlertActionStyle.cancel, handler: { action in
                        
                    })
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    
                }
            )
            EZLoadingActivity.show("", disableUI: true)
            
        } else {
            
            
            // not supported to adjust individual assets at this point, just because complexity all over the place
            // the people may ask for it, and if they do, then bla
            var data: [String: AnyObject] = [
                "Category": self.documentType! as AnyObject, // LOL on that name/attribute mismatch
                "Privacy": self.privacy as AnyObject
            ]
            if self.mode == "document" {
                data["Title"] = self.valName as AnyObject?
            }
            EZLoadingActivity.show("", disableUI: true)
            LSQAPI.sharedInstance.updateDocument(
                self.data["uuid"].string!,
                data: data as AnyObject,
                success: { response in
                    EZLoadingActivity.hide(true, animated: true)
                    LSQPatientManager.sharedInstance.fetch()
                    self.close()
                },
                failure: { response in
                    EZLoadingActivity.hide(false, animated: true)
                    // show error???
                    let alert: UIAlertController = UIAlertController(
                        title: "Server Error",
                        message: "Unable to update document",
                        preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                        // TODO: focus first problem child?
                    })
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            )
            
            // delete is a separate mode
            
        }
    }
    
    var observationQueue: [AnyObject] = []
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.imageCaptured,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.docFiles.append((notification.userInfo!["image"] as? UIImage)!)
                var index: Int = 0
                if self.mode == "document" {
                    index = 1
                }
                self.tableView.reloadSections(IndexSet(integer: index), with: UITableViewRowAnimation.automatic)
            }
        )
        
        NotificationCenter.default.addObserver(
            forName: LSQ.notification.form.field.change,
            object: nil,
            queue: OperationQueue.main
        ) { notification in
            let attribute = (notification.userInfo!["id"] as? String)
            if attribute == "title" {
                self.valName = (notification.userInfo!["value"] as? String)!
            }
        }
    }
    
    func removeObservers() {
        for observed in self.observationQueue {
            NotificationCenter.default.removeObserver(observed)
        }
        self.observationQueue = []
    }
    
    deinit {
        let _ = self.durationTimer?.stop()
        self.removeObservers()
    }
    
    func confirmDelete(){
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        let alert: UIAlertController = UIAlertController(
            title: "Delete Document",
            message: "",
            preferredStyle: preferredStyle)
        
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            
            let user: LSQUser = LSQUser.currentUser
            
            LSQAPI.sharedInstance.deleteDocument(
                self.data["uuid"].string!,
                success: { response in
                    NotificationCenter.default.post(
                        name: LSQ.notification.analytics.event,
                        object: nil,
                        userInfo:[
                        "event": "Document Delete",
                        "attributes": [
                            "AccountId": user.uuid!,// huh wut?
                            "Provider": user.provider, // huh wut?
                            "PatientId": self.patientId!,
                            "DocumentId": self.data["uuid"].string!
                        ]
                    ])
                    LSQPatientManager.sharedInstance.fetch()
                    self.close()
                },
                failure: { response in
                    let alert: UIAlertController = UIAlertController(
                        title: "Error",
                        message: "Document delete failed",
                        preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                        
                    })
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            )
            
            
        })
        alert.addAction(deleteAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            // nothing here
        })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
