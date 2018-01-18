//
//  LSQAPIPatient.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire
import SwiftyJSON

extension LSQAPI {
    
    func createPatientBasic(_ data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // slightly misleading since it has both auth headers and misc client headers… lol brolo
        self.sessionManager.request(api_root + "profiles/basic", method: .post, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func loadPatients(_ success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "patients", method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func loadPatient(_ patient_id: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "profiles/" + patient_id, method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
    
    // this will continue to use the ASYNC notifications only for the time being as it's invoked in the mediator and manages flow
    // and is decoupled from the various consumers
    func loadPatientLegacy(_ patient_id: String) -> Void {
        self.sessionManager.request(api_root + "profiles/" + patient_id, method: .get)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "profile",
                            "action": "get",
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
                            "object": "profile",
                            "action": "get"
                        ]
                    )
                }
            })
        
    }
    
    // bridging the gap son buns
    // TODO: retire and merge all utilization with the LSQPatientManager and the basic patient.loaded notification
    func loadPatientWithCallbacks(_ uuid: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "profiles/" + uuid, method: .get)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.loaded.patient,
                        object: self,
                        userInfo: [
                            "patientInstance": response.result.value!
                        ]
                    )
                    success(response.result.value! as AnyObject)
                case .failure(_):
                    if (response.response != nil) {
                        if response.response?.statusCode == 401 {
                            NotificationCenter.default.post(name: LSQ.notification.auth.unauthorized, object: nil)
                            return
                        }
                    }
                    failure(response as AnyObject)
                }
        }
    }
    
    func parseLicense(_ data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        Alamofire.request(api_root + "parser/drivers-license", method: .post, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func createProfile() -> Void {
        // 0 params son
        self.sessionManager.request(api_root + "profiles", method: .post)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    let j:JSON = JSON(response.result.value as Any)
                    if let patient_id: String = j["uuid"].string {
                        NotificationCenter.default.post(
                            name: LSQ.notification.network.success,
                            object: nil,
                            userInfo: [
                                "object": "profile",
                                "action": "create",
                                "patient_id": patient_id,
                                "response": response.result.value!
                            ]
                        )
                    }                    
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
                            "object": "profile",
                            "action": "create"
                        ]
                    )
                }
            })
    }
    
    func deleteProfile(_ uuid: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "profiles/" + uuid, method: .delete)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func updateProfile(_ patient_id: String, json: AnyObject) -> Void {
        self.sessionManager.request(api_root + "profiles/" + patient_id, method: .put, parameters: json as? Parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "profile",
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
                            "object": "profile",
                            "action": "update",
                            "patient_id": patient_id
                        ]
                    )
                }
            })
        
    }
    
    func updateProfileWithCallbacks(_ uuid: String, data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "profiles/" + uuid, method: .put, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func updateProfilePhoto(_ uuid: String, data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "profiles/" + uuid + "/profile-photo", method: .put, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
    
    // TODO: WTF SON?
    func confirmProfile(_ uuid: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "profiles/" + uuid + "/confirm", method: .put)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func getCollection(_ patient_id: String, collection_name: String) -> Void {
        // yup, because sometimes, we might want to do this, but probably not, we'll probably get a fresh copy of the entire patient yo…, we shall see
    }
    
    // GENERIC endpoint as we know for creating, updating, deleting
    func updateCollection(_ patient_id: String, collection_name: String, data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // POST and PUT lolzones
        // consider merging in da patientId and recordOrder??
        var params: Parameters = [:]
        params[collection_name] = [ data ]
        
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/" + collection_name,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default
            )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    // TODO: notification / pass that sucker down the chain to the callback?
                    success(response.result.value! as AnyObject)
                    // hack zor xor
                    NotificationCenter.default.post(
                        name: LSQ.notification.network.success,
                        object: nil,
                        userInfo: [
                            "object": "collection.\(collection_name)",
                            "action": "update",
                            "patient_id": patient_id
                        ]
                    )
                    
                case .failure(_):
                    if (response.response != nil) {
                        if response.response?.statusCode == 401 {
                            NotificationCenter.default.post(name: LSQ.notification.auth.unauthorized, object: nil)
                            return
                        }
                    }
                    failure(response as AnyObject)
                }
        }
    }
    
    func messageContacts(_ patient_id: String, message: String, latitude: Double?=nil, longitude: Double?=nil){
        var params: Parameters = [:]
        params["message"] = message
        if latitude != nil && longitude != nil {
            params["latitude"] = latitude as AnyObject?
            params["longitude"] = longitude as AnyObject?
        }
        // TODO: callbacks missing, no error capabilties here
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/emergency-contacts/message", method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    break
                case .failure(_):
                    if (response.response != nil) {
                        if response.response?.statusCode == 401 {
                            NotificationCenter.default.post(name: LSQ.notification.auth.unauthorized, object: nil)
                            return
                        }
                    }
                }
        }
    }
    
    func getPopularTerms(_ patient_id: String, category: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/popular-terms/" + category, method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
    
}
