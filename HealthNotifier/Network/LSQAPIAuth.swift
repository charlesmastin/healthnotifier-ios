//
//  LSQAPI2.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    func authenticateAccount(_ email: String, password: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        let params: Parameters =
        [
            "Email": email,
            "Password": password
        ]
        // TODO: until the default response handler can introspect the request and check against login, we can't use it
        self.sessionManager.request(api_root + "auth/login", method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    success(response.result.value! as AnyObject)
                case .failure(_):
                    failure(response as AnyObject)
                }
            })
        
    }
    
    func deauthenticateAccount(_ success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // auth based request brosef
        var params: Parameters = [:]
        if self.device_token != nil {
            params["device_token"] = self.device_token!
        }
        // negative on doing the default handler until we can inspect the request and whitelist this for 401s
        self.sessionManager.request(api_root + "auth/logout", method: .delete, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    success(response.result.value! as AnyObject)
                case .failure(_):
                    // if we had a 401 it's because we already had an invalid token or something or other, meh
                    failure(response as AnyObject)
                }
            })
        //.defaultResponseHandler(success, failure: failure)
        
    }
    
    func verifyAccountCredentials(_ uuid: String, password: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        let params: Parameters =
        [
            "password": password
        ]
        // TODO: until the default response handler can introspect the request and check against login, we can't use it
        self.sessionManager.request(api_root + "accounts/" + uuid + "/verify-credentials", method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    success(response.result.value! as AnyObject)
                case .failure(_):
                    failure(response as AnyObject)
                }
            })
        
    }
    
    func deleteAccount(_ uuid: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "accounts/" + uuid, method: .delete)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func forgotPassword(_ email: String, phone: String="", success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        var params: Parameters =
        [
            "Email": email
        ]
        if phone != "" {
            params["MobilePhone"] = phone
        }
        self.sessionManager.request(api_root + "accounts/begin-recovery", method: .post, parameters: params, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func unlockAccountWithCode(_ code: String, phone: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        let params: Parameters =
        [
            "UnlockCode": code,
            "MobilePhone": phone,
        ]
        self.sessionManager.request(api_root + "accounts/recover", method: .post, parameters: params, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
    func completeRecovery(_ password: String, token: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        let params: Parameters =
        [
            "Password": password,
            "Token": token,
        ]
        self.sessionManager.request(api_root + "accounts/complete-recovery", method: .post, parameters: params, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
        
    }
    
}
