//
//  LSQDurationTimer.swift
//
//  Created by Charles Mastin on 3/18/16.
//  http://stackoverflow.com/questions/24755558/measure-elapsed-time-in-swift

import Foundation
import CoreFoundation

class LSQDurationTimer {
    
    let startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> Double {
        endTime = CFAbsoluteTimeGetCurrent()
        return duration!
    }
    
    // analytics side should be able to deal with this easily
    var duration:Double? {
        if let endTime = endTime {
            // we're not measuring milliseconds anymore, but ok
            return round(endTime - startTime)
        } else {
            return nil
        }
    }
    
    var durationSeconds:Int? {
        if let endTime = endTime {
        // we're not measuring milliseconds anymore, but ok
        return Int(round(endTime - startTime))
        } else {
            return nil
        }
    }
}