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
        self.auth.redirectURL = URL(string: "partydj-spotify://callback") // put your direct URL here
        self.auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistModifyPrivateScope]
        self.auth.sessionUserDefaultsKey = "currentSPTSession" // user defaults key to automatically save the session when it changes
        self.loginURL = auth.spotifyWebAuthenticationURL()
    }
    
    init(session: SPTSession) {
        self.auth = SPTAuth.defaultInstance()!
        self.auth.clientID = "3cf0170752134301bf4e79b33eae31e8" // put your client ID here
        self.auth.redirectURL = URL(string: "partydj-spotify://callback") // put your direct URL here
        self.auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistModifyPrivateScope]
        self.auth.tokenSwapURL = URL(string: "https://partydj-refresh.herokuapp.com/")
        self.auth.tokenRefreshURL = URL(string: "https://partydj-refresh.herokuapp.com/")
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
   
    func createUser() {
        SPTUser.requestCurrentUser(withAccessToken: session.accessToken, callback: { (error: Error?, response: Any?) in
            if let error = error {
                print("Error requesting in createUser(): \(error.localizedDescription)")
            } else {
                let spotifyUser = response as! SPTUser
                var dictionary: [String: Any] = [:]
                dictionary["id"] = spotifyUser.canonicalUserName
                if spotifyUser.displayName == nil {
                    dictionary["name"] = ""
                    
                } else {
                    dictionary["name"] = spotifyUser.displayName
                }
                if spotifyUser.smallestImage != nil {
                    dictionary["profileImageURL"] = spotifyUser.smallestImage.imageURL.absoluteString
                }
                let status = spotifyUser.product
                dictionary["premium"] = status == SPTProduct.premium
                let user = User(dictionary)
                User.current = user
                NotificationCenter.default.post(name: Notification.Name(rawValue: "user.currentSetup"), object: nil)
            }
        })
    }
    
    func searchTracks(query: String, user: User?, callback: @escaping ([Track]) -> Void) -> Void {
        if lastRequest != nil {
            lastRequest!.cancel()
            lastRequest = nil
        }
        var results: [Track] = []
        let urlRequest = try! SPTSearch.createRequestForSearch(withQuery: query, queryType: .queryTypeTrack, accessToken: session.accessToken)
        lastRequest = Alamofire.request(urlRequest).responseJSON { (response) in
            do {
                var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: Any]
                if let tracks = readableJSON["tracks"] as? JSON {
                    if let items = tracks["items"] as? [JSON] {
                        for i in 0..<items.count {
                            let item = items[i]
                            var dictionary: [String: Any] = [:]
                            dictionary["id"] = item["id"]
                            dictionary["name"] = item["name"]
                            dictionary["album"] =  item["album"] as! JSON
                            dictionary["artists"] = item["artists"] as! [JSON]
                            dictionary["userId"] = user?.id
                            dictionary["uri"] = item["uri"]
                            dictionary["likes"] = 0
                            dictionary["likedByUsers"] = []
                            dictionary["duration_ms"] = item ["duration_ms"]
                            let track = Track(dictionary)
                            results.append(track)
                        }
                    }
                }
                callback(results)
            } catch {
                print("Error while searching tracks: \(error.localizedDescription)")
            }
        }
    }
    
    func searchArtists(query: String, user: User?, callback: @escaping ([Artist]) -> Void) -> Void {
        if lastRequest != nil {
            lastRequest!.cancel()
            lastRequest = nil
        }
        var results: [Artist] = []
        let urlRequest = try! SPTSearch.createRequestForSearch(withQuery: query, queryType: .queryTypeArtist, accessToken: session.accessToken)
        lastRequest = Alamofire.request(urlRequest).responseJSON { (response) in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: Any]
                if let artists = readableJSON["artists"] as? JSON {
                    if let items = artists["items"] as? [JSON] {
                        for i in 0..<items.count {
                            let item = items[i]
                            var dictionary: [String: Any] = [:]
                            dictionary["id"] = item["id"]
                            dictionary["name"] = item["name"]
                            dictionary["images"] = item["images"] as! [JSON]
                            dictionary["userId"] = user?.id
                            dictionary["uri"] = item["uri"]
                            let artist = Artist(dictionary)
                            results.append(artist)
                        }
                    }
                }
                callback(results)
            } catch {
                print("Error while searching artists: \(error.localizedDescription)")
            }
        }
    }
    
    func searchAlbums(query: String, user: User?, callback: @escaping ([Album]) -> Void) -> Void {
        if lastRequest != nil {
            lastRequest!.cancel()
            lastRequest = nil
        }
        var results: [Album] = []
        let urlRequest = try! SPTSearch.createRequestForSearch(withQuery: query, queryType: .queryTypeAlbum, accessToken: session.accessToken)
        lastRequest = Alamofire.request(urlRequest).responseJSON { (response) in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: Any]
                if let albums = readableJSON["albums"] as? JSON {
                    if let items = albums["items"] as? [JSON] {
                        for i in 0..<items.count {
                            let item = items[i]
                            var dictionary: [String: Any] = [:]
                            dictionary["id"] = item["id"]
                            dictionary["name"] = item["name"]
                            dictionary["images"] =  item["images"] as! [JSON]
                            dictionary["artists"] = item["artists"] as! [JSON]
                            dictionary["userId"] = user?.id
                            dictionary["uri"] = item["uri"]
                            let album = Album(dictionary)
                            results.append(album)
                        }
                    }
                }
                callback(results)
                
            } catch {
                print("Error while searching albums: \(error.localizedDescription)")
            }
        }
    }
    
    func getTracksInAlbum(albumURI: URL, user: User?, callback: @escaping ([Track]) -> Void) -> Void {
        var results: [Track] = []
        let urlRequest = try! SPTAlbum.createRequest(forAlbum: albumURI, withAccessToken: session.accessToken, market: "US")
        Alamofire.request(urlRequest).responseJSON { (response) in
            do {
                var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as!                     [String: Any]
                if let tracks = readableJSON["tracks"] as? JSON {
                    if let items = tracks["items"] as? [JSON] {
                        for i in 0..<items.count {
                            let item = items[i]
                            var dictionary: [String: Any] = [:]
                            dictionary["id"] = item["id"]
                            dictionary["name"] = item["name"]
                            dictionary["album"] = readableJSON
                            dictionary["artists"] = item["artists"] as! [JSON]
                            dictionary["userId"] = user?.id
                            dictionary["uri"] = item["uri"]
                            dictionary["likes"] = 0
                            dictionary["likedByUsers"] = []
                            dictionary["duration_ms"] = item ["duration_ms"]
                            let track = Track(dictionary)
                            results.append(track)
                        }
                    }
                }
                callback(results)
            } catch {
                print(error.localizedDescription)
            }
        }
        refreshToken()
    }
    
    
    func getAlbumsByArtist(artistURI: URL, user: User?, callback: @escaping ([Album]) -> Void) -> Void {
        var results: [Album] = []
        let urlRequest = try! SPTArtist.createRequestForAlbums(byArtist: artistURI, of: SPTAlbumType.album, withAccessToken: session.accessToken, market: "US")
        Alamofire.request(urlRequest).responseJSON { (response) in
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: Any]
                if let albums = readableJSON["items"] as? [[String: Any]] {
                    for item in albums {
                        var dictionary: [String: Any] = [:]
                        dictionary["id"] = item["id"]
                        dictionary["name"] = item["name"]
                        dictionary["images"] =  item["images"] as! [JSON]
                        dictionary["artists"] = item["artists"] as! [JSON]
                        dictionary["userId"] = user?.id
                        dictionary["uri"] = item["uri"]
                        let album = Album(dictionary)
                        results.append(album)
                    }
                }
                callback(results)
            } catch {
                print(error.localizedDescription)
            }
        }
        refreshToken()
    }
    
    func getTopTracks(artistURI: URL, user: User?, callback: @escaping ([Track]) -> Void) -> Void {
        var results: [Track] = []
        let urlRequest = try! SPTArtist.createRequestForTopTracks(forArtist: artistURI, withAccessToken: session.accessToken, market: "US")
        Alamofire.request(urlRequest).responseJSON { (response) in
            do {
                var readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: Any]
                if let tracks = readableJSON["tracks"] as? [[String: Any]] {
                    for item in tracks {
                        var dictionary: [String: Any] = [:]
                        dictionary["id"] = item["id"]
                        dictionary["name"] = item["name"]
                        dictionary["album"] =  item["album"] as! JSON
                        dictionary["artists"] = item["artists"] as! [JSON]
                        dictionary["userId"] = user?.id
                        dictionary["uri"] = item["uri"]
                        dictionary["likes"] = 0
                        dictionary["likedByUsers"] = []
                        dictionary["duration_ms"] = item ["duration_ms"]
                        let track = Track(dictionary)
                        results.append(track)
                    }
                }
                callback(results)
            } catch {
                print(error.localizedDescription)
            }
        }
        refreshToken()
    }
    
}

