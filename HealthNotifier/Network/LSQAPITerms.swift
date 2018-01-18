//
//  LSQAPITerms.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    
    func getAutocomplete(_ autocompleteId:String, query: String) -> Void {
        let params:Parameters = [
            "category": autocompleteId,
            "term": query
        ]
        self.sessionManager.request(api_root + "term-lookup/search", method: .get, parameters: params, encoding: URLEncoding.queryString)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.loaded.autocomplete,
                        object: nil,
                        userInfo: [
                            "results": response.result.value!
                        ]
                    )
                case .failure(_):
                    if (response.response != nil) {
                        if response.response?.statusCode == 401 {
                            NotificationCenter.default.post(name: LSQ.notification.auth.unauthorized, object: nil)
                            return
                        }
                    }
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.error,
                        object: nil,
                        userInfo: [
                            "object": "autocomplete",
                            "action": "get",
                            ]
                    )
                }
        }
        
    }
    
    func getMedicationDose(_ medicationName: String) -> Void {
        let params:Parameters = [
            "med_name": medicationName
        ]
        self.sessionManager.request(api_root + "term-lookup/medication", method: .get, parameters: params, encoding: URLEncoding.queryString)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.loaded.medicationDose,
                        object: nil,
                        userInfo: [
                            "results": response.result.value!
                        ]
                    )
                case .failure(_):
                    if (response.response != nil) {
                        if response.response?.statusCode == 401 {
                            NotificationCenter.default.post(name: LSQ.notification.auth.unauthorized, object: nil)
                            return
                        }
                    }
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.error,
                        object: nil,
                        userInfo: [
                            "object": "medicationdose",
                            "action": "get",
                        ]
                    )
                }
        }
    }
    
}
