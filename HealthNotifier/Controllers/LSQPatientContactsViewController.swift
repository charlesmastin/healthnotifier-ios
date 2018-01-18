//
//  LSQPatientContactsViewController.swift
//
//  Created by Charles Mastin on 8/3/16.
//

import Foundation
import UIKit
import SwiftyJSON

class LSQPatientContactsViewController: LSQCollectionBaseViewController {
    
    override func configureTable() {
        self.dataConfig = []
        if !self.editMode {
            self.dataConfig.append(
            [
                "key": "emergency",
                "name": "Emergency",
                "cell": "default",
                "observePress": "yes", // LOL
                "collectionName": LSQModelPatientContact().collectionName// TODO: tap the underlying model
            ])
        }
        
        // and all the rest
        self.dataConfig.append(
            [
            "key": "insurances",
            "name": "Insurances",
            "cell": "default",
            "observePress": "yes", // LOL
            "collectionName": LSQModelPatientInsurance().collectionName
            ]
        )
        
        self.dataConfig.append(
            [
            "key": "care_providers",
            "name": "Physicians",
            "cell": "default",
            "observePress": "yes", // LOL
            "collectionName": LSQModelPatientCareProvider().collectionName
            ]
        )
            
        self.dataConfig.append(
            [
            "key": "hospitals",
            "name": "Hospitals",
            "cell": "default",
            "observePress": "yes", // LOL
            "collectionName": LSQModelPatientMedicalFacility().collectionName
            ]
        )
        
        self.dataConfig.append(
            [
            "key": "pharmacies",
            "name": "Pharmacies",
            "cell": "default",
            "observePress": "yes", // LOL
            "collectionName": LSQModelPatientPharmacy().collectionName
            ]
        )
        
        self.tableView.reloadData()
    }

}
