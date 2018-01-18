//
//  LSQLocationManager.swift
//
//  Created by Charles Mastin on 3/19/16.
//

import Foundation
import CoreLocation
import UIKit

class LSQLocationManager : NSObject, CLLocationManagerDelegate {
    static let sharedInstance = LSQLocationManager()
    
    var lm: CLLocationManager? = nil
    var lastLocation: CLLocation? = nil
    var minimumMovementDistance: Int = 50

    func initLocationManager() {
        if self.lm == nil {
            self.lm = CLLocationManager()
            self.lm!.delegate = self
            self.lm!.pausesLocationUpdatesAutomatically = true
            self.lm!.activityType = CLActivityType.other // THIS IS TEMPORARY
            self.lm!.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyNearestTenMeters // scale this back in general, based on account type and org settings
            self.lm!.distanceFilter = 50 //meters //kCLDistanceFilterNone // Per org settings per intended use case, basically tracking human or auto
            self.lm!.requestWhenInUseAuthorization()
        }
    }
    
    func start() {
        self.initLocationManager()
        // unsure if this hurts to repeatedly call this
        self.lm!.startUpdatingLocation()
        NotificationCenter.default.post(name: LSQ.notification.location.start, object: self)
    }
    
    func stop() {
        if self.lm != nil {
            self.lm!.stopUpdatingLocation()
            self.lm = nil
            /*
            let user = LSQUser.currentUser
            if user.isHealthNotifierEmployee() && user.backgroundLocation {
                // do nothing aka, leave it running
            } else {
            }
            */
        }
        NotificationCenter.default.post(name: LSQ.notification.location.stop, object: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.lastLocation == nil || ( Int(self.lastLocation!.distance(from: locations[0])) > self.minimumMovementDistance) {
            self.lastLocation = locations[0]
            NotificationCenter.default.post(
                name: LSQ.notification.location.update,
                object: self,
                userInfo:["location": self.lastLocation!]
            )
            /*
            let user = LSQUser.currentUser
            if user.locationTracking {
                LSQAPI.sharedInstance.updateLocation(
                    (self.lastLocation?.coordinate.latitude)!,
                    longitude: (self.lastLocation?.coordinate.longitude)!,
                    success: { response in
                    },
                    failure: { response in
                    }
                )
            }
            */
        }
    }
    
}
