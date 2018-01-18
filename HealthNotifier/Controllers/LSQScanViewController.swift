//
//  LSQScanViewController.swift
//
//  Created by Charles Mastin on 12/1/16.
//  foundation AV from https://gist.github.com/MihaelIsaev/273e4e8ddaaf062d2155


import Foundation
import AVFoundation
import UIKit
import SwiftyJSON
import CoreLocation
import EZLoadingActivity

class LSQScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var scanTargetImage: UIImageView!
    @IBOutlet weak var noScanLabel: UILabel!
    // this is a quick n dirty hack to avoid refactoring all the code to move consumption into the mediator or some other
    var captureMode: Bool = false
    
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var prevLayer: AVCaptureVideoPreviewLayer?
    
    @IBAction func cancelScanning() -> Void {
        NotificationCenter.default.post(
            name: LSQ.notification.dismiss.captureLifesquareCode,
            object: self,
            userInfo: [
                "origin": "user"// hack so we "KNOW" it's a user press vs just a rando call to "close" the window like Hide it
            ]
        )
        self.close()
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    @IBAction func actionEnterCode() -> Void {
        NotificationCenter.default.post(
            name: LSQ.notification.show.scanCodeEntry,
            object: self,
            userInfo: [
                "capture": self.captureMode
            ]
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startScanning()
        if LSQUser.currentUser.provider {
            LSQLocationManager.sharedInstance.start()
        }
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopScanning()
        if LSQUser.currentUser.provider {
            LSQLocationManager.sharedInstance.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noScanLabel?.alpha = 0.0
        //startScanning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prevLayer?.frame.size = myView.frame.size
    }
    
    func startScanning() {
        
        session = AVCaptureSession()
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            input = try AVCaptureDeviceInput(device: device)
            session?.addInput(input)
        } catch _ {
            //Error handling, if needed
            self.noScanLabel?.alpha = 1.0
            self.scanTargetImage?.alpha = 0.0
            return
        }
        
        output = AVCaptureMetadataOutput()
        session?.addOutput(output)
        
        let dispatcher: DispatchQueue = DispatchQueue(label: "QRCAPTURESON", attributes: [])
        output?.setMetadataObjectsDelegate(self, queue: dispatcher)
        if LSQUser.currentUser.isHealthNotifierEmployee() {
            // beta scanning feature
            output?.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeDataMatrixCode]
        } else {
            output?.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }
        
        // CAPTURE QR CODE
        
        prevLayer = AVCaptureVideoPreviewLayer(session: session)
        prevLayer?.frame.size = myView.frame.size
        prevLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        prevLayer?.connection.videoOrientation = transformOrientation(UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
        
        myView.layer.addSublayer(prevLayer!)
        myView.bringSubview(toFront: self.scanTargetImage!)
        
        session?.startRunning()
    }
    
    func stopScanning(){
        self.session?.stopRunning()
        self.session = nil
        self.prevLayer?.removeFromSuperlayer()
    }
    
    func parseScan(_ result: AVMetadataMachineReadableCodeObject){
        if self.session == nil {
            print("SHOULD NOT HAVE BEEN PROCESSED!!!! RUNAWAY SCANNER!")
            return
        }
        let code = result.stringValue.uppercased()
        // does our code start with HTTPS://LSQR.NET if not, we're not a code
        // careful about changing the strictness here in case something somethings
        if code.contains("HTTPS://LSQR.NET") {
            
        }
        let matches = LSQ.utils.matchesForRegexInText("[A-Z0-9]{9}$", text: code)
        if matches.count == 1 {
            
            EZLoadingActivity.show("", disableUI: false)
            
            self.stopScanning()
            // vibrate
            // start the spinner
            // print(matches[0]) look it up son
            // load the patient son
            if self.captureMode {
                NotificationCenter.default.post(
                    name: LSQ.notification.hacks.lifesquareCodeCaptured,
                    object: self,
                    userInfo: [
                        "code": matches[0],
                        "mode": "scan"
                    ]
                )
                NotificationCenter.default.post(
                    name: LSQ.notification.dismiss.captureLifesquareCode,
                    object: self
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
                matches[0],
                latitude: latitude,
                longitude: longitude,
                success: { response in
                    EZLoadingActivity.hide(true, animated: true)
                    // stop dat spinner son
                    //[self.activityIndicator stopAnimating];

                    let patient: JSON = JSON(response)
                    let user: LSQUser = LSQUser.currentUser
                    
                    var attributes: [String:AnyObject] = [:]
                    attributes["AccountId"] = user.uuid! as AnyObject
                    attributes["Provider"] = user.provider as AnyObject
                    attributes["PatientId"] = patient["PatientId"].string! as AnyObject
                    
                    NotificationCenter.default.post(
                        name: LSQ.notification.analytics.event,
                        object: nil,
                        userInfo: [
                            "event": "Scan",
                            "attributes": attributes
                        ]
                    )
                    
                    var historyObj: [String: AnyObject] = [:]
                    historyObj["PatientId"] = patient["PatientId"].string! as AnyObject
                    historyObj["Name"] = "\(patient["FirstName"].string!) \(patient["LastName"].string!)" as AnyObject
                    historyObj["Address"] = patient["Residence"]["Address1"].string! as AnyObject
                    historyObj["LifesquareLocation"] = patient["Residence"]["LifesquareLocation"].string! as AnyObject
                    historyObj["ScanTime"] = NSDate.init()
                    LSQScanHistory.sharedInstance.addPatient(historyObj)
                    
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
                    EZLoadingActivity.hide(false, animated: false)
                    var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                        preferredStyle = UIAlertControllerStyle.actionSheet
                    }
                    let alert: UIAlertController = UIAlertController(
                        title: "\(matches[0]) is not an active LifeSticker",
                        message: "",
                        preferredStyle: preferredStyle)
                    
                    let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                        // nothing here
                        self.startScanning()
                    })
                    alert.addAction(cancelAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
            )
            
        }
        // basis regex to extract a match
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // JUMP THREADS SON???
        if metadataObjects != nil && metadataObjects.count > 0 {
            self.parseScan(metadataObjects[0] as! AVMetadataMachineReadableCodeObject)
        }
    }
    
    func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device in devices! {
            if (device as AnyObject).position == position {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.prevLayer?.connection.videoOrientation = self.transformOrientation(UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
            self.prevLayer?.frame.size = self.myView.frame.size
            }, completion: { (context) -> Void in
                
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func transformOrientation(_ orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    @IBAction func switchCameraSide(_ sender: AnyObject) {
        /*
        if let sess = session {
            let currentCameraInput: AVCaptureInput = sess.inputs[0] as! AVCaptureInput
            sess.removeInput(currentCameraInput)
            var newCamera: AVCaptureDevice
            if (currentCameraInput as! AVCaptureDeviceInput).device.position == .Back {
                newCamera = self.cameraWithPosition(.Front)!
            } else {
                newCamera = self.cameraWithPosition(.Back)!
            }
            //let newVideoInput = AVCaptureDeviceInput(device: newCamera, error: nil)
            //session?.addInput(newVideoInput)
        }
        */
    }
}
