//
//  LSQProfileEmergencyViewController.swift
//
//  Created by Charles Mastin on 12/7/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQProfileEmergencyViewController: LSQCollectionBaseViewController {
    
    override func configureTable() {
        self.dataConfig = []
        
        // be careful up in hizzle
        if LSQOnboardingManager.sharedInstance.active == false {
            self.dataConfig.append(
            [
                "key": "emergency-promo",
                "name": "",
                "cell": "custom",
                "observePress": "no",
                "collectionName": ""
            ])
        }
        self.dataConfig.append(
        [
            "key": "emergency",
            "name": "",
            "cell": "default",
            "observePress": "yes", // LOL
            "collectionName": LSQModelPatientContact().collectionName// TODO: tap the underlying model
        ])
        
        // and when we have content son
        if let _ = self.data["meta"]["coverage"].dictionaryObject {
            if self.data["emergency"].arrayValue.count > 0 {
                
                self.dataConfig.append(
                    [
                        "key": "emergency-actions",
                        "name": "",
                        "cell": "custom",
                        "observePress": "no",
                        "collectionName": ""
                    ])
            }
        } else {
            
        }
        
        
    }
    
    // add another button somewhere, like in the right actions
    
}
