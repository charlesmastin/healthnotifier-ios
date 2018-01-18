//
//  Utils.swift
//
//  Created by Charles Mastin on 11/1/16.
//

import Foundation
import UIKit

// http://peatiscoding.me/geek-stuff/javascript-settimeout-in-swift-2-0/
// Basic.swift
func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
}

func setInterval(_ interval:TimeInterval, block:@escaping ()->Void) -> Timer {
    return Timer.scheduledTimer(timeInterval: interval, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: true)
}

/*
 // Simple usage
 let handle = setTimeout(0.35, block: { () -> Void in
 // do this stuff after 0.35 seconds
 })
 
 // Later on cancel it
 handle.invalidate()
 */
func getCurrentViewController(_ vc: UIViewController) -> UIViewController? {
    // oh stack overflow, http://stackoverflow.com/questions/24825123/get-the-current-view-controller-from-the-app-delegate
    if let pvc = vc.presentedViewController {
        return getCurrentViewController(pvc)
    }
    if let svc = vc as? UISplitViewController {
        if svc.viewControllers.count > 0 {
            return getCurrentViewController(svc.viewControllers.last!)
        }
    }
    if let nc = vc as? UINavigationController {
        if nc.viewControllers.count > 0 {
            return getCurrentViewController(nc.topViewController!)
        }
    }
    else if let tbc = vc as? UITabBarController {
        if let svc = tbc.selectedViewController {
            return getCurrentViewController(svc)
        }
    }
    return vc
}
