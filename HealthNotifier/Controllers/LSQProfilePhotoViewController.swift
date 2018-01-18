//
//  LSQProfilePhotoViewController.swift
//
//  Created by Charles Mastin on 10/18/16.
//

import Foundation
import UIKit
import Kingfisher
import EZLoadingActivity

class LSQProfilePhotoViewController: UIViewController {
    //
    @IBOutlet weak var profilePhoto: UIImageView?
    // TODO: for the future, patients may have multiple photos
    
    // also this coule become an edit container view, or something w/e
    // we is a modal, but we should genericize this beast son
    @IBAction func handleClose() {
        EZLoadingActivity.hide(true, animated: true)
        self.close()
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = LSQ.appearance.color.stolenBlue
    }
    
    func loadImage(_ url: String) {
        EZLoadingActivity.show("", disableUI: false)
        //let placeholder = UIImage(named: "selfie_image")
        self.profilePhoto!.contentMode = UIViewContentMode.scaleAspectFit
        self.profilePhoto!.kf.setImage(
            with: URL(string: url),
            placeholder: nil,
            options: [.requestModifier(LSQAPI.sharedInstance.kfModifier)],
            progressBlock: { (receivedSize, totalSize) -> () in
                //print("Download Progress: \(receivedSize)/\(totalSize)")
            },
            completionHandler: { (image, error, cacheType, imageURL) -> () in
                EZLoadingActivity.hide(true, animated: true)
                //print("Downloaded and set!")
            }
        )
    }
}
