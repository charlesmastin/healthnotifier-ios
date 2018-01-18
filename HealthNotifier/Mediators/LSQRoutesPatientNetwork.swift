//
//  LSQRoutesPatientNetwork.swift
//
//  Created by Charles Mastin on 9/8/17.
//

import Foundation
import UIKit


class LSQRoutesPatientNetwork : LSQRouter {
    
    override func addObservers(){
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.patientNetwork,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPatientNetwork
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.show.patientNetworkSearch,
                object: nil,
                queue: OperationQueue.main,
                using: self.showPatientNetworkSearch
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.answerConnectionRequest,
                object: nil,
                queue: OperationQueue.main,
                using: self.actionAnswerConnectionRequest
            )
        )
        
        self.observationQueue.append(
            NotificationCenter.default.addObserver(
                forName: LSQ.notification.action.manageConnection,
                object: nil,
                queue: OperationQueue.main,
                using: self.actionManageConnection
            )
        )
        
        
    }
    
    func showPatientNetwork(notification: Notification) {
        // consider this is literally the only area of the app that's blablabl real-time ish
        // LOL we may have a payload of sorts for all the previously loaded network, if so, pass in so we can skip asking again
        // needs loading of data
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQNetworkCollectionViewController = sb.instantiateViewController(withIdentifier: "NetworkCollectionViewController") as! LSQNetworkCollectionViewController
        vc.mode = (notification.userInfo!["mode"] as? String)!
        vc.patientId = LSQPatientManager.sharedInstance.uuid!
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            vc.loadData()
        }
    }
    
    func showPatientNetworkSearch(notification: Notification) {
        let sb:UIStoryboard = UIStoryboard(name:"Profile", bundle:nil)
        let vc:LSQNetworkSearchResultsViewController = sb.instantiateViewController(withIdentifier: "NetworkSearchResultsViewController") as! LSQNetworkSearchResultsViewController
        vc.mode = (notification.userInfo!["mode"] as? String)!
        vc.patientId = LSQPatientManager.sharedInstance.uuid!
        let pvc: UIViewController = notification.object as! UIViewController
        // XXX: this is using the fancy extension from SO, the block is the completion callback
        pvc.navigationController?.pushViewController(vc, animated: true) {
            //vc.loadData()
        }
    }
    
    func actionAnswerConnectionRequest(notification: Notification) {
        // this is quick n dirty one level, no confirmation
        let vc: UIViewController = notification.object as! UIViewController
        
        var title = "Allow \((notification.userInfo!["auditor_name"] as? String)!) to access your LifeSticker at privacy level:"
        let is_provider = (notification.userInfo!["is_provider"] as? Bool)!
        if is_provider {
            title = "Allow \((notification.userInfo!["auditor_name"] as? String)!) (a registered health care provider) to access your LifeSticker at privacy level:"
        }
        
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        let alert: UIAlertController = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: preferredStyle)
        
        if !is_provider {
            let publicAction: UIAlertAction = UIAlertAction(title: "HealthNotifier Network", style: UIAlertActionStyle.default, handler: { action in
                LSQAPI.sharedInstance.patientNetworkAccept(
                    (notification.userInfo!["granter_uuid"] as? String)!,
                    granter_id: (notification.userInfo!["granter_uuid"] as? String)!,
                    auditor_id: (notification.userInfo!["auditor_uuid"] as? String)!,
                    privacy: "public"
                )
            })
            alert.addAction(publicAction)
        }
        
        
        let providerAction: UIAlertAction = UIAlertAction(title: "Authorized Viewer", style: UIAlertActionStyle.default, handler: { action in
            LSQAPI.sharedInstance.patientNetworkAccept(
                (notification.userInfo!["granter_uuid"] as? String)!,
                granter_id: (notification.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification.userInfo!["auditor_uuid"] as? String)!,
                privacy: "provider"
            )
        })
        alert.addAction(providerAction)
        
        let privateAction: UIAlertAction = UIAlertAction(title: "Private", style: UIAlertActionStyle.default, handler: { action in
            // TODO: double secret, where is the confirmation opt-in on a potentially dangerous op
            LSQAPI.sharedInstance.patientNetworkAccept(
                (notification.userInfo!["granter_uuid"] as? String)!,
                granter_id: (notification.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification.userInfo!["auditor_uuid"] as? String)!,
                privacy: "private"
            )
        })
        alert.addAction(privateAction)
        
        let removeAction: UIAlertAction = UIAlertAction(title: "Decline Request", style: UIAlertActionStyle.destructive, handler: { action in
            // TODO: double secret, where is the confirmation opt-in on a potentially dangerous op
            LSQAPI.sharedInstance.patientNetworkDecline(
                (notification.userInfo!["granter_uuid"] as? String)!,
                granter_id: (notification.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification.userInfo!["auditor_uuid"] as? String)!
            )
        })
        alert.addAction(removeAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            // nothing here
        })
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    // this is 99% duplicate currently of answer request, just a different network endpoint, which should be abstracted anyhow
    func actionManageConnection(notification: Notification) {
        // this is quick n dirty one level, no confirmation
        let vc: UIViewController = notification.object as! UIViewController
        
        var title = "Allow \((notification.userInfo!["auditor_name"] as? String)!) to access your LifeSticker at privacy level:"
        let is_provider: Bool = (notification.userInfo!["is_provider"] as? Bool)!
        if is_provider {
            title = "Allow \((notification.userInfo!["auditor_name"] as? String)!) (a registered health care provider) to access your LifeSticker at privacy level:"
        }
        
        var preferredStyle: UIAlertControllerStyle = UIAlertControllerStyle.alert
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            preferredStyle = UIAlertControllerStyle.actionSheet
        }
        let alert: UIAlertController = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: preferredStyle)
        
        
        if !is_provider {
            let publicAction: UIAlertAction = UIAlertAction(title: "HealthNotifier Network", style: UIAlertActionStyle.default, handler: { action in
                LSQAPI.sharedInstance.patientNetworkUpdate(
                    (notification.userInfo!["granter_uuid"] as? String)!,
                    granter_id: (notification.userInfo!["granter_uuid"] as? String)!,
                    auditor_id: (notification.userInfo!["auditor_uuid"] as? String)!,
                    privacy: "public"
                )
            })
            alert.addAction(publicAction)
        }
        
        
        let providerAction: UIAlertAction = UIAlertAction(title: "Authorized Viewers", style: UIAlertActionStyle.default, handler: { action in
            LSQAPI.sharedInstance.patientNetworkUpdate(
                (notification.userInfo!["granter_uuid"] as? String)!,
                granter_id: (notification.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification.userInfo!["auditor_uuid"] as? String)!,
                privacy: "provider"
            )
        })
        alert.addAction(providerAction)
        
        let privateAction: UIAlertAction = UIAlertAction(title: "Private", style: UIAlertActionStyle.default, handler: { action in
            // TODO: double secret, where is the confirmation opt-in on a potentially dangerous op
            LSQAPI.sharedInstance.patientNetworkUpdate(
                (notification.userInfo!["granter_uuid"] as? String)!,
                granter_id: (notification.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification.userInfo!["auditor_uuid"] as? String)!,
                privacy: "private"
            )
        })
        alert.addAction(privateAction)
        
        let removeAction: UIAlertAction = UIAlertAction(title: "Remove Connection", style: UIAlertActionStyle.destructive, handler: { action in
            // TODO: double secret, where is the confirmation opt-in on a potentially dangerous op
            LSQAPI.sharedInstance.patientNetworkRevoke(
                (notification.userInfo!["granter_uuid"] as? String)!,
                granter_id: (notification.userInfo!["granter_uuid"] as? String)!,
                auditor_id: (notification.userInfo!["auditor_uuid"] as? String)!
            )
        })
        alert.addAction(removeAction)
        
        let cancelAction: UIAlertAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            // nothing here
        })
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    
}
