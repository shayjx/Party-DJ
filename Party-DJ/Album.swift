//
//  Album.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/26/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import Foundation
import Parse

class Album {
    
    // Properties
    var dictionary: [String: Any]
    
    var id: String {
        get {
            return dictionary["id"] as! String
        }
        set (id) {
            dictionary["id"] = id
        }
    }
    var name: String {
        get {
            return dictionary["name"] as! String
        }
        set (name) {
            dictionary["name"] = name
        }
    }
    var images: [[String: Any]] {
        get {
            return dictionary["images"] as! [[String: Any]]
        }
        set (album) {
            dictionary["images"] = album
        }
    }
    
    var artists: [[String: Any]] {
        get {
            return dictionary["artists"] as! [[String: Any]]
        }
        set (artists) {
            dictionary["artists"] = artists
        }
    }
    var userId: String? {
        get {
            return dictionary["userId"] as? String
        }
        set (userId) {
            dictionary["userId"] = userId
        }
    }
    var uri: String {
        get {
            return dictionary["uri"] as! String
        }
        set (uri) {
            dictionary["uri"] = uri
        }
    }
    init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
    }
}

