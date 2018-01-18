//
//  LSQAPIDocument.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    
    func viewDocument(_ uuid: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "document/" + uuid, method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func deleteDocument(_ uuid: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "documents/" + uuid, method: .delete)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func addDocument(_ data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "documents", method: .post, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func updateDocument(_ uuid: String, data: AnyObject, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "documents/" + uuid, method: .patch, parameters: data as? Parameters, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
    
}
