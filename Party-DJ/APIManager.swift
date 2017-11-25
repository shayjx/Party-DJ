//
//  APIManager.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/24/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import Foundation
import Alamofire

class APIManager {
    typealias JSON = [String: Any]
    var auth: SPTAuth
    var session: SPTSession!
    var loginURL: URL?
    var lastRequest: DataRequest?
    
    private static var _current: APIManager?
    
    static var current: APIManager? {
        get {
            if _current == nil {
                // check if there is a stored session; if so, regenerate an API manager from that session
                let defaults = UserDefaults.standard
                if let sessionObject = defaults.object(forKey: "currentSPTSession") {
                    let sessionData = sessionObject as! Data
                    let session = NSKeyedUnarchiver.unarchiveObject(with: sessionData) as! SPTSession
                    _current = APIManager(session: session)
                }
            }
            return _current
        }
        set (manager) {
            _current = manager
            if let manager = manager {
                // store the session data
                if let session = manager.session {
                    let defaults = UserDefaults.standard
                    let sessionData = NSKeyedArchiver.archivedData(withRootObject: session)
                    defaults.set(sessionData, forKey: "currentSPTSession")
                    defaults.synchronize()
                }
            }
        }
    }
    
    init() {
        self.auth = SPTAuth.defaultInstance()!
        self.auth.clientID = "3cf0170752134301bf4e79b33eae31e8" // put your client ID here
        self.auth.redirectURL = URL(string: "Kickback://returnAfterLogin") // put your direct URL here
        self.auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistModifyPrivateScope]
        self.auth.sessionUserDefaultsKey = "currentSPTSession" // user defaults key to automatically save the session when it changes
        self.loginURL = auth.spotifyWebAuthenticationURL()
    }
    
    init(session: SPTSession) {
        self.auth = SPTAuth.defaultInstance()!
        self.auth.clientID = "3cf0170752134301bf4e79b33eae31e8" // put your client ID here
        self.auth.redirectURL = URL(string: "Kickback://returnAfterLogin") // put your direct URL here
        self.auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistModifyPrivateScope]
        self.auth.tokenSwapURL = URL(string: "https://kickback-token-refresh.herokuapp.com/swap")
        self.auth.tokenRefreshURL = URL(string: "https://kickback-token-refresh.herokuapp.com/refresh")
        self.loginURL = auth.spotifyWebAuthenticationURL()
        self.session = session
    }
    
    func refreshToken() {
        auth.renewSession(session) { (error, newSession) in
            if let error = error {
                print("got an error")
                print(error.localizedDescription)
            } else {
                self.session = newSession
            }
        }
    }
}
