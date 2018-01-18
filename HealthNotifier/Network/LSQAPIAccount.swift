//
//  LSQAPIAccount.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    func getAccount(_ uuid: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        var params: Parameters = [:]
        if self.device_token != nil {
            params["device_token"] = self.device_token!
        }
        self.sessionManager.request(api_root + "accounts/" + uuid, method: .get, parameters: params)
            .defaultResponseHandler(success, failure: failure)
    }
       
    func registerUser(_ data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // slightly misleading since it has both auth headers and misc client headers… lol brolo
        self.sessionManager.request(api_root + "accounts", method: .post, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func registerUserBasic(_ data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // slightly misleading since it has both auth headers and misc client headers… lol brolo
        self.sessionManager.request(api_root + "accounts/basic", method: .post, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func addDeviceToken(_ token: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // lol
        self.device_token = token
        //
        let params: Parameters =
        [
            "platform": "ios", // should be from headers
            "device_token": token
        ]
        self.sessionManager.request(api_root + "devices", method: .post, parameters: params, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func updateUser(_ uuid: String, data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "accounts/" + uuid, method: .put, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func getAccountNotifications(_ success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "accounts/notifications", method: .get)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func updateLocation(_ latitude: Double, longitude: Double, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // LOL on new style API here
        let params: Parameters =
        [
            "latitude": latitude as AnyObject,
            "longitude": longitude as AnyObject
        ]
        self.sessionManager.request(api_root + "accounts/location", method: .post, parameters: params, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
}
