//
//  Track.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/26/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import Foundation
import Parse

class Track: Comparable {
    
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
    var album: [String: Any] {
        get {
            return dictionary["album"] as! [String: Any]
        }
        set (album) {
            dictionary["album"] = album
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
    var durationMS: Int? {
        get {
            return  dictionary["duration_ms"] as? Int
        }
        set (duration)
        {
            dictionary["duration_ms"] = durationMS
        }
        
    }
    var likedByUsers: [String] {
        get {
            return dictionary["likedByUsers"] as! [String]
        }
        set (likedByUsers) {
            dictionary["likedByUsers"] = likedByUsers
        }
    }
    
    var likes: Int {
        get {
            return dictionary["likes"] as! Int
        }
        set (likes) {
            dictionary["likes"] = likes
        }
    }
    var addedAt: Date {
        get {
            return dictionary["addedAt"] as! Date
        }
        set (date) {
            dictionary["addedAt"] = date
        }
    }
    
    init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
    }
    
    func like(userId: String) {
        self.likes += 1
        self.likedByUsers.append(userId)
    }
    
    func unlike(userId: String) {
        self.likes -= 1
        let index = self.likedByUsers.index(of: userId)
        self.likedByUsers.remove(at: index!)
    }
    
    func isLikedBy(userId: String) -> Bool {
        return self.likedByUsers.contains(userId)
    }
    
    static func < (lhs: Track, rhs: Track) -> Bool {
        if lhs.likes == rhs.likes {
            return lhs.addedAt < rhs.addedAt
        } else {
            return lhs.likes > rhs.likes
        }
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
}

