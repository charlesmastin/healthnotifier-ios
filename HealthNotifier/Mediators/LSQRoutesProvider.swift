//
//  LSQRoutesProvider.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit

class LSQRoutesProvider : LSQRouter {
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.providerRegistration,
                object: nil,
                queue: OperationQueue.main,
                using: self.showProviderRegistrationScreen
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.providerRegistrationSuccess,
                object: nil,
                queue: OperationQueue.main,
                using: self.showProviderRegistrationSuccessScreen
            )
        )
        
    }
    
    func showProviderRegistrationScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:LSQProviderCredentialsViewController = sb.instantiateViewController(withIdentifier: "ProviderRegistrationViewController") as! LSQProviderCredentialsViewController
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }
        //(notification.object as! UIViewController).present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    // THIS is bogus and should not be mounted this way
    func showProviderRegistrationSuccessScreen(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Onboarding", bundle:nil)
        let vc:UIViewController = sb.instantiateViewController(withIdentifier: "ProviderRegistrationSuccessViewController")
        //
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            
        }

        
        //
    }
}
