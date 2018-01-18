//
//  LSQOnboardingManager.swift
//
//  Created by Charles Mastin on 8/2/17.
//

import Foundation

class LSQOnboardingManager {
    static let sharedInstance = LSQOnboardingManager()
    
    // all the state bro bas
    // basically lots of public vas vs an API for my classes, bla
    // presumably there is some aspect of the token and whatnot meh meh
    var active: Bool = false
    var promoCode: String? // must be validated
    var claimedLifesquare: String? // must be validated
    var amountDue: Int = 1000000 // aka a default whatever, basically if this is not 0 then someone owes something, but it's here so we can do simple math.min
    
    // scratch from the account screen, mainly our password so we can enable touchID without asking again
    // store only in memory, but also encrypted?? meh no!
    // var dataAccount: AnyObject? // this should never need to be persisted
    //
    // var dataProfile: AnyObject? // maybe just for storing license capture, depends on supported navigation flow, etc
    // var dataPhoto: AnyObject? // really this will transactionally save
    // var dataContacts: transactionally saved
    // var dataMedical nope
    // other state stuffs
    
    
    // something that helps restore state
    func restoreState() {
        
    }
    
    func begin(){
        // classy method name
        self.reset()
        self.active = true
    }
    
    func clearLifesquare(){
        self.promoCode = nil
        self.claimedLifesquare = nil
        self.amountDue = 100000
    }
    
    func reset(){
        self.active = false
        self.clearLifesquare()
    }
    
    // currently navigation is handled in the individual controllers data transactions, which is best anyhow
    // we could also just comment out our top level sequencing here too, or even take it over as a sequence mediator
    
    
    
}
