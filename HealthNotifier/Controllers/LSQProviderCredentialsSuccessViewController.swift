//
//  LSQProviderCredentialsSuccessViewController.swift
//
//  Created by Charles Mastin on 3/7/16.
//

import Foundation
import UIKit

class LSQProviderCredentialsSuccessViewController: UIViewController {
    
    private var backButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.navigationController?.navigationBar.barTintColor = LSQ.appearance.color.newTeal
        //self.view.backgroundColor = LSQ.appearance.color.newTeal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(LSQProviderCredentialsSuccessViewController.close))
        navigationItem.leftBarButtonItem = backButton
        backButton.isEnabled = false
    }
    
    @IBAction func backToAccount(_ sender: AnyObject?) {
        // TODO: instead send a generic dismiss modal business SON, since all of "level 1 modals" should be in the same spot
        // This is also amusing because we have no "resume" on maintabcontroller, w/e
        self.close()
    }
    
    internal func close(){
        self.dismissMe(animated: true, completion: nil)
    }
    
}
