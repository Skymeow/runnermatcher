//
//  Chat.swift
//  iosapp
//
//  Created by Sky Xu on 8/16/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
class Chat {
    var key: String?
    let title: String
    let memberHash: String
    let memberUIDs: [String]
    var lastMessage: String?
    var lastMessageSent: Date?
    
    init?(snapshot: DataSnapshot) {
        guard !snapshot.key.isEmpty,
            let dict = snapshot.value as? [String : Any],
            let title = dict["title"] as? String,
            let memberHash = dict["memberHash"] as? String,
            let membersDict = dict["members"] as? [String : Bool],
            let lastMessage = dict["lastMessage"] as? String,
            let lastMessageSent = dict["lastMessageSent"] as? TimeInterval
            else { return nil }
        
        self.key = snapshot.key
        self.title = title
        self.memberHash = memberHash
        self.memberUIDs = Array(membersDict.keys)
        self.lastMessage = lastMessage
        self.lastMessageSent = Date(timeIntervalSince1970: lastMessageSent)
        
    }
    
    init(members: [User]){
        // app will crush if there were more than two users
        assert(members.count == 2, "There must be two members in a chat.")
        
        // create the chat title using usernames of each member
        self.title = members.reduce("") { (acc, cur) -> String in
            return acc.isEmpty ? cur.first_name : "\(acc), \(cur.first_name)"
        }
        // store a hash value so users won't duplicate chats
        self.memberHash = Chat.hash(forMembers: members)
        // store each member's uid to update denormalized chats when create a service for sending messages
        self.memberUIDs = members.map { $0.uid }
    }
    
    static func hash(forMembers members: [User]) -> String {
        guard members.count == 2 else {
            fatalError("There must be two members to compute member hash.")
        }
        
        let firstMember = members[0]
        let secondMember = members[1]
        //XOR the two hashValues of each member's UID, XORing is commutative(no order matters)
        //to identify if a user already has an existing chat with another user
        let memberHash = String(firstMember.uid.hashValue ^ secondMember.uid.hashValue)
        return memberHash
    }    
}

