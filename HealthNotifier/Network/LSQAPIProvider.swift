//
//  LSQAPIProvider.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    
    func registerProvider(_ data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "provider-credentials", method: .post, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func nearbyLifesquares(_ latitude: Double, longitude: Double, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        let params: Parameters =
        [
            "latitude": latitude as AnyObject,
            "longitude": longitude as AnyObject
        ]
        
        self.sessionManager.request(api_root + "lifesquares/nearby", method: .get, parameters: params, encoding: URLEncoding.queryString)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func searchLifesquares(_ keywords: String, latitude: Double?=nil, longitude: Double?=nil, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        var params: Parameters =
        [
            "keywords": keywords
        ]
        if latitude != nil && longitude != nil {
            params["latitude"] = latitude as AnyObject?
            params["longitude"] = longitude as AnyObject?
        }
        
        self.sessionManager.request(api_root + "lifesquares/search", method: .get, parameters: params, encoding: URLEncoding.queryString)
            .defaultResponseHandler(success, failure: failure)
    }
}
