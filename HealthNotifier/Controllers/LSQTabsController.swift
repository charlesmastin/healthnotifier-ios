//
//  LSQTabsController.swift
//
//  Created by Charles Mastin on 12/15/16.
//

import Foundation
import UIKit
import FontAwesome_swift

class LSQTabsController : UITabBarController {
    func customizeDemTabsSon() {
        for tab in self.tabBar.items! {
            if tab.tag == 3 {
                tab.title = "Invites"
                tab.image = UIImage.fontAwesomeIcon(name: .envelopeO, textColor: UIColor.black, size: CGSize(width: 35, height: 35))
                tab.selectedImage = UIImage.fontAwesomeIcon(name: .envelopeO, textColor: UIColor.black, size: CGSize(width: 35, height: 35))
                // FONT FACE MOTHER TRUCKER
            }
            if tab.tag == 1 {
                //tab.title = "Scan"
                //tab.image = UIImage.fontAwesomeIcon(name: .camera, textColor: UIColor.blackColor(), size: CGSizeMake(35, 35))
                
                // tab.image = UIImage.fontAwesomeIcon
                // FONT FACE MOTHER TRUCKER
            }
            if tab.tag == 2 {
                tab.image = UIImage.fontAwesomeIcon(name: .cog, textColor: UIColor.black, size: CGSize(width: 35, height: 35))
                tab.selectedImage = UIImage.fontAwesomeIcon(name: .cog, textColor: UIColor.black, size: CGSize(width: 35, height: 35))
            }
        }
    }
}
