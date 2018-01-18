//
//  LSQAPICareplan.swift
//
//  Created by Charles Mastin on 3/22/17.
//

import Foundation
import Alamofire

extension LSQAPI {
    
    func loadCareplans(_ patient_id: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/advise-me", method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func loadCareplanQuestionGroup(_ patient_id: String, questiongroup_uuid: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // get the descriptive JSON so we can build the UI for the given question group
        // could we not store a reference in the class? seems like a simple solution, but w/e
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/advise-me/question-group/" + questiongroup_uuid, method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func sendCareplanResponses(_ patient_id: String, questiongroup_uuid: String, answers: [[String: AnyObject]], success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // form up the params SOnnnnny buns huns
        let params : Parameters = [
            "question_group_uuid": questiongroup_uuid,
            "answers": answers
        ]
        
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/advise-me/response", method: .post, parameters: params, encoding: JSONEncoding.default)
            .defaultResponseHandler(success, failure: failure)
    }
    
    func loadCareplanRecommendation(_ patient_id: String, recommendation_uuid: String, success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        // so much OTT son
        self.sessionManager.request(api_root + "profiles/" + patient_id + "/advise-me/advice/" + recommendation_uuid, method: .get)
            .defaultResponseHandler(success, failure: failure)
    }
    
}
