//
//  LSQTouchAuthManager.swift
//
//  Created by Charles Mastin on 5/26/17.
//

import Foundation
import RNCryptor
import LocalAuthentication
import KeychainAccess

class LSQTouchAuthManager {
    
    static let sharedInstance = LSQTouchAuthManager()
    // we need to consider accessing the encrypted data
    // I guess we have to persist the key as well, as per the OG architecture
    
    // TODO: handle password change and deal with this
    func getSigningKey() -> String {
        return "todo-stronger-healthnotifier-phrase-available-without-jwt"
    }
    
    func touchIdAvailable() -> Bool {
        var policy: LAPolicy?
        if #available(iOS 9.0, *) {
            policy = .deviceOwnerAuthentication
        }
        let context = LAContext()
        var err: NSError?
        guard context.canEvaluatePolicy(policy!, error: &err) else {
            return false
        }
        return true
    }
    
    func requestPasswordAsync() -> Void {
        DispatchQueue.global().async {
            
            do {
                let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
                let uuid: String = LSQUser.currentUser.getSavedUuid()
                let keyname: String = "healthnotifier.account-" + uuid + ".password"
                
                let password = try keychain
                    .authenticationPrompt("Please enter your fingerprint to login.")
                    .getData(keyname)
                //
                // do the decryption
                //
                var passphrase:String = ""
                let originalData = try RNCryptor.decrypt(data:password!, withPassword: LSQTouchAuthManager.sharedInstance.getSigningKey())
                // WTF SON can we make it more labor intensive to decode a string?
                passphrase = String(data: originalData as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: LSQ.notification.auth.passwordRetrieved,
                        object: nil,
                        userInfo: [
                            "password": passphrase
                        ]
                    )
                }
                
                
            } catch let error {
                print(error)
                // jump back to main
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: LSQ.notification.auth.passwordRetrievalError,
                        object: nil
                    )
                }
            }
        }
    }
    
    func persistPassword(password: String) -> Void {
        
        
        
        DispatchQueue.global().async {
            do {
                let data: Data = password.data(using: .utf8)!
                // TODO: a better signing key lolzin
                let encrypted = RNCryptor.encrypt(data:data, withPassword: LSQTouchAuthManager.sharedInstance.getSigningKey())
                let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
                let uuid: String = LSQUser.currentUser.getSavedUuid()
                let keyname: String = "healthnotifier.account-" + uuid + ".password"
                // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .authenticationPrompt("Authenticate to save your encrypted credentials")
                    .set(encrypted, key: keyname)
                
                LSQTouchAuthManager.sharedInstance.enable()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: LSQ.notification.action.touchSetupComplete,
                        object: nil
                    )
                }
                
                // positive blablabla
                
            } catch let error {
                // Error handling if needed...
                // user cancelled
                print(error)
            }
        }
    }
    
    func enable() -> Void {
        // user requests enablement, this is probably not necessary here
        // is this a uniform flow? is this better served from the navigation mediator though?, probably
        
        // set user state of feature, only if we success etc
        //user's JWT token obtained after login
        LSQUser.currentUser.prefs.touchIdEnabled = true
        LSQUser.currentUser.persistPrefs()
        
    }
    
    func disable() -> Void {
        // user invoked maybe? or non-relevant
        // discard keychains if possible…
        // change state in NSUserDefaults / General User Keychain on User Model???
        LSQUser.currentUser.prefs.touchIdEnabled = false
        LSQUser.currentUser.persistPrefs()
    }
    
    func recycleToken() -> Void {
        // an attempt to generically recycle things
    }
    
    func purgeKeychain() -> Void {
        // wipe it all down son, ALL THE THINGS BE GONE AND DONE FOR
        let keychain = Keychain(service: "com.healthnotifier.HealthNotifier")
        let keyname: String = "healthnotifier.account-" + LSQUser.currentUser.uuid! + ".password"
        do {
            try keychain.remove(keyname)
        } catch let error {
            print("error: \(error)")
        }
    }

}
