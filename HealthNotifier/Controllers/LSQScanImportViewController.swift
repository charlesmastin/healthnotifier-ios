//
//  LSQScanImportViewController.swift
//
//  Created by Charles Mastin on 2/20/17.
//

import Foundation
import AVFoundation
import UIKit
import SwiftyJSON
import CoreLocation

class LSQScanImportViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
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
        self.dismissMe(animated: true, completion: nil)
        /*
        NotificationCenter.default.post(
            name: LSQ.notification.dismiss.scanImport,
            object: self,
            userInfo: [
                "origin": "user"// hack so we "KNOW" it's a user press vs just a rando call to "close" the window like Hide it
            ]
        )
        */
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startScanning()
        if LSQUser.currentUser.provider {
            LSQLocationManager.sharedInstance.start()
        }
        // meh zone
        //if LSQOnboardingManager.sharedInstance.active {
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
        //}
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
        output?.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeDataMatrixCode]
        
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
        let code = result.stringValue
        print("RAW CAPTURE")
        print("\(String(describing: code))")
        self.stopScanning()
        
        var payload:[String:AnyObject] = [:]
        payload["data"] = code as AnyObject?
        
        // TODO: error handling
        
        
        LSQAPI.sharedInstance.parseLicense(
            payload as AnyObject,
            success: { response in
                let rJson: JSON = JSON(response)
                print(rJson)
                NotificationCenter.default.post(
                    name: LSQ.notification.hacks.licenseCaptured,
                    object: self,
                    userInfo: [
                        "onboarding": true,
                        "data": (rJson.object)
                    ]
                )
            },
            failure: { response in
                self.startScanning()
            }
        )
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
