//
//  LSQ.swift
//
//  Created by Charles Mastin on 3/3/16.
//

import Foundation
import UIKit
import CoreLocation
import AVFoundation
import Photos
import EZLoadingActivity

// this won't work for objc but we only have like a few cases where we call from objc, so anyhow
struct LSQ {
    // name space the hotness
    struct notification {
        // for view controllers
        struct show {
            static let login = Notification.Name("show.login")
            static let forgotPassword = Notification.Name("show.forgot-password")
            static let passwordSent = Notification.Name("show.forgot-password-success")
            static let unlockSent = Notification.Name("show.forgot-password-success-unlock")
            static let completeRecovery = Notification.Name("show.complete-recovery") // aka CHOOSE PASSWORD - but not the same as in the account VC
            
            static let enablePush = Notification.Name("show.enable-push")
            
            static let providerRegistration = Notification.Name("show.onboarding.providerregistration")
            static let providerRegistrationSuccess = Notification.Name("show.onboarding.providerregistrationsuccess")
            //static let credentials = Notification.Name("show.credentials") // provider signup form
            //static let credentialsSuccess = Notification.Name("show.credentials-success")
            
            
            static let captureLifesquareCode = Notification.Name("show.capture-lifesquare-code")
            
            // onboarding 2.0
            static let welcome = Notification.Name("show.welcome")
            // wrap in da slidy bits doe
            static let onboardingAccount = Notification.Name("show.onboarding.account")
            static let onboardingLicense = Notification.Name("show.onboarding.license")
            static let onboardingProfile = Notification.Name("show.onboarding.profile")
            static let onboardingPhoto = Notification.Name("show.onboarding.Photo")
            static let onboardingScanLifesquare = Notification.Name("show.onboarding.scanlifesquare")
            static let onboardingContacts = Notification.Name("show.onboarding.contacts")
            static let onboardingInsurance = Notification.Name("show.onboarding.insurance")
            static let onboardingMedical = Notification.Name("show.onboarding.medical")
            static let onboardingPromo = Notification.Name("show.onboarding.promo")
            static let onboardingConfirm = Notification.Name("show.onboarding.confirm")
            static let onboardingSuccess = Notification.Name("show.onboarding.success")
            
            // gateway
            
            
            // these are the external handlers
            static let lifesquare = Notification.Name("show.lifesquare") // use userInfo to determine the kinds of things son
            static let profile = Notification.Name("show.profile") // this is for when we own something ONLY coming from our Accounts view
            // internal would be in theory method calls based on callbacks with????
            // because we need to load things in multiple calling contexts for these specifically??
            
            
            
            // detail edit views - passes patient json as .object
            static let profileEditPersonal = Notification.Name("show.profile-edit-personal")
            static let profileEditMedical = Notification.Name("show.profile-edit-medical")
            static let profileEditContacts = Notification.Name("show.profile-edit-contacts")
            static let profileEditEmergency = Notification.Name("show.profile-edit-emergency")
            
            static let profileConfirm = Notification.Name("show.profile-confirm")
            
            //
            static let document = Notification.Name("show.document")
            static let documentForm = Notification.Name("show.document-form")
            
            static let pickerGallery = Notification.Name("show.picker-gallery")
            static let pickerCamera = Notification.Name("show.picker-camera")
            //
            static let messageContacts = Notification.Name("show.message-contacts")
            //
            static let careplanIndex = Notification.Name("show.careplan-index")
            static let careplanPlan = Notification.Name("show.careplan-plan")
            static let careplanQuestionGroup = Notification.Name("show.careplan-question-group")
            static let careplanRecommendation = Notification.Name("show.careplan-recommendation")
            // patient fragments - view mode son for now
            // we could use a single action and switch inside the notification handler via the "type", that would require less wiring,
            // probably better since there is nothing unique about each drill in
            static let patientFragment = Notification.Name("show.patient.fragment")
            static let patientPhoto = Notification.Name("show.patient.photo")
            
            static let collectionItemForm = Notification.Name("show.collection-item.form") // this is for both add and edit mode, since we just have extra userInfo for the object
            static let formSelect = Notification.Name("show.form-select")
            static let formAutocomplete = Notification.Name("show.form-autocomplete")
            static let formDatePicker = Notification.Name("show.form-datepicker")
            static let formHeightPicker = Notification.Name("show.form-heightpicker")
            
            static let editAccount = Notification.Name("show.edit-account")
            static let changePassword = Notification.Name("show.change-password")
            
            static let scanImport = Notification.Name("show.scan-import")
            
            static let checkout = Notification.Name("show.checkout") // 1 stop for now
            static let checkoutSuccess = Notification.Name("show.checkout.success")
            
            // patient network
            
            static let patientNetwork = Notification.Name("show.patient-network")
            static let patientNetworkSearch = Notification.Name("show.patient-network-search")
            static let patientNetworkSearchResult = Notification.Name("show.patient-network-search-result") // may not be used
            static let patientNetworkConnection = Notification.Name("show.patient-network-connection") // may not be used
            
            static let scanCodeEntry = Notification.Name("show.scan-code-entry")
            
            // POP stacks, and set tab index yea son
            // for now, let's keep them unique and context laden until we dismantle that construct
            static let tabController = Notification.Name("show.tab-controller")
            static let tabPatients = Notification.Name("show.tab-patients")
            static let tabScan = Notification.Name("show.tab-scan")
            static let tabSearch = Notification.Name("show.tab-search")
            static let tabHistory = Notification.Name("show.tab-history")
            static let tabAccount = Notification.Name("show.tab-account")
            
            //
            static let terms = Notification.Name("show.terms") // general terms
            static let privacy = Notification.Name("show.privacy") // general privacy
            static let termsTouch = Notification.Name("show.terms.touch") // general touch terms son, modal only ever, meh
            
            static let goodbye = Notification.Name("show.goodbye")
        }
        
        // for view controllers, typically only needed for modals or out of sideband (onboarding) screens
        struct dismiss {
            // useful for a hack to reset checkout view state
            static let captureLifesquareCode = Notification.Name("dismiss.capture-lifesquare-code")
            static let scanImport = Notification.Name("dismiss.scan-import")
            /*
            // root view controllers
            static let login = Notification.Name("dismiss.login") // this is highly ambiguous
            static let registration = Notification.Name("dismiss.registration")
            // no need for dismiss enable push, or registration success
            
            // modally presented things
            static let document = Notification.Name("dismiss.document")
            static let messageContacts = Notification.Name("dismiss.message-contacts")
            
            static let credentials = Notification.Name("dismiss.credentials") // this is ambiguous given the multiple contexts
            static let credentialsSuccess = Notification.Name("dismiss.credentials-success")
            
            static let patientFragment = Notification.Name("dismiss.patient.fragment") // catch all for all drill-ins
            static let patientPhoto = Notification.Name("dismiss.patient.photo")
            
            static let onboardingPatient = Notification.Name("dismiss.onboarding.patient") // generic bounce son
            
            
            
            
            */
        }
        
        // for alerts n such, probably should call this alert w/e
        // user actions ONLY
        struct action {
            static let logout = Notification.Name("action.logout")
            static let addDocument = Notification.Name("action.add-document")
            static let deleteDocument = Notification.Name("action.delete-document")
            static let deleteCredentialFile = Notification.Name("action.delete-credential-file")
            static let patientActions = Notification.Name("action.patient-actions")
            static let editPatient = Notification.Name("action.edit-patient")
            static let accountActions = Notification.Name("action.account-actions")
            static let createPatient = Notification.Name("action.create-patient")
            static let createPatientOnboarding = Notification.Name("action.create-patient-onboarding")
            static let deletePatient = Notification.Name("action.delete-patient")
            static let deleteAccount = Notification.Name("action.delete-account")
            
            // case 1
            // the intermediary step - choose capture type
            // dynamic title and message
            static let chooseCaptureMethod = Notification.Name("action.choose-capture-method")
            
            // case 2
            // do either kind directly
            static let captureImage = Notification.Name("action.capture-image") // generic setup for capturing
            // in the future - more modes of capture supported, like Drive, Dropbox, etc
            
            
            // patient network, object level
            static let requestConnection = Notification.Name("action.request-connection") // these are the initial ones, not the "doing of" aka, network transactions
            static let grantConnection = Notification.Name("action.grant-connection") // these are the initial ones, not the "doing of" aka, network transactions
            static let manageConnection = Notification.Name("action.manage-connection") // blablabl, for showing the actions for management on a network connection
            static let answerConnectionRequest = Notification.Name("action.answer-connection-request") // this is the generic one, and yes, it could be invoked from multiple places, like a langing, or the network screen
            
            // meh meh meh meh
            static let skipOnboardingStep = Notification.Name("action.skip-onboarding") // short cut so we don't have to define userinfo skip: true. bro!
            static let nextOnboardingStep = Notification.Name("action.continue-onboarding")
            static let prevOnboardingStep = Notification.Name("action.previous-onboarding") // in case we go non-traditional navigation controller UI bro, yea son!
            // legacy up in this bitch
            static let continueSetup = Notification.Name("action.continue-setup")
            
            // responding to touch terms, this is a straggler ish because it's a nav button meh, but it's coincidentarly just likt continue csetup
            // THESE ARE NOT OS PERMISSIONS, so they go here
            static let acceptTouchTerms = Notification.Name("action.accept-touch-terms")
            static let declineTouchTerms = Notification.Name("action.decline-touch-terms")
            static let acceptTerms = Notification.Name("action.accept-terms")
            static let declineTerms = Notification.Name("action.decline-terms")
            //
            static let touchSetupComplete = Notification.Name("action.touch-setup-complete")
        }
        
        struct permissions {
            struct request {
                static let camera = Notification.Name("action.permission.request.camera")
                static let photos = Notification.Name("action.permission.request.photos")
                static let location = Notification.Name("action.permission.request.location")
                static let notificationsPrettyPlease = Notification.Name("action.permission.request.notifications-please") // pre-request
                static let notifications = Notification.Name("action.permission.request.notifications")
            }
            struct authorize {
                static let camera = Notification.Name("action.permission.authorize.camera")
                static let photos = Notification.Name("action.permission.authorize.photos")
                static let location = Notification.Name("action.permission.authorize.location")
                static let notifications = Notification.Name("action.permission.authorize.notifications")
                // not needed for pretty please, because that ALWAYS continues to ask the system dialog
            }
            struct deny {
                static let camera = Notification.Name("action.permission.deny.camera")
                static let photos = Notification.Name("action.permission.deny.photos")
                static let location = Notification.Name("action.permission.deny.location")
                static let notificationsPrettyPlease = Notification.Name("action.permission.deny.notifications-please") // pre-request
                static let notifications = Notification.Name("action.permission.deny.notifications")
            }
        }
        
        struct auth {
            // success / failure, whatever, splitting hairs, these are rough client side representations
            static let authorize = Notification.Name("auth.authorize")
            static let authorized = Notification.Name("auth.authorized")
            static let deauthorize = Notification.Name("auth.deauthorize")
            static let unauthorized = Notification.Name("auth.unauthorized") // ALL 401's from the server, exception of on login VC
            // this describes the state, but it itself is not an action or indicitive of a user action, just the lack of authorizaion
            // static let deauthorized = Notification.Name("auth.deauthorized") // this is Server invoked, token failure etc
            static let passwordRetrieved = Notification.Name("auth.password.retrieved")
            static let passwordRetrievalError = Notification.Name("auth.password.cancel-or-fail")
        }
        
        // jimmy hack level 2.0
        struct network {
            
            // success
            static let success = Notification.Name("network.success")
            // error
            static let error = Notification.Name("network.error")
            
            /*
            // this begs the question why we don't have a more predictable setup
            static let patient = "saved.patient" // the whoel schebang
            static let profile = "saved.profile"
            static let collection = "saved.collection"
            */
        }
        
        struct form {
            static let change = Notification.Name("form.change")
            struct field {
                static let change = Notification.Name("form.field.change")
            }
        }
                
        // for model updates, lul
        struct loaded {
            // hack inline replacement to not disrupt the stuffs
            static let patient3 = Notification.Name("loaded.patient.hacknsleep")
            static let patient2 = Notification.Name("loaded.patient.new")
            static let patient = Notification.Name("loaded.patient") // hack
            static let autocomplete = Notification.Name("loaded.autocomplete") // lol wut
            static let medicationDose = Notification.Name("loaded.medication.dose")
            // WHAT SON
            static let image = Notification.Name("loaded.image")
        }
        
        // for our location manager wrapper singleton
        struct location {
            static let update = Notification.Name("location.update")
            static let stop = Notification.Name("location.stop")
            static let start = Notification.Name("location.start")
        }
        
        // appropriately named so we know what we're dealing with
        struct hacks {
            // terrible, hence the namespace hacks
            static let patientIdCreated = Notification.Name("hacks.patient-id-created") // so we can not directly touch anything in the mediato
            // and slipstream our new onboarding patient id in there for the utility VC loads
            static let reloadPatients = Notification.Name("hacks.reload-patients")
            static let reloadPatient = Notification.Name("hacks.reload-patient") // TODO: replace with calls to LSQPatientManager.sharedInstance.fetch()
            static let replaceCollection = Notification.Name("hacks.replace-collection")
            // this side steps the whole storing a reference to the modal and then closing from the mediator, by
            // listening inside the vc and then calling it's close
            static let documentDeleted = Notification.Name("hacks.document-deleted")
            // some setters to pass crap between date picker windows and parent - terrrrrrrible
            static let setCredentialsExpiration = Notification.Name("hacks.set-credentials-expiration")
            static let setCredentialsState = Notification.Name("hacks.set-credentials-state")
            static let setRegistrationDob = Notification.Name("hacks.set-registration-dob")
            static let tableForceReload = Notification.Name("hacks.table-force-reload")
            
            // to support objc connection, ish
            static let deletePatientFromHistory = Notification.Name("hacks.delete-patient-from-history")
            static let addPatientToHistory = Notification.Name("hacks.add-patient-to-history")
            
            static let patientHistoryUpdate = Notification.Name("hacks.patient-history-update")
            
            static let resetCarePlanHistory = Notification.Name("hacks.reset-care-plan-history")
            
            // this is just to take the raw "well-formed" code string, and then do something with it, somewhere else
            static let lifesquareCodeCaptured = Notification.Name("hacks.lifesquare-code-captured") // directly off a scan, well-formed
            static let lifesquareCodeInput = Notification.Name("hacks.lifesquare-code-input") // manually input well-formed only for the regex
            static let imageCaptured = Notification.Name("hacks.imageOSQ-captured")
            
            static let licenseCaptured = Notification.Name("hacks.license-captured")
            
            static let reloadUser = Notification.Name("hacks.reload-user")
            
            static let badgeCountChange = Notification.Name("hacks.badge-count-change")
            
            static let configureTabs = Notification.Name("hacks.configure-tabs")
            
            // lol
            static let containerSizeUpdate = Notification.Name("hacks.container-size-update")
        }
        
        struct analytics {
            static let event = Notification.Name("analytics.event")
        }

    }
    
    struct formatter {
        // this shit be legacy son
        static func documentType(_ name: String) -> String {
            switch name {
                case "POLST" :
                    return "POLST Form"
                case "ADVANCE_DIRECTIVE" :
                    return "Advance Directive"
                case "IMAGING_RESULT" :
                    return "Imaging Result"
                case "MEDICAL_NOTE" :
                    return "Medical Note"
                case "LAB_RESULT" :
                    return "Lab Result"
                default:
                    return name
            }
        }
        
        static func standardDate(_ date: Date) -> String {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            return formatter.string(from: date)
        }
        
        static func dateToString(_ date: Date) -> String {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
        
        static func standardTimestamp(_ date: Date) -> String {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "hh:mm a MM/dd/yyyy"
            return formatter.string(from: date)
        }
        
        static func humanizeTimestamp(_ value: String, format: String="yyyy-mm-ddTHH:MM:SS.sssZ") -> String {
            // assume
            // 2016-12-12T19:14:58.725Z
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            let sub:String = value[value.startIndex...value.characters.index(value.startIndex, offsetBy: 9)]
            let date = inputFormatter.date(from: sub)
            
            let outputFormatter: DateFormatter = DateFormatter()
            outputFormatter.dateFormat = "MM/dd/yyyy"
            return outputFormatter.string(from: date!)
            
            // return value
        }
        
        static func heightToMetric(_ value: String) -> Int {
            // syntax is 5'-11"
            return 180
        }
        
        // this is really to (label)
        static func heightToImperial(_ value: Int) -> String {
            let totalInches:Int = LSQ.formatter.centimetersToInches(value)
            let feet: Int = LSQ.formatter.inchesToFeet(totalInches)
            let inches: Int = LSQ.formatter.inchesToFootInches(totalInches)
            return "\(feet)' - \(inches)\""
        }
        
        static func centimetersToInches(_ value: Int) -> Int {
            // 0.393700787
            return Int(ceil(Float(value) / 2.54))
        }
        
        static func inchesToCentimeters(_ value: Int) -> Int {
            // 0.393700787
            return Int(Float(value) * 2.54)
        }
        
        static func inchesToFeet(_ value: Int) -> Int {
            return Int(floor(Float(value) / 12.0))
        }
        
        static func inchesToFootInches(_ value: Int) -> Int {
            return Int(value % 12)
        }
        
        static func weightToMetric(_ value: Int) -> Double {
            return Double(Double(value) / 2.20462262)
        }
        
        static func weightToImperial(_ value: Double) -> Int {
            return Int(round(value * 2.20462262))
        }
        
        static func phoneStringSquash(_ value: String) -> String {
            // http://stackoverflow.com/questions/36594179/remove-all-non-numeric-characters-from-a-string-in-swift
            // take really anything and spit out 10 digits only
            // let's strip stuff, and then take the last 10 digits, from the right son
            let numericSet = "0123456789"
            let filteredCharacters = value.characters.filter {
                return numericSet.contains(String($0))
            }
            let filteredString = String(filteredCharacters) // -> 347
            // FML
            if filteredString.characters.count >= 10 {
                return filteredString.substring(from: filteredString.characters.index(filteredString.endIndex, offsetBy: -10))
            }
            return ""
        }
        
        static func ageFromBirthday (_ birthday: Date) -> Int {
            return (Calendar.current as NSCalendar).components(.year, from: birthday, to: Date(), options: []).year!
        }
        
        // ok this belongs in a static zone like LSQ.formatters bro
        // TODO: consider dimension reduction resizing yo
        static func imageToBase64(_ image: UIImage, mode: String, compression: CGFloat = 0.7) -> String {
            // 1.0 is no compression, lol bro
            // 0.0 is max cheesed
            if mode == "jpeg" {
                return (UIImageJPEGRepresentation(image, compression)?.base64EncodedString(
                    options: NSData.Base64EncodingOptions.lineLength64Characters))! as String
            }
            if mode == "png"{
                return (UIImagePNGRepresentation(image)?.base64EncodedString(
                    options: NSData.Base64EncodingOptions.lineLength64Characters))! as String

            }
            // you be screwed son
            return ""
        }
        
        static func centsToDollars(_ cents: Int) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            return formatter.string(from: NSNumber(value: Float(cents/100) as Float))!
        }


    }

    struct appearance {
        
        struct color {
            // the raw pallete
            
            static let ogRed: UIColor = UIColor(red: 196/255, green: 38/255, blue: 46/255, alpha: 1.0)
            static let red: UIColor = UIColor(red: 216/255, green: 3/255, blue: 25/255, alpha: 1.0)
            static let purple: UIColor = UIColor(red: 81/255, green: 38/255, blue: 156/255, alpha: 1.0)
            static let blue: UIColor = UIColor(red: 51/255, green: 123/255, blue: 211/255, alpha: 1.0)
            static let blueApple: UIColor = UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1.0)
            static let stolenBlue: UIColor = UIColor(red: 33/255, green: 39/255, blue: 44/255, alpha: 1.0)
            static let white: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            static let black: UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            static let lightGray: UIColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
            static let lightGray2: UIColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
            static let gray0: UIColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0) // f you transparencies
            static let gray1: UIColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0) // f you transparencies
            static let gray2: UIColor = UIColor(red: 19/255, green: 19/255, blue: 19/255, alpha: 1.0) // f you transparencies
            
            // scrape dat JT gray palette front loader scales
            // some other colors, just for giggles
            // dem new colors brolo
            static let newBlue: UIColor = UIColor(red: 55/255, green: 53/255, blue: 70/255, alpha: 1.0) // f you transparencies
            static let newTeal: UIColor = UIColor(red: 2/255, green: 164/255, blue: 174/255, alpha: 1.0) // f you transparencies
            // marketing UI colors brolo
            static let newLilac: UIColor = UIColor(red: 109/255, green: 120/255, blue: 151/255, alpha: 1.0)
            static let newLilacDark: UIColor = UIColor(red: 89/255, green: 99/255, blue: 125/255, alpha: 1.0)
            static let newCyan: UIColor = UIColor(red: 0/255, green: 178/255, blue: 214/255, alpha: 1.0) // f you transparencies
            // Sketch only
            static let newPurple: UIColor = UIColor(red: 110/255, green: 91/255, blue: 174/255, alpha: 1.0) // f you transparencies
            static let newGreen: UIColor = UIColor(red: 0/255, green: 191/255, blue: 120/255, alpha: 1.0) // f you transparencies
            
            static let brand: UIColor = newLilac
        }
        
        // the application onto uikit
        struct ui {
            // technically this one should be set as a default and then overriden in individual views
            // static let defaultViewBackgroundColor: UIColor = color.brand
        }
        
        static func initialize() {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            
            UITabBar.appearance().tintColor = color.newBlue
            UITabBar.appearance().backgroundColor = UIColor.white
            
            UINavigationBar.appearance().barTintColor = color.newBlue
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().tintColor = color.white
            UINavigationBar.appearance().barStyle = UIBarStyle.black
            
            // configure our global loader up in here
            EZLoadingActivity.Settings.SuccessIcon = ""
            EZLoadingActivity.Settings.FailIcon = ""
            EZLoadingActivity.Settings.SuccessText = ""
            EZLoadingActivity.Settings.FailText = ""
            EZLoadingActivity.Settings.BackgroundColor = UIColor.white
            EZLoadingActivity.Settings.TextColor = UIColor.gray
            EZLoadingActivity.Settings.ActivityWidth = 60.0
            EZLoadingActivity.Settings.ActivityHeight = 60.0
        }
        
    }

    struct validator {
        static func email(_ testStr:String) -> Bool {
            let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: testStr)
        }
        
        static func password(_ testStr:String) -> Bool {
            // must include at least one number or non-letter symbol
            let passwordRegEx = ".*[\\d|\\W].*"
            let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
            if testStr.characters.count > 7 && testStr.characters.count < 128 {
                return passwordTest.evaluate(with: testStr)
            }
            return false
        }
        
        static func lifesquareCode(_ testStr:String) -> Bool {
            let regex = "^[a-zA-Z0-9]{9}$" // case insensitive
            let test = NSPredicate(format: "SELF MATCHES %@", regex)
            return test.evaluate(with: testStr)
        }
        
        static func allowableLifesquareCharacter(_ character: String) -> Bool {
            return true
        }
        /*
        + (BOOL)isValidCode:(NSString *)code
        {
        static NSRegularExpression *regex;
        static dispatch_once_t regExToken;
        dispatch_once(&regExToken, ^{
        NSError *err;
        regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-z0-9]{9}$" options:NSRegularExpressionCaseInsensitive error:&err];
        });
        
        return ([regex numberOfMatchesInString:code options:0 range:NSMakeRange(0, code.length)] == 1);
        }
        
        
        + (BOOL)isValidCodeCharacter:(NSString *)character
        {
        static NSRegularExpression *regex;
        static dispatch_once_t regeExToken;
        dispatch_once(&regeExToken, ^{
        NSError *err;
        regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-z0-9]{1,9}$" options:NSRegularExpressionCaseInsensitive error:&err];
        });
        
        return ([regex numberOfMatchesInString:character options:0 range:NSMakeRange(0, character.length)] > 0);
        }
        */
    }
    
    struct constants {
        static let historyMaxAgeSeconds: Double = 21600.0 // Six hours
        static let historyCleanInterval: Double = 60.0 //every minute son, scrub it down
    }
    
    struct action {
        // common shared actions
        static let support: UIAlertAction = UIAlertAction(title:"Contact Support", style: UIAlertActionStyle.default, handler: { action in
            let url = URL(string: "mailto:support@domain.com")
            UIApplication.shared.openURL(url!)
        })
    }
    
    struct launchers {
        static func phone(_ val:String) {
            guard let number = URL(string: "tel:" + val) else { return }
            if #available(iOS 10.0, *) {
                print(number)
                UIApplication.shared.open(number)
            } else {
                // Fallback on earlier versions
                print("ball ")
                let application:UIApplication = UIApplication.shared
                application.openURL(number)
            }
        }
        static func email(_ val:String) {
            if let actionURL:URL = URL(string: "mailto://\(val)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(actionURL)) {
                    application.openURL(actionURL);
                }
            }
        }
        static func sms(_ val:String) {
            if let actionURL:URL = URL(string: "sms://\(val)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(actionURL)) {
                    application.openURL(actionURL);
                }
            }
        }
    }
    
    struct utils {
        // http://stackoverflow.com/questions/27880650/swift-extract-regex-matches
        static func matchesForRegexInText(_ regex: String, text: String) -> [String] {
            do {
                let regex = try NSRegularExpression(pattern: regex, options: [])
                let nsString = text as NSString
                let results = regex.matches(in: text,
                                                    options: [], range: NSMakeRange(0, nsString.length))
                return results.map { nsString.substring(with: $0.range)}
            } catch let error as NSError {
                print("invalid regex: \(error.localizedDescription)")
                return []
            }
        }
    }
    
    struct permissions {
        static func checkPermissionCamera() -> String {
            let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            switch status {
            case AVAuthorizationStatus.authorized:
                return "authorized"
            case AVAuthorizationStatus.denied:
                return "denied"
            case AVAuthorizationStatus.notDetermined:
                return "notdetermined"
            default:
                return ""
            }
        }
        
        static func checkPermissionPhotos() -> String {
            let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            switch status {
            case PHAuthorizationStatus.authorized:
                return "authorized"
            case PHAuthorizationStatus.denied:
                return "denied"
            case PHAuthorizationStatus.notDetermined:
                return "notdetermined"
            default:
                return ""
            }
        }
        
        static func checkPermissionLocation() -> String {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways:
                    return "authorized"
                case .authorizedWhenInUse:
                    return "authorized"
                case .denied:
                    return "denied"
                case .restricted:
                    return "restricted"
                case .notDetermined:
                    return "notdetermined"
                }
            } else {
                return ""
            }
        }
        
        static func checkPermissionNotifications() -> Bool {
            let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
            let notificationTypes = UIApplication.shared.currentUserNotificationSettings!.types
            //  {
            // TODO: USE THESE TOGETHER THOUGH for optimal granularity
            // use different buttons because we honestly have different scenarios
            
            // one is rescue-push
            
            if notificationTypes.contains(UIUserNotificationType.alert) && isRegisteredForRemoteNotifications {
                return true
            }
            return false
        }
    }
    
}
