//
//  LSQDocumentViewController.swift
//
//  Created by Charles Mastin on 3/1/16.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQDocumentViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var closeButton: UIBarButtonItem?
    @IBOutlet weak var deleteButton: UIBarButtonItem?
    @IBOutlet weak var webView: UIWebView?
    
    var documentJson: JSON = []
    // our anchor tag on the screen, lulz
    var initialIndex: String = "#file-0"
    var documentId: String = ""
    
    // TODO: review architecture but for now, assume we have no communication with outside objects for data other than user singleton
    var patientId: String = ""
    var durationTimer: LSQDurationTimer?
    var loadingComplete: Bool = false
    
    @IBAction func deleteDocument(_ sender: AnyObject?) {
        print("DELETE DOCUMENT????")
        /*
        // TODO: NOT WIRED UP
        // what the duck do the deleting here? and then close bro
        NotificationCenter.default.post(
            name: LSQ.notification.action.deleteDocument,
            object: self,
            userInfo: ["Uid": self.documentJson["Uid"].string!]
        )
         */
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: AnyObject?) {
        self.close()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.durationTimer = LSQDurationTimer()
        // kick off a request
        
        // if we aren't the OWNER remove the deleteButton
        // fortunately the backend will validate against this
        
        // self.deleteButton?.enabled = false
        
        self.title = "Document" // NSLocalizedString("healthnotifier.titles.document", "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let user: LSQUser = LSQUser.currentUser
        NotificationCenter.default.post(name: LSQ.notification.analytics.event, object: nil, userInfo:[
            "event": "Document View",
            "attributes": [
                // basic stuffs
                "AccountId": user.uuid!,
                "Provider": user.provider,
                //
                "PatientId": self.patientId,
                
                "DocumentId": self.documentId,
                "DocumentIndex": self.initialIndex,
                "ViewDuration": self.durationTimer!.stop(),
                "LoadingComplete": self.loadingComplete,
            ]
        ])
        
        super.viewWillDisappear(animated)
        EZLoadingActivity.hide()
        self.webView?.stopLoading()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        EZLoadingActivity.hide(true, animated: true)
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData(_ documentId: String, fileIndex: String) {
        self.documentId = documentId
        self.initialIndex = fileIndex
        
        LSQAPI.sharedInstance.viewDocument(
            documentId,
            success: { response in
                self.documentJson = JSON(response as! [AnyHashable: Any])
                /*
                if self.documentJson["Owner"].bool! {
                    self.deleteButton?.enabled = true
                } else{
                    self.navigationItem.leftBarButtonItem = nil
                }
                */
                self.title = LSQ.formatter.documentType(self.documentJson["Title"].string!)
                self.webView?.loadHTMLString(self.documentJson["Html"].string! as String, baseURL: nil)
            },
            failure:{ response in
                EZLoadingActivity.hide(false, animated: true)
            }
        )
        
        EZLoadingActivity.show("", disableUI: false)
        
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "window.location.href = '" + self.initialIndex + "';")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadingComplete = true
        // TODO: revisit on large multipage documents, LOLZORS
        EZLoadingActivity.hide(true, animated: true)
        // unless the user has started interacting with things, then disregard
        // THIS WILL BE A UX ISSUE UNTIL WE GO FULL NATIVE, BUT IT'S A TRADEOFF
        webView.stringByEvaluatingJavaScript(from: "window.location.href = '" + self.initialIndex + "';")
    }
}
