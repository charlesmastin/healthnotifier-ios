//
//  LSQUserPrefs.swift
//
//  Created by Charles Mastin on 5/27/17.
//

import Foundation

struct LSQUserPrefs: JSONSerializable {
    // prefs - serialize a struct though?
    var touchIdEnabled: Bool = false
    // special secret nsa stuffs
    var locationTracking: Bool = false
    var backgroundLocation: Bool = false
    // TODO: not just a preference, but something coming back from the server
    var pushEnabled: Bool = false
    // push notifications opt-in settings
    var rejectedPushPrettyPlease: Bool = false // this could be true, but we still get a shot
    var rejectedPush: Bool = false // system prompt, if this is ever true, we know we have to do that thing
}
