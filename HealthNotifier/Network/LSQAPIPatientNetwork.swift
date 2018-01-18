//
//  LSQAPIPatientNetwork.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    
    // initial is a discreet call
    func patientNetworkConnections(_ patient_id: String) -> Void {
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/network", method: .get)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "patientnetwork",
                            "action": "index",
                            "response": response.result.value!
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
                            "object": "patientnetwork",
                            "action": "index",
                            ]
                    )
                    
                }
            })
    }
    
    func patientNetworkSearch(_ patient_id: String, keywords: String, group: String? = nil) -> Void {
        // format the params son
        var params:Parameters = [
            "keywords": keywords
        ]
        if group != nil {
            params["group"] = group
        }
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/network/search", method: .get, parameters: params, encoding: URLEncoding.queryString)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "patientnetwork",
                            "action": "search",
                            "response": response.result.value!
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
                            "object": "patientnetwork",
                            "action": "search",
                            ]
                    )
                }
            })
    }
    
    // these could basically be generically handled in one method
    
    // AUDITOR is the person ABLE TO VIEW
    // GRANTER is the patient BEING VIEWED
    // TODO: rework entire API to only accept a single param for the "granter or auditor", it's always contextual based on operation
    
    // add
    func patientNetworkAdd(_ patient_id: String, granter_id: String, auditor_id: String, privacy: String) -> Void {
        let params: Parameters = [
            "AuditorId": auditor_id as AnyObject,
            "GranterId": granter_id as AnyObject,
            "Privacy": privacy as AnyObject
        ]
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/network/add", method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "patientnetwork",
                            "action": "add",
                            "response": response.result.value!
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
                            "object": "patientnetwork",
                            "action": "add",
                            ]
                    )
                }
            })
        
    }
    
    // request_access
    func patientNetworkRequestAccess(_ patient_id: String, granter_id: String, auditor_id: String) -> Void {
        let params: Parameters = [
            "AuditorId": auditor_id as AnyObject,
            "GranterId": granter_id as AnyObject
        ]
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/network/request-access", method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "patientnetwork",
                            "action": "request-access",
                            "patient_id": patient_id,
                            "response": response.result.value!
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
                            "object": "patientnetwork",
                            "action": "request-access",
                        ]
                    )
                }
            })
        
    }
    
    // accept
    func patientNetworkAccept(_ patient_id: String, granter_id: String, auditor_id: String, privacy: String) -> Void {
        let params: Parameters = [
            "AuditorId": auditor_id,
            "GranterId": granter_id,
            "Privacy": privacy
        ]
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/network/accept", method: .put, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "patientnetwork",
                            "action": "accept",
                            "patient_id": patient_id,
                            "response": response.result.value!
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
                            "object": "patientnetwork",
                            "action": "accept",
                        ]
                    )
                }
            })
        
    }
    
    // decline
    func patientNetworkDecline(_ patient_id: String, granter_id: String, auditor_id: String) -> Void {
        let params: Parameters = [
            "AuditorId": auditor_id,
            "GranterId": granter_id
            // Reason: "You are creepy and I don't like creeps? Sorry!"
        ]
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/network/decline", method: .put, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "patientnetwork",
                            "action": "decline",
                            "patient_id": patient_id,
                            "response": response.result.value!
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
                            "object": "patientnetwork",
                            "action": "decline",
                        ]
                    )
                }
            })
    }
    
    // update
    func patientNetworkUpdate(_ patient_id: String, granter_id: String, auditor_id: String, privacy: String) -> Void {
        let params: Parameters = [
            "AuditorId": auditor_id,
            "GranterId": granter_id,
            "Privacy": privacy
        ]
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/network/update", method: .put, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "patientnetwork",
                            "action": "update",
                            "patient_id": patient_id,
                            "response": response.result.value!
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
                            "object": "patientnetwork",
                            "action": "update",
                        ]
                    )
                }
            })
    }
    
    // revoke
    func patientNetworkRevoke(_ patient_id: String, granter_id: String, auditor_id: String) -> Void {
        let params: Parameters = [
            "AuditorId": auditor_id,
            "GranterId": granter_id
            // "Reason": "You are creepy"
        ]
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/network/revoke", method: .delete, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "patientnetwork",
                            "action": "revoke",
                            "patient_id": patient_id,
                            "response": response.result.value!
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
                            "object": "patientnetwork",
                            "action": "revoke",
                        ]
                    )
                }
            })
    }
    
    // leave
    func patientNetworkLeave(_ patient_id: String, granter_id: String, auditor_id: String) -> Void {
        let params: Parameters = [
            "AuditorId": auditor_id,
            "GranterId": granter_id
            // "Reason": "You are creepy"
        ]
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/network/leave", method: .delete, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "patientnetwork",
                            "action": "leave",
                            "patient_id": patient_id,
                            "response": response.result.value!
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
                            "object": "patientnetwork",
                            "action": "leave",
                        ]
                    )
                }
            })
    }

}
