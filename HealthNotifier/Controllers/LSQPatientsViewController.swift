//
//  LSQPatientsViewController.swift
//
//  Created by Charles Mastin on 12/3/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQPatientsViewController: UICollectionViewController {
    
    var patientsJson: JSON = []
    var patientsLoading: Bool = false
    var imageSize: CGFloat = 88.0
    var loaded: Bool = false
    var refreshControl: UIRefreshControl!
    
    var observationQueue: [AnyObject] = []
    
    @IBAction func viewActions() {
        // NotificationCenter.default.post(name: LSQ.notification.action.createPatient, object: self)
        NotificationCenter.default.post(name: LSQ.notification.action.createPatientOnboarding, object: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("zeroing patient selection though")
        LSQPatientManager.sharedInstance.reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.collectionView!.alwaysBounceVertical = true
        self.collectionView!.addSubview(refreshControl)

        self.title = "My Profiles"
        
        // tweaking dat layout son
        // http://stackoverflow.com/questions/28325277/how-to-set-cell-spacing-and-uicollectionview-uicollectionviewflowlayout-size-r
        let screenSize: CGRect = UIScreen.main.bounds
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: (screenSize.width / 2) - 15.0, height: 250.0)
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        self.collectionView!.collectionViewLayout = layout
        
        self.collectionView!.backgroundColor = LSQ.appearance.color.lightGray
        // when we move to blablabal
        // self.collectionView!.registerClass(LSQProfileCollectionViewCell.self, forCellWithReuseIdentifier: "profileCell")
        
        // TODO: where to unobserve???
        
        // but also if we're already set son
        let user:LSQUser = LSQUser.currentUser
        if user.isLoggedIn() {
            // MEH MEH MEH MEH MEH
            self.loadPatients() // this is the first visible tab, so if yea, it's gonna trigger a 401
            //self.renderProviderStatus()
        }
        
        self.addObservers()
        // self.refreshControl?.addTarget(self, action: #selector(LSQAccountViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        // lock this in some blocking business :) for now, just a cheesy class variable
        // vs checking the underlying AFN since we don't have a reference to that shiz
        if !self.patientsLoading {
            self.loadPatients(false)
        } else {
            // wrap that JW in a timer, just cause
        }
        // refreshControl.endRefreshing()
    }
    
    func addObservers() {
        self.observationQueue = []
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.auth.authorized,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.loadPatients()
            }
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.hacks.reloadPatients,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                self.loadPatients()
            }
        )
        /*
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.network.success,
                object: nil,
                queue: OperationQueue.main
            ) { notification in
                if notification.userInfo!["object"] as? String == "profile" {
                    if notification.userInfo!["action"] as? String == "create" {
                        // THIS IS GOING TO CONFLICT WITH THE ONBOARDING FIRST RUN
                        self.loadPatients(true, uuid: notification.userInfo!["patient_id"] as? String)
                    } else {
                        self.loadPatients()
                    }
                }
                //
            }
        )
         */
    }
    
    func loadPatients(_ showLoader: Bool = true, uuid: String? = nil) {
        print("loadPatients son")
        if showLoader {
            EZLoadingActivity.show("", disableUI: false)
        }
        self.patientsLoading = true
        LSQAPI.sharedInstance.loadPatients(
            { response in
                
                EZLoadingActivity.hide(true, animated: true)
                self.refreshControl.endRefreshing()
                self.loaded = true
                self.patientsLoading = false
                self.patientsJson = JSON(response)
                self.collectionView!.reloadData()
                
                if uuid != nil {
                    NotificationCenter.default.post(
                        name: LSQ.notification.show.profile,
                        object: self,
                        userInfo:[
                            "patientId": uuid!
                        ]
                    )
                    EZLoadingActivity.show("", disableUI: false)
                }
            },
            failure: { response in
                self.patientsLoading = false
                self.refreshControl.endRefreshing()
                EZLoadingActivity.hide(true, animated: true)
                
                let alert: UIAlertController = UIAlertController(
                    title: "Server Error",
                    message: "Unable to load profiles",
                    preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.cancel, handler: { action in
                })
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        )
    }
    
    func populateDataProvider() -> Void {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.loaded {
            return self.patientsJson["Patients"].count
        }
        return 0
        //return self.items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = LSQ.appearance.color.lightGray2
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = LSQ.appearance.color.white
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row: JSON = self.patientsJson["Patients"][indexPath.row]
        NotificationCenter.default.post(
            name: LSQ.notification.show.profile,
            object: self,
            userInfo:[
                "patientId": row["PatientId"].string!,
            ]
        )
        EZLoadingActivity.show("", disableUI: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row: JSON = self.patientsJson["Patients"][indexPath.row]
        var cell: LSQProfileCollectionViewCell
        var hasLifesquare: Bool = false
        if row["LifesquareId"] != JSON.null {
            hasLifesquare = true
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! LSQProfileCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCellOnboarding", for: indexPath) as! LSQProfileCollectionViewCell
        }
        
        // http://stackoverflow.com/questions/33875133/uicollectionview-customcell-reuse
        var name = row["FirstName"].string!
        var age = row["Age"].string!
        if name == "" {
            name = "New Profile"
            age = " "
        }
        if age == "" {
            // blablabla birthdate on 1/1/1
        }
        
        cell.labelName?.text = name
        cell.labelAge?.text = age
        
        // profile photo son
        let placeholder = UIImage(named: "selfie_image")
        cell.imageProfile?.contentMode = UIViewContentMode.scaleAspectFill
        cell.imageProfile?.kf.setImage(
            with: URL(string: "\(row["ProfilePhoto"].string!)?width=\(Int(self.imageSize * 2))&height=\(Int(self.imageSize * 2))"),
            placeholder: placeholder,
            options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)]
        )
        
        // round it up son buns hons
        // http://stackoverflow.com/questions/29173116/swift-mask-of-circle-layer-over-uiview
        let innerFrame = CGRect(x: 0, y: 0, width: self.imageSize - 2, height: self.imageSize - 2)
        let maskLayer = CAShapeLayer()
        let circlePath = UIBezierPath(roundedRect: innerFrame, cornerRadius: innerFrame.width)
        maskLayer.path = circlePath.cgPath
        maskLayer.fillColor = LSQ.appearance.color.blue.cgColor
        
        let strokeLayer = CAShapeLayer()
        strokeLayer.path = circlePath.cgPath
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.strokeColor = LSQ.appearance.color.white.cgColor
        strokeLayer.lineWidth = 2
        
        // add the layer
        cell.imageProfile?.layer.addSublayer(maskLayer)
        cell.imageProfile?.layer.mask = maskLayer
        cell.imageProfile?.layer.addSublayer(strokeLayer)
        
        if hasLifesquare {
            cell.labelLifesquare?.text = row["LifesquareId"].string!
            let placeholder = UIImage(named: "qrcode")
            cell.imageLifesquare?.contentMode = UIViewContentMode.scaleAspectFill
            let imageURL: String = "\(LSQAPI.sharedInstance.api_root)lifesquares/\(row["LifesquareId"].string!)/image?width=\(Int(self.imageSize * 2))&height=\(Int(self.imageSize * 2))"

            cell.imageLifesquare?.kf.setImage(
                with: URL(string: imageURL),
                placeholder: placeholder,
                options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)]
            )
        } else {
            /*
            let placeholder = UIImage(named: "qrcode")
            cell.imageLifesquare?.contentMode = UIViewContentMode.ScaleAspectFill
            cell.imageLifesquare?.image = placeholder
            cell.imageLifesquare?.alpha = 0.1
            
            cell.labelLifesquare?.text = "Continue Setup"
            cell.labelLifesquare?.textColor = LSQ.appearance.color.blueApple
            */
        }
        
        cell.backgroundColor = LSQ.appearance.color.white // make cell more visible in our example project
        
        return cell
    }
    
}
