//
//  Queue.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/26/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import Foundation
import Parse

class Queue {
    
    // Properties
    var id: String!
    var ownerId: String
    var accessCode: String
    var name: String // name of queue
    var tracks: [Track] = []
    var counts: [String: Int] = [:] // user id : number of songs user has played
    var members: [String] // user ids, might not be necessary with the counts dictionary?
    var playIndex: Int = 0 // index of current playing track
    var furthestIndex : Int = 0
    var currentTrack: Track?
    var parseQueue: PFObject
    
    private static var _current: Queue?
    static var current: Queue? {
        get {
            if _current == nil {
                if let queueId = User.current?.queueId {
                    let parseQueue = try! PFQuery(className: "Queue").getObjectWithId(queueId)
                    _current = Queue(parseQueue)
                }
            }
            return _current
        }
        set (newQueue) {
            _current = newQueue
        }
    }
    
    // Create initializer
    init(owner: User, name: String) {
        let queue = PFObject(className: "Queue")
        self.ownerId = owner.id
        self.accessCode = Queue.generateAccessCode()
        if name.characters.count == 0 {
            self.name = "New Playlist"
        } else {
            self.name = name
        }
        self.members = [owner.id]
        queue["ownerId"] = self.ownerId
        queue["accessCode"] = self.accessCode
        queue["name"] = self.name
        queue["jsonTracks"] = [] as! [[String: Any]]
        queue["members"] = self.members
        queue["playIndex"] = self.playIndex
        queue["furthestIndex"] = self.furthestIndex
        self.parseQueue = queue
        queue.saveInBackground { (success: Bool, error: Error?) in
            if success {
                self.id = self.parseQueue.objectId!
                owner.add(queueId: self.id)
                User.current = owner
                print(User.current!.queueId!)
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    init(_ parseQueue: PFObject) {
        self.parseQueue = parseQueue
        self.id = parseQueue.objectId
        self.ownerId = parseQueue["ownerId"] as! String
        self.accessCode = parseQueue["accessCode"] as! String
        self.name = parseQueue["name"] as! String
        let jsonTracks = parseQueue["jsonTracks"] as! [[String: Any]]
        self.tracks = []
        for jsonTrack in jsonTracks {
            self.tracks.append(Track(jsonTrack))
        }
        self.members = parseQueue["members"] as! [String]
        self.playIndex = parseQueue["playIndex"] as! Int
        self.furthestIndex = parseQueue["furthestIndex"] as! Int
    }
    
    func updateFromParse(callback: @escaping () -> Void) {
        self.parseQueue.fetchInBackground { (result, error) in
            if let parseQueue = result {
                self.id = parseQueue.objectId
                self.ownerId = parseQueue["ownerId"] as! String
                self.accessCode = parseQueue["accessCode"] as! String
                self.name = parseQueue["name"] as! String
                let jsonTracks = parseQueue["jsonTracks"] as! [[String: Any]]
                self.tracks = []
                for jsonTrack in jsonTracks {
                    self.tracks.append(Track(jsonTrack))
                }
                self.members = parseQueue["members"] as! [String]
                self.playIndex = parseQueue["playIndex"] as! Int
                self.furthestIndex = parseQueue["furthestIndex"] as! Int
                self.parseQueue = parseQueue
                callback()
            } else {
                print("Error updating from parse \(error!.localizedDescription)")
            }
        }
    }
    
    func addMember(userId: String) {
        if !members.contains(userId) {
            updateFromParse(callback: {
                self.members.append(userId)
                self.parseQueue.add(userId, forKey: "members")
                self.parseQueue.saveInBackground()
            })
        }
    }
    
    func removeMember(userId: String) {
        if members.contains(userId) {
            updateFromParse(callback: {
                self.members = self.members.filter() {$0 != userId}
                self.parseQueue.remove(userId, forKey: "members")
                self.parseQueue.saveInBackground()
            })
        }
    }
    
    func addTrack(_ track: Track, user: User) {
        track.userId = user.id
        track.addedAt = Date()
        updateFromParse(callback: {
            self.tracks.append(track)
            self.sortTracks()
            var jsonTracks: [[String: Any]] = []
            for track in self.tracks {
                jsonTracks.append(track.dictionary)
            }
            self.parseQueue["jsonTracks"] = jsonTracks
            self.parseQueue.saveInBackground()
        })
    }
    
    func renameTo(_ newName: String) {
        self.name = newName
        parseQueue["name"] = newName
        parseQueue.saveInBackground()
    }
    
    func incrementPlayIndex() {
        if furthestIndex == playIndex {
            furthestIndex += 1
        }
        playIndex += 1
        parseQueue["playIndex"] = playIndex
        parseQueue["furthestIndex"] = furthestIndex
        parseQueue.saveInBackground()
    }
    
    func decrementPlayIndex() {
        playIndex -= 1
        parseQueue["playIndex"] = playIndex
        parseQueue.saveInBackground()
    }
    
    func sortTracks() {
        if tracks.isEmpty {
            return
        }
        var sortedTracks: [Track] = []
        var userQueues: [String: [Track]] = [:]
        // initializing user queues
        for userId in members {
            userQueues[userId] = []
            counts[userId] = 0
        }
        // initializing the counts dictionary
        for i in 0..<furthestIndex + 1 {
            sortedTracks.append(tracks[i])
            counts[tracks[i].userId!]! += 1
        }
        // sorting the unplayed tracks
        let unplayedTracks = Array(tracks[furthestIndex + 1..<tracks.endIndex])
        if !unplayedTracks.isEmpty {
            for track in unplayedTracks {
                userQueues[track.userId!]!.append(track)
            }
            var peekedTracks: [Track] = []
            for userId in members {
                var userTracks = userQueues[userId]!
                QuickSort.quicksortDutchFlag(&userTracks, low: 0, high: userTracks.count - 1)
                if !userTracks.isEmpty {
                    peekedTracks.append(userTracks.removeFirst())
                }
                userQueues[userId] = userTracks
            }
            var numTracks = unplayedTracks.count
            while numTracks > 0 {
                numTracks -= 1
                var minIndex = 0
                for i in 0..<peekedTracks.count {
                    minIndex = isLess(peekedTracks[i], peekedTracks[minIndex]) ? i : minIndex
                }
                let min = peekedTracks[minIndex]
                sortedTracks.append(min)
                peekedTracks.remove(at: minIndex)
                counts[min.userId!]! += 1
                var userTracks = userQueues[min.userId!]!
                if !userTracks.isEmpty {
                    let track = userTracks.removeFirst()
                    peekedTracks.append(track)
                    userQueues[min.userId!] = userTracks
                }
            }
        }
        self.tracks = sortedTracks
        updateTracksToParse()
    }
    
    private func isLess(_ lhs: Track, _ rhs: Track) -> Bool {
        let lhsCounts = counts[lhs.userId!]!
        let rhsCounts = counts[rhs.userId!]!
        if lhs.likes == rhs.likes && lhsCounts == rhsCounts {
            return lhs.addedAt < rhs.addedAt
        } else if lhs.likes == rhs.likes {
            return lhsCounts < rhsCounts
        } else {
            return lhs.likes > rhs.likes
        }
    }
    
    func updateTracksToParse() {
        var jsonTracks: [[String: Any]] = []
        for track in tracks {
            jsonTracks.append(track.dictionary)
        }
        parseQueue["jsonTracks"] = jsonTracks
        parseQueue.saveInBackground()
    }
    
    private static func generateAccessCode() -> String {
        let possible : NSString = "abcdefghijklmnopqrstuvwxyz"
        var codeExists = true
        var code: String = ""
        while codeExists {
            code = ""
            for _ in 1...6 {
                let random = arc4random_uniform(UInt32(possible.length))
                var char = possible.character(at: Int(random))
                code += NSString(characters: &char, length: 1) as String
            }
            let query = PFQuery(className: "Queue").whereKey("accessCode", equalTo: code)
            if query.countObjects(nil) == 0 {
                codeExists = false
            }
        }
        return code
    }
}
