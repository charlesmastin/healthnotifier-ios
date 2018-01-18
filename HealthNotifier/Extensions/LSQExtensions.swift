//
//  LSQExtensions.swift
//
//  Created by Charles Mastin on 10/3/16.
//

import Foundation

// http://stackoverflow.com/questions/9906966/completion-handler-for-uinavigationcontroller-pushviewcontrolleranimated
// usage
// navigationController?.pushViewController(vc, animated: true) {
    // Animation done
// }
extension UINavigationController {
    
    func pushViewController(_ viewController: UIViewController,
                            animated: Bool, completion: @escaping () -> Void) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
}

// http://stackoverflow.com/questions/37048759/swift-display-html-data-in-a-label-or-textview
extension String {
    
    var html2AttributedString: NSAttributedString? {
        guard
            let data = data(using: String.Encoding.utf8)
            else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:String.Encoding.utf8], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
// http://stackoverflow.com/questions/28414999/html-format-in-uitextview
extension Data {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
extension String {
    var utf8Data: Data? {
        return data(using: String.Encoding.utf8)
    }
}

// import UIKit.UIFont



//
//  UIView+Frame.swift
//  FoudCourt
//
//  Created by Evgenii Rtishchev on 08/10/15.
//  Copyright © 2015 Evgenii Rtishchev. All rights reserved.
//
// https://github.com/katleta3000/UIView-Frame/blob/master/UIView%2BFrame.swift
import UIKit

extension UIView {
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var rect = self.frame
            rect.size.width = newValue
            self.frame = rect
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var rect = self.frame
            rect.size.height = newValue
            self.frame = rect
        }
    }
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var rect = self.frame
            rect.origin.x = newValue
            self.frame = rect
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var rect = self.frame
            rect.origin.y = newValue
            self.frame = rect
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            var rect = self.frame
            rect.origin.y = newValue - self.frame.size.height
            self.frame = rect
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            var rect = self.frame
            rect.origin.y = newValue - self.frame.size.width
            self.frame = rect
        }
    }
}

//
//  Created by Frédéric ADDA on 25/07/2016.
//  Copyright © 2016 Frédéric ADDA. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    func addShadow(_ shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}

// https://gist.github.com/sjgroomi/2a30c9b1447736aa66e5
import UIKit

extension UIResponder {
    
    //Class var not supported in 1.0
    fileprivate struct CurrentFirstResponder {
        weak static var currentFirstResponder: UIResponder?
    }
    fileprivate class var currentFirstResponder: UIResponder? {
        get { return CurrentFirstResponder.currentFirstResponder }
        set(newValue) { CurrentFirstResponder.currentFirstResponder = newValue }
    }
    
    class func getCurrentFirstResponder() -> UIResponder? {
        currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder), to: nil, from: nil, for: nil)
        return currentFirstResponder
    }
    
    func findFirstResponder() {
        UIResponder.currentFirstResponder = self
    }
}

extension UIView {
    var firstResponder:UIView? {
        if self.isFirstResponder {
            return self
        }
        for view in self.subviews {
            if let firstResponder = view.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
}

extension UIViewController {
    var firstResponder:UIView? {
        return view.firstResponder
    }
}

// http://stackoverflow.com/questions/27998409/email-phone-validation-in-swift
extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.characters.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}

// http://stackoverflow.com/questions/28935565/calculate-age-from-birth-date
extension Date {
    var age: Int {
        return (Calendar.current as NSCalendar).components(.year, from: self, to: Date(), options: []).year!
    }
}

import Alamofire

// http://stackoverflow.com/questions/39838682/alamofire4-trouble-with-jsonresponseserializer-httpurlresponse-swift-3-0/39838723#39838723
// thank you thank you!
extension Alamofire.DataRequest {
   
    public func defaultResponseHandler(_ success: @escaping (AnyObject) -> Void, failure: @escaping (AnyObject) -> Void) -> Void {
        validate()
        .responseJSON(completionHandler: { response in
            /*
            guard case let .failure(error) = response.result else { return }
            if let error = error as? AFError {
                switch error {
                case .invalidURL(let url):
                    print("Invalid URL: \(url) - \(error.localizedDescription)")
                case .parameterEncodingFailed(let reason):
                    print("Parameter encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .multipartEncodingFailed(let reason):
                    print("Multipart encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .responseValidationFailed(let reason):
                    print("Response validation failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    
                    switch reason {
                    case .dataFileNil, .dataFileReadFailed:
                        print("Downloaded file could not be read")
                    case .missingContentType(let acceptableContentTypes):
                        print("Content Type Missing: \(acceptableContentTypes)")
                    case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                        print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                    case .unacceptableStatusCode(let code):
                        print("Response status code was unacceptable: \(code)")
                    }
                case .responseSerializationFailed(let reason):
                    print("Response serialization failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                }
                
                print("Underlying error: \(error.underlyingError)")
            } else if let error = error as? URLError {
                print("URLError occurred: \(error)")
            } else {
                print("Unknown error: \(error)")
            }
            */
            switch response.result {
                case .success(_):
                    success(response.result.value! as AnyObject)
                case .failure(_):
                    if (response.response != nil) {
                        // TODO: figure out how to look at the request url and exclude "/login
                        // TODO: figure out how to preserve the failed request and send along for a retry
                        if response.response?.statusCode == 401 {
                            NotificationCenter.default.post(name: LSQ.notification.auth.unauthorized, object: nil)
                            // should we even do our failure callback at this point? since naaaa, probaly not
                            return
                        }
                    }
                    // TODO: get real thingy sony
                    failure(response as AnyObject)
            }
        })
    }
}

// meh meh meh
// https://gist.github.com/stinger/803299c1ee0c95e53dc3d9e59c37b187

//: ### Defining the protocols
protocol JSONRepresentable {
    var JSONRepresentation: Any { get }
}

protocol JSONSerializable: JSONRepresentable {}

//: ### Implementing the functionality through protocol extensions
extension JSONSerializable {
    var JSONRepresentation: Any {
        var representation = [String: Any]()
        
        for case let (label?, value) in Mirror(reflecting: self).children {
            
            switch value {
                
            case let value as Dictionary<String, Any>:
                representation[label] = value as AnyObject
                
            case let value as Array<Any>:
                if let val = value as? [JSONSerializable] {
                    representation[label] = val.map({ $0.JSONRepresentation as AnyObject }) as AnyObject
                } else {
                    representation[label] = value as AnyObject
                }
                
            case let value:
                representation[label] = value as AnyObject
                
            //default:
                // Ignore any unserializable properties
            //  break
            }
        }
        return representation as Any
    }
}

extension JSONSerializable {
    func toJSON() -> String? {
        let representation = JSONRepresentation
        
        guard JSONSerialization.isValidJSONObject(representation) else {
            print("Invalid JSON Representation")
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: representation, options: [])
            
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}


// https://stackoverflow.com/questions/15090987/how-to-identify-that-an-uiviewcontroller-is-presented
// Edit: Added 2 other modal cases
extension UIViewController {
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (navigationController != nil && navigationController?.presentingViewController?.presentedViewController == navigationController)
            || tabBarController?.presentingViewController is UITabBarController
    }
}

extension UIViewController {
    var isEmbeded: Bool {
        if self.presentingViewController is UINavigationController {
            print("A")
            return true
        }
        if self.parent is UINavigationController {
            print("B")
            return true
        }
        if self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController {
            print("C")
            return true
        }
        return false
    }
}

extension UIViewController {
    var wasPresented: Bool {
        return self.isModal
    }
}

// https://stackoverflow.com/questions/33038451/get-reference-to-nslayoutconstraint-using-identifier-set-in-storyboard
extension UIView {
    func constraint(withIdentifier: String) -> NSLayoutConstraint? {
        return self.constraints.filter { $0.identifier == withIdentifier }.first
    }
}

// https://stackoverflow.com/questions/24668818/how-to-dismiss-viewcontroller-in-swift
extension UIViewController {
    func dismissMe(animated: Bool, completion: (()->())?) {
        var count = 0
        if let c = self.navigationController?.childViewControllers.count {
            count = c
        }
        if count > 1 {
            //Pop the last view controller off navigation controller list
            self.navigationController!.popViewController(animated: animated)
            if let handler = completion {
                handler()
            }
        } else {
            //Dismiss the last vc or vc without navigation controller
            dismiss(animated: animated, completion: completion)
        }
    }
}

/*
 if let c = button.constraint(withIdentifier: "my-button-width") {
 // do stuff with c
 }
 */
