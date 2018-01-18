//
//  LSQPatientMedicalViewController.swift
//
//  Created by Charles Mastin on 8/3/16.
//

import Foundation
import UIKit
import SwiftyJSON
import Kingfisher

class LSQPatientMedicalViewController: LSQCollectionBaseViewController {
    
    override func configureTable() {
        // TODO: onboarding data scheme configuration up in this bitch
        self.dataConfig = [
            [
                "key": "directives",
                "name": "Directives",
                "cell": "document",
                "observePress": "yes", // LOL
                "collectionName": "" // unique delete endpoint
            ],
            [
                "key": "medications",
                "name": "Medications",
                "cell": "default",
                "observePress": "no", // LOL
                "collectionName": LSQModelPatientTherapy().collectionName// TODO: tap the underlying model
            ],
            [
                "key": "allergies",
                "name": "Allergies",
                "cell": "default",
                "observePress": "no", // LOL
                "collectionName": LSQModelPatientAllergy().collectionName
            ],
            [
                "key": "conditions",
                "name": "Conditions",
                "cell": "default",
                "observePress": "no", // LOL
                "collectionName": LSQModelPatientCondition().collectionName
            ],
            [
                "key": "procedures",
                "name": "Procedures & Devices",
                "cell": "default",
                "observePress": "no", // LOL
                "collectionName": LSQModelPatientProcedure().collectionName
            ],
            [
                "key": "immunizations",
                "name": "Immunizations",
                "cell": "default",
                "observePress": "no", // LOL
                "collectionName": LSQModelPatientImmunization().collectionName
            ],
            [
                "key": "documents",
                "name": "Documents",
                "cell": "document", // unique delete endpoint or something
                "observePress": "yes", // LOL
                "collectionName": ""
            ]
        ]
        
        // da F
        // self.broadcastSize()
    }

}
