//
//  LSQAPILifesquare.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    
    func patientFromLifesquare(_ code: String, latitude: Double?=nil, longitude: Double?=nil, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        var params: Parameters = [:]
        if latitude != nil && longitude != nil {
            params["latitude"] = latitude as AnyObject?
            params["longitude"] = longitude as AnyObject?
        }
        self.sessionManager.request(api_root + "lifesquare/" + code, method: .get, parameters: params, encoding: URLEncoding.queryString)
            .defaultResponseHandler(success, failure: failure)
    }
    
    // lifesquare API for stuffs son
    func processLifesquares(_ json: AnyObject, action: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "lifesquares/" + action, method: .post, parameters: json as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func validateLifesquares(_ json: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "lifesquares/validate", method: .post, parameters: json as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
    
}
