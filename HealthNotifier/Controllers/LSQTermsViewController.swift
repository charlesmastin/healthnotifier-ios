//
//  LSQTermsController.swift
//
//  Created by Charles Mastin on 9/5/17.
//

import Foundation
import UIKit
import SwiftyJSON
import EZLoadingActivity

class LSQTermsViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var agreeButton: UIBarButtonItem?
    @IBOutlet weak var webView: UIWebView?
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var loadingComplete: Bool = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.agreeButton?.isEnabled = true
        print(scrollView.contentSize.height)
        if (scrollView.contentOffset.y == 0) {
            //Do what you want.
            print("a")
        } else {
            print("b")
        }
    }
    
    // legacy town for modal only presentation meh meh meh
    @IBAction func done(_ sender: AnyObject?){
        self.close()
    }
    
    @IBAction func agree(_ sender: AnyObject?){
        if self.wasPresented {
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(
                    name: LSQ.notification.action.acceptTerms,
                    object: self
                )
            })
        } else {
            NotificationCenter.default.post(
                name: LSQ.notification.action.acceptTerms,
                object: self
            )
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    internal func close(){
        if self.wasPresented {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func segmentedControlAction() -> Void {
        self.renderTab()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.segmentedControl!.tintColor = LSQ.appearance.color.newBlue // TODO: use correct hook
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.renderTab()
        self.webView?.scrollView.delegate = self
    }
    
    func showTab(index: Int){
        // danger zone brolo
        self.segmentedControl!.selectedSegmentIndex = index
        self.renderTab()
    }
    
    func renderTab(){
        // TODO: hahahah city brolo
        let int : Int = self.segmentedControl!.selectedSegmentIndex as Int
        if(int == 0){
            self.loadData("terms")
            self.navigationItem.title = "Terms of Use"
        } else {
            self.loadData("privacy")
            self.navigationItem.title = "Privacy Policy"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EZLoadingActivity.hide()
        self.webView?.stopLoading()
    }
    
    deinit {
        EZLoadingActivity.hide(true, animated: true)
        // NotificationCenter.default.removeObserver(self)
    }
    
    func loadData(_ slug: String) {
        LSQAPI.sharedInstance.getStatic(
            slug,
            success: { response in
                let p: JSON = JSON(response)
                self.webView?.loadHTMLString(p["html"].string! as String, baseURL: nil)
            },
            failure: { response in
                EZLoadingActivity.hide(false, animated: true)
            }
        )
        EZLoadingActivity.show("", disableUI: false)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        //webView.stringByEvaluatingJavaScript(from: "window.location.href = '" + self.initialIndex + "';")
    }
    
    // observe scroll brolo
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadingComplete = true
        // TODO: revisit on large multipage documents, LOLZORS
        EZLoadingActivity.hide(true, animated: true)
        // unless the user has started interacting with things, then disregard
        // THIS WILL BE A UX ISSUE UNTIL WE GO FULL NATIVE, BUT IT'S A TRADEOFF
        //webView.stringByEvaluatingJavaScript(from: "window.location.href = '" + self.initialIndex + "';")
    }
}

