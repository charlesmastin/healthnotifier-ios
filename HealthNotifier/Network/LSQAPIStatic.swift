//
//  LSQAPIStatic.swift
//
//  Created by Charles Mastin on 9/5/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    
    func getStatic(_ slug: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "static/\(slug)", method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
    func getTerms(_ success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "static/terms", method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
    func getPrivacy(_ success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "static/privacy", method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
}
