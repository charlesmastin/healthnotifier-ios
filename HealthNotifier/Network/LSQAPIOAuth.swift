//
//  LSQAPIOAuth.swift
//
//  Created by Charles Mastin on 5/17/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    func getAccessToken(_ email: String, password: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        let params: Parameters =
        [
            "grant_type": "password",
            "username": email,
            "password": password
        ]
        // TODO: until the default response handler can introspect the request and check against login, we can't use it
        self.sessionManager.request(api_root + "oauth/access_token", method: .post, parameters: params, encoding: URLEncoding.default)
            .validate()
            .responseJSON(completionHandler: { response in
                // TODO: robust validation here?
                switch response.result {
                case .success(_):
                    // let's break the mold and do some processing here before sending it back. Because WHY NOT
                    success(response.result.value! as AnyObject)
                case .failure(_):
                    failure(response as AnyObject)
                }
            })
        
    }
    
    func revokeAccessToken(token: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        let params: Parameters =
            [
                "token_type_hint": "access_token",
                "token": token
        ]
        // TODO: until the default response handler can introspect the request and check against login, we can't use it
        self.sessionManager.request(api_root + "oauth/revoke_token", method: .post, parameters: params, encoding: URLEncoding.default)
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
}
