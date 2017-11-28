//
//  User.swift
//  
//
//  Created by Shana Joseph on 11/26/17.
//


import Foundation


class User {
    
    // Properties
    var id: String // corresponds to the spotify ID
    var name: String
    var queueId: String?
    var premium: Bool
    var profileImageURL: String?
    var parseId: String?
    var parseUser: PFObject!
    
    private static var _current: User?
    
    static var current: User? {
        get {
            if _current == nil {
                let defaults = UserDefaults.standard
                if let userData = defaults.data(forKey: "currentUserData") {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! [String: Any]
                    _current = User(dictionary)
                }
            }
            return _current
        }
        set (user) {
            _current = user
            let defaults = UserDefaults.standard
            if let user = user {
                var dictionary: [String: Any] = [:]
                dictionary["id"] = user.id
                dictionary["name"] = user.name
                dictionary["profileImageURL"] = user.profileImageURL
                dictionary["queueId"] = user.queueId
                dictionary["premium"] = user.premium
                if let parseId = user.parseId {
                    user.parseUser = try! PFQuery(className: "SPTUser").getObjectWithId(
                        parseId)
                }
                let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.removeObject(forKey: "currentUserData")
            }
        }
    }
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as! String
        self.name = dictionary["name"] as! String
        self.premium = dictionary["premium"] as! Bool
        if dictionary["profileImageURL"] != nil  {
            profileImageURL = dictionary["profileImageURL"] as? String
        }
        self.profileImageURL = dictionary["profileImageURL"] as? String
        self.queueId = dictionary["queueId"] as? String
        let query = PFQuery(className: "SPTUser").whereKey("id", equalTo: id)
        if query.countObjects(nil) == 0 {
            self.parseUser = PFObject(className: "SPTUser", dictionary: dictionary)
            self.parseUser.saveInBackground(block: { (success, error) in
                if success {
                    self.parseId = self.parseUser.objectId
                } else {
                    print(error!.localizedDescription)
                }
            })
        } else {
            query.getFirstObjectInBackground(block: { (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.parseUser = result!
                    self.parseId = self.parseUser.objectId
                }
            })
        }
    }
    
    func add(queueId: String) {
        self.queueId = queueId
        self.parseUser["queueId"] = queueId
        self.parseUser.saveInBackground()
    }
    
    static func leaveQueue() {
        if let user = User.current {
            user.queueId = nil
            User.current = user
            user.parseUser.remove(forKey: "queueId")
            user.parseUser.saveInBackground()
        }
    }
}
