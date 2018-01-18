//
//  LSQAPIValues.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    func loadValues(){
        // TODO: standard error handling? or not? w/e, we don't need no auth on this though, but we do need a response
        self.sessionManager.request(api_root + "values", method: .get)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(_):
                    self.cached_values = response.result.value as! [[String:AnyObject]]?
                    break
                case .failure(_):
                    // pass
                    break
                }
            })
        // self.cached_values = response.result.value
        
    }
    
    // TODO: restore this
    func getValues(_ model: String, attribute: String?=nil) -> [[String: AnyObject]] {
        // first attempt to find it in our internal 'cache'
        // check the freshness, and if needed recycle our cache
        if self.cached_values != nil {
            if attribute == nil {
                // iterate and find matching KEY, I HATE YOU SWIFT
                // we don't really need this if we have the appropriate typing on cached_values
                for i in 0..<self.cached_values!.count {
                    if self.cached_values![i]["model"] as? String == model {
                        if model == "country" {
                            // find United States, and pluck that sucker to the top of the stack
                            var results:[[String:AnyObject]] = (self.cached_values![i]["values"] as? [[String:AnyObject]])!
                            results.insert(["name": "United States" as AnyObject, "value": "US" as AnyObject], at: 0)
                            return results
                        }
                        return (self.cached_values![i]["values"] as? [[String:AnyObject]])!
                    }
                }
            } else {
                for i in 0..<self.cached_values!.count {
                    if self.cached_values![i]["model"] as? String == model && self.cached_values![i]["attribute"] as? String == attribute {
                        return (self.cached_values![i]["values"] as? [[String:AnyObject]])!
                    }
                }
            }
        } else {
            self.loadValues() // tough luck son
        }
        return Array()
    }
    
    // bwaa
    func getNameForValue(_ model: String, attribute: String?=nil, value: String) -> String {
        // STRAIGHT UP ASSUMING String only yea son
        // yea we could pass in the previously queried values you zlutttt, but there is literally no penalty hgere
        let name: String = ""
        let values = self.getValues(model, attribute: attribute)
        for obj in values {
            if obj["value"] as? String == value {
                return String(describing: obj["name"]!)
            }
        }
        return name
    }
    
    func getValueForName(_ model: String, attribute: String?=nil, name: String) -> String {
        // STRAIGHT UP ASSUMING String only yea son
        // yea we could pass in the previously queried values you zlutttt, but there is literally no penalty hgere
        let value: String = ""
        let values = self.getValues(model, attribute: attribute)
        for obj in values {
            if obj["name"] as? String == name {
                return String(describing: obj["value"]!)
            }
        }
        return value
    }
}
