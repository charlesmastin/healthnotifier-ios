//
//  LSQAPI.swift
//
//  Created by Charles Mastin on 7/27/16.
//

// TODO: unify name of all da methods SON
// TODO: standardize signatures to use callbacks, and DRY up notifications

import Foundation
import Alamofire
import Kingfisher

class LSQAPI {
    static let sharedInstance = LSQAPI()
    let release_api_root: String = "https://api.domain.com/api/v1/"
    let api_root:String = "http://10.0.1.9:3000/api/v1/"//"//http://10.0.1.12:3000/api/v1/"//"but "
    var cached_values: [[String: AnyObject]]? = nil
    var headers: [String:String] = [:]
    
    // workaround to store the device token
    var device_token: String? = nil
    
    var kfModifier = AnyModifier { request in
        return request
    }
    
    var sessionManager: SessionManager = SessionManager()
    
    // attach the headers
    func setToken(token: String){
        self.headers["Authorization"] = "Bearer \(token)"
        self.updateSession()
    }
    
    func clearToken(){
        self.headers.removeValue(forKey: "Authorization")
        self.updateSession()
    }
    
    func updateSession() -> Void {
        // meh meh meh meh
        self.sessionManager = SessionManager()
        self.sessionManager.adapter = LSQAPIRequestAdapter(headers: self.headers)
    }
    
    func setClientVersion(build: String, name: String){
        self.headers["HealthNotifier-Client-Version"] = build
        self.headers["HealthNotifier-Client-Version-Name"] = name
        self.updateSession()
        
        kfModifier = AnyModifier { request in
            var r = request
            r.setValue(build, forHTTPHeaderField: "HealthNotifier-Client-Version")
            r.setValue(name, forHTTPHeaderField: "HealthNotifier-Client-Version-Name")
            // TODO: add authorization token for direct image requests?
            return r
        }
    }
    
}
