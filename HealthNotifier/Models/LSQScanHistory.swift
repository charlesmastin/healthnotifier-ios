//
//  LSQScanHistory.swift
//
//  Created by Charles Mastin on 3/10/16.
//

// this is questionably placed but it's gonna work

import Foundation
import KeychainAccess

class LSQScanHistory : NSObject {
    static let sharedInstance = LSQScanHistory()
    
    var patients: [[String:AnyObject]] = []
    var userId: String? = ""
    var timer: Timer? = nil
    
    fileprivate override init () {}
    
    // init the pruning schedule in the delegate for now, for now, for now
    func purge() -> Void {
        self.patients = []
        self.userId = ""
        if self.timer != nil {
            self.timer!.invalidate()
        }
    }
    
    func purgeKeychain() -> Void {
        // wipe it all down son, ALL THE THINGS BE GONE AND DONE FOR
        let keychain = Keychain(service: "com.healthnotifier.healthNotifier")
        let keyname: String = "healthnotifier.account-" + LSQUser.currentUser.uuid! + ".scanhistory"
        do {
            try keychain.remove(keyname)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func initializeForUser(_ userId: String) -> Void {
        self.patients = []
        self.userId = userId
        //let keyname: String = "healthnotifier.account-" + userId + ".scanhistory"
        //let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        /*
        do {
            let data = try keychain
                .getData(keyname)
            
                self.patients = NSKeyedUnarchiver.unarchiveObject(with: data!) as! [[String: AnyObject]]
                self.pruneMembership()
            
                self.timer = Timer(timeInterval: LSQ.constants.historyCleanInterval, target: self, selector: #selector(LSQScanHistory.pruneMembership), userInfo: nil, repeats: true)
                RunLoop.current.add(self.timer!, forMode: RunLoopMode.commonModes)
            
                } catch let error {
                    
            }
        }
        */
    }
    
    func persist() -> Void {
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        let keyname: String = "healthnotifier.account-" + self.userId! + ".scanhistory"
        let data = NSKeyedArchiver.archivedData(withRootObject: self.patients)
        do {
            try keychain.set(data, key: keyname)
        }
        catch let error {
            print(error)
        }
        NotificationCenter.default.post(name: LSQ.notification.hacks.patientHistoryUpdate, object: nil)
    }
    
    func pruneMembership() -> Void {
        let now: Date = Date()
        // we could do some filter and fancy crap, but no
        // TODO: locking ???
        var validPatients: [[String : AnyObject]] = []
        for (_, patient) in self.patients.enumerated() {
            // do we have a valid conforming object?
            // let's be more tolerant of crap data? no no?
            // just don't crash ok
            if let d = patient["ScanTime"] {
                if (d as! Date).addingTimeInterval(LSQ.constants.historyMaxAgeSeconds) > now {
                    validPatients.append(patient)
                    // if we were super fancy, we would remove in place by iterating in reverse or something
                } else {
                    // expired, not sure if we need to message this
                }
            } else {
                // data was malformed, we should reset everything, purge the stuffs
            }
        }
        self.patients = validPatients
        self.persist()
    }
    
    func addPatient(_ obj: [String: AnyObject]) -> Void {
        for (_, patient) in self.patients.enumerated() {
            if patient["PatientId"] as! String == obj["PatientId"] as! String {
                // TODO: update existing, so we can nudge the scan time
                // patient["ScanTime"] = obj["ScanTime"] as! NSDate
                // self.persist()
                return
            }
        }
        self.patients.append(obj)
        self.pruneMembership()
    }
    
    func removePatientByIndex(_ index: Int) -> Void {
        self.patients.remove(at: index)
        self.pruneMembership()
    }
    
    func removePatientById(_ patientId: String) -> Void {
        for (index, patient) in self.patients.enumerated() {
            if patient["PatientId"] as! String == patientId {
                self.patients.remove(at: index)
                self.pruneMembership()
                return
            }
        }
    }
}

// https://gist.github.com/pyrtsa/ae251cd74cd6d095a2b1
// MARK: Comparable instance for NSDate
public func <(a: Date, b: Date) -> Bool {
    return a.compare(b) == .orderedAscending
}

public func ==(a: Date, b: Date) -> Bool {
    return a.compare(b) == .orderedSame
}
// gone for swift3 though
// extension Date : Comparable {}
