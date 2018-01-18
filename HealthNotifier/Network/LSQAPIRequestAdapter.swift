//
//  LSQAPIRequestAdapter.swift
//
//  Created by Charles Mastin on 3/23/17.
//

import Foundation
import Alamofire

class LSQAPIRequestAdapter: RequestAdapter {
    private let headers: [String: String]
    
    init(headers: [String:String]) {
        self.headers = headers
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        // iterate dem headers bro, regardless of classification "auth" or "client meta"
        for(k, v) in self.headers {
            urlRequest.setValue(v, forHTTPHeaderField: k)
        }
        return urlRequest
    }
}
