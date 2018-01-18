//
//  LSQAppearanceManager.swift
//
//  Created by Charles Mastin on 9/13/17.
//

import Foundation
import UIKit

class LSQAppearanceManager {
    static let sharedInstance = LSQAppearanceManager()
    //
    // basically, swap themes on themes bro
    
    // are we using the toned table vibe
    // or are we using a default view and table colors
    
    // which color are we using as a base for our view controllers brolo
    var defaultViewBackgroundColor: UIColor? = nil
    var underlinedInputs: Bool = false
    var cellSeparatorColor: UIColor? = nil
    // central themeing??? of objects? naaaaaa, maybe though
    // reasonable changes include color only… meh
    //
    func reset(){
        self.defaultViewBackgroundColor = nil
        self.underlinedInputs = false
        self.cellSeparatorColor = nil
    }
    
    func activateThemeOnboarding(){
        self.defaultViewBackgroundColor = nil
        self.underlinedInputs = false
        self.cellSeparatorColor = nil
    }
    
    func activateThemeAuth(){
        self.defaultViewBackgroundColor = LSQ.appearance.color.newTeal
        self.underlinedInputs = true
        self.cellSeparatorColor = nil
    }
}
