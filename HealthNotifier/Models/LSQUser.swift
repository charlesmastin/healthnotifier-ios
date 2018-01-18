//
//  LSQUser.swift
//
//  Created by Charles Mastin on 12/1/16.
//

import Foundation
import SwiftyJSON
import JWTDecode
import KeychainAccess

class LSQUser {
    static let currentUser = LSQUser()
    
    static let keyForToken: String = "healthnotifier.account.token"
    static let keyForUuid: String = "healthnotifier.account.uuid"
    
    // in memory bro, set to true upon first sync
    var loaded: Bool = false
    
    // this is PHI, so it ALL must go into the Keychain son, we can keep these attributes in memory only
    // var json: JSON? = nil
    var uuid: String? = nil
    var email: String = ""
    var phone: String? = nil // IS NIL ON THE SERVER if empty w/e son
    var provider: Bool = false
    var providerCredentialStatus: String? = nil
    
    var patientsCount: Int = 0
    
    // 
    var deviceToken: String? = nil
    
    // stored as it's own thing
    var accessToken: String? = nil
    
    var prefs: LSQUserPrefs = LSQUserPrefs()
    
    func restorePrefs() -> Void {
        // attempts to restore, or inits a default
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        // meh meh, just get it, but don't umm persist it specifically
        // must also be fault tolerant, aka, if the keychain data does not exist, then kick off a query
        if uuid == nil {
            uuid = getSavedUuid()
        }
        if uuid != nil {
            
            let keyname: String = "healthnotifier.account-" + uuid! + ".prefs"
            let j = try! keychain.get(keyname)
            if j != nil {
                let json = JSON.init(parseJSON: j!)
                // OH BOY SON, this is out of site, out of mind, 
                // NEVER SHOW THIS EVER
                if let b1 = json["touchIdEnabled"].bool {
                    self.prefs.touchIdEnabled = b1
                }
                if let b2 = json["pushEnabled"].bool {
                    self.prefs.pushEnabled = b2
                }
                if let b3 = json["rejectedPushPrettyPlease"].bool {
                    self.prefs.rejectedPushPrettyPlease = b3
                }
                if let b4 = json["rejectedPush"].bool {
                    self.prefs.rejectedPush = b4
                }
            }
            
        }
    }
    
    func persistPrefs() -> Void {
        // yup, that one
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        let keyname: String = "healthnotifier.account-" + uuid! + ".prefs"
        do {
            //let pData = NSKeyedArchiver.archivedData(withRootObject: self.prefs)
            //let pData = NSKeyedArchiver.archivedData(withRootObject: self.prefs)
            try keychain.set(self.prefs.toJSON()!, key: keyname)
        }
        catch let error {
            print(error)
        }
    }
    
    
    func restoreAccessToken() -> Bool {
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        let token = try! keychain.get(LSQUser.keyForToken)
        if token != nil {
            return propagateToken(token: token!)
        }
        return false
    }
    
    func getSavedUuid() -> String {
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        let uuid = try! keychain.get(LSQUser.keyForUuid)
        if uuid != nil {
            return uuid!
        }
        return ""
    }
    
    func getSavedJson() -> JSON {
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        // meh meh, just get it, but don't umm persist it specifically
        // must also be fault tolerant, aka, if the keychain data does not exist, then kick off a query
        if uuid == nil {
            uuid = getSavedUuid()
        }
        if uuid != nil {
            // guard against uuid being nil this is terrible swift and all that
            let keyname: String = "healthnotifier.account-" + uuid! + ".json"
            let j = try! keychain.get(keyname)
            if j != nil {
                let json = JSON.init(parseJSON: j!)
                return json
            }
        }
        return JSON.null
    }
    
    func restoreUserJson(refresh: Bool = false){
        let json:JSON = getSavedJson()
        // meh, meh meh meh
        self.restorePrefs()
        //
        if json != JSON.null {
            self.mapAttributes(json: json)
            if refresh {
                self.fetch()
            }
        } else {
            if refresh {
                self.fetch()
            }
        }
        
    }
    
    func processAccessToken(response: AnyObject) -> Bool {
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        // TODO: make this entire process atomic though
        let rJ:JSON = JSON(response)
        let token:String = rJ["access_token"].string!
        do {
            try keychain.set(token, key: LSQUser.keyForToken)
            return propagateToken(token: token)
        }
        catch let error {
            print(error)
        }
        return false
    }
    
    internal func propagateToken(token: String) -> Bool {
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        let jwt = try? decode(jwt: token)
        // is the token valid locally
        if (jwt != nil) {
            if jwt!.expired {
                print("EXPIRED TOKEN LOCALLY")
                return false
            } else {
                LSQAPI.sharedInstance.setToken(token: token)
                accessToken = token
                let claim = jwt?.claim(name: "lifesquare_account_uuid")
                if let account_uuid = claim?.string {
                    uuid = account_uuid
                    do {
                        try keychain.set(uuid!, key: LSQUser.keyForUuid)
                        // THIS DOESN"T MEAN ANYTHING THOUGH
                        //
                        return true
                    }
                    catch let error {
                        print(error)
                    }
                }

            }
        }
        
        // if not
        
                // I mean, meh meh, technically we shouldn't need this
        return false
    }
    
    func isLoggedIn() -> Bool {
        // TODO: robustify this a whole lot!
        // TODO: use class variable that is only ever set in the return handlers of auth based responses… meh so annoying
        if self.accessToken != nil {
            return true
        }
        return false
    }
    
    func initWithData(_ data: AnyObject) -> Void {
        // convert to JSON
        let json = JSON(data)
        // map to instance attributes
        self.mapAttributes(json: json)
        // persist a few things for kicks, mainly a string of the json, yolo
        self.persist(json: json)
        
        if let pc = json["PatientsCount"].int {
            // blablabla
            self.patientsCount = pc
        }
        
    }
    
    func persist(json: JSON) -> Void {
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        var j: JSON = json
        // strip stuff we know is legacy, this is so wrong btw
        if j["AuthToken"].exists() {
            j.dictionaryObject?.removeValue(forKey: "AuthToken")
        }
        //
        let keyname: String = "healthnotifier.account-" + uuid! + ".json"
        do {
            try keychain.set(j.rawString()!, key: keyname)
            
        }
        catch let error {
            print(error)
        }
    }
    
    func isHealthNotifierEmployee() -> Bool {
        if self.email.contains("domain.com"){
            return true
        }
        return false
    }
    
    func mapAttributes(json: JSON) -> Void {
        // this is done from the JWT
        // self.uuid = self.json!["AccountId"].string!
        if let email = json["Email"].string {
            self.email = email
        }
        
        // temp hack for background location though
        // TODO: hook the actual local persistence
        // user the permissions too, but that is more downstream
        /*
        if(self.isHealthNotifierEmployee()){
            self.locationTracking = true
            self.backgroundLocation = true
        } else {
            self.locationTracking = false
            self.backgroundLocation = false
        }
        */
        if let provider = json["Provider"].bool {
            self.provider = provider
        }
        if let pcs = json["ProviderCredentialStatus"].string {
            self.providerCredentialStatus = pcs
        }
        if let p = json["MobilePhone"].string {
            self.phone = p
        }
        
        //
        if let pushEnabled = json["PushEnabled"].bool {
            // the server could have fallen out of sync, any number of things, we could have wiped our end points, etc
            if pushEnabled {
                self.prefs.pushEnabled = true
            } else {
                self.prefs.pushEnabled = false
            }
            // don't think we need yet another cycle of persistence, endless loop edition
        }
    }
    
    func purgeKeychain() -> Void {
        // wipe it all down son, ALL THE THINGS BE GONE AND DONE FOR
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        var keyname: String = "healthnotifier.account-" + self.uuid! + ".prefs"
        do {
            try keychain.remove(keyname)
        } catch let error {
            print("error: \(error)")
        }
        keyname = LSQUser.keyForUuid
        do {
            try keychain.remove(keyname)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func destroy() -> Void {
        print("TRASHING ALL THE THINGS, likely cause of this debocle")
        self.loaded = false
        self.uuid = nil
        self.email = ""
        self.phone = nil
        self.provider = false
        self.providerCredentialStatus = nil
        self.accessToken = nil
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        // KeyChain wipedown
        do {
            try keychain.remove(LSQUser.keyForToken)
        } catch let error {
            print("error: \(error)")
        }
        /*
        do {
            try keychain.remove(LSQUser.keyForUuid)
        } catch let error {
            print("error: \(error)")
        }
        */
        /*
        do {
            try keychain.remove(keyname)
        } catch let error {
            print("error: \(error)")
        }
        */
        // but do not wipe the last uuid? or not I dunno blabla
        // no wiping of prefs, as those are deep stored though son
    }
    
    func fetch() -> Void {
        
        if self.uuid != nil {
            LSQAPI.sharedInstance.getAccount(
                self.uuid!,
                success: { response in
                    
                    self.initWithData(response)
                    
                    // CATCH OUR FIRST SYNC INTROSPECTION OPPORTUITIES NOW
                    // TODO: move this higher up into something
                    if !self.loaded {
                        // check our state
                        
                        // do we have patients
                        let vc: UIViewController = ((UIApplication.shared.delegate as! LSQAppDelegate).window?.rootViewController)!
                        if self.patientsCount == 0 {
                            // highly crash prone
                            
                            // there is nothing except showing the create patient screen at this point
                            // we need to obtain a VC to reference though, this is sketchy as hell in this callback though
                            NotificationCenter.default.post(
                                name: LSQ.notification.show.onboardingProfile,
                                object: vc // TODO: get a current root VC???
                            )
                        }
                        if self.patientsCount == 1 {
                            // print… meh
                            
                            // check onboarding status though brolo, which is higher up
                            
                            NotificationCenter.default.post(
                                name: LSQ.notification.show.tabController,
                                object: vc // TODO: get a current root VC???
                            )
                        }
                        if self.patientsCount > 1 {
                            NotificationCenter.default.post(
                                name: LSQ.notification.show.tabController,
                                object: vc // TODO: get a current root VC???
                            )
                        }
                        
                        // how many, might need to slap into onboarding, but down the chain bro
                        
                        // else slap into onboarding
                        
                        // now set it
                        self.loaded = true
                    }
                    /*
                    // message for the nav mediator to configure tab bar bro bras
                    NotificationCenter.default.post(
                        name: LSQ.notification.hacks.configureTabs,
                        object: self
                    )
                     */
                    //
                    // ghetto bootstrap to do the badgemanger fetch though
                    LSQBadgeManager.sharedInstance.removeObservers()
                    LSQBadgeManager.sharedInstance.addObservers()
                    LSQBadgeManager.sharedInstance.sync()
                    //
                },
                failure: { response in
                    // alert perhaps
                }
            )
        }
    }
    
    
    
}
