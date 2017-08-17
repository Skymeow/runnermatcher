//
//  ChatService.swift
//  iosapp
//
//  Created by Sky Xu on 8/16/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import FirebaseDatabase
import Foundation
struct ChatService {
    static func create(from message: Message, with chat: Chat, completion: @escaping (Chat?) -> Void) {
        
        // create a dic of each member's UID
        var membersDict = [String : Bool]()
        for uid in chat.memberUIDs {
            membersDict[uid] = true
        }
        
        // populate our chat object with missing data from the first mes sent(not to create each chat till the first mes is sent
        let lastMessage = "\(message.sender.first_name): \(message.content)"
        chat.lastMessage = lastMessage
        let lastMessageSent = message.timestamp.timeIntervalSince1970
        chat.lastMessageSent = message.timestamp
        
        // create a dic of the chat json object to be stored in database
        let chatDict: [String : Any] = ["title" : chat.title,
                                        "memberHash" : chat.memberHash,
                                        "members" : membersDict,
                                        "lastMessage" : lastMessage,
                                        "lastMessageSent" : lastMessageSent]
        
        // generate a location for a new child of the chat
        let chatRef = Database.database().reference().child("chats").child(User.current.uid).childByAutoId()
        chat.key = chatRef.key
        
        // create a muti-location update dic, so we can write to multi locations without making api requests
        var multiUpdateValue = [String : Any]()
        
        // update each of chat member's chats with denormalized chat json object
        for uid in chat.memberUIDs {
            multiUpdateValue["chats/\(uid)/\(chatRef.key)"] = chatDict
        }
        
        // create new ref for a new mesg child
        let messagesRef = Database.database().reference().child("messages").child(chatRef.key).childByAutoId()
        let messageKey = messagesRef.key
        
        // set key value of multi-lopcation update dic to write new mesg data
        multiUpdateValue["messages/\(chatRef.key)/\(messageKey)"] = message.dictValue
        
        // multi-location update to return chat if success
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            
            completion(chat)
        }
    }
    
    static func checkForExistingChat(with user: User, completion: @escaping (Chat?) -> Void) {
        // get hash value from each member's UIDs using Chat class
        let members = [user, User.current]
        let hashValue = Chat.hash(forMembers: members)
        
        // check for existing chat with the other member
        let chatRef = Database.database().reference().child("chats").child(User.current.uid)
        
        // query for matching memberHash child value of each chat
        let query = chatRef.queryOrdered(byChild: "memberHash").queryEqual(toValue: hashValue)
        
        // return corresponding Chat if exists
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let chatSnap = snapshot.children.allObjects.first as? DataSnapshot,
                let chat = Chat(snapshot: chatSnap)
                else { return completion(nil) }
            
            completion(chat)
        })
    }
    
    static func sendMessage(_ message: Message, for chat: Chat, success: ((Bool) -> Void)? = nil) {
        guard let chatKey = chat.key else {
            success?(false)
            return
        }
        
        var multiUpdateValue = [String : Any]()
        
        for uid in chat.memberUIDs {
            let lastMessage = "\(message.sender.first_name): \(message.content)"
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessage"] = lastMessage
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessageSent"] = message.timestamp.timeIntervalSince1970
        }
        
        let messagesRef = Database.database().reference().child("messages").child(chatKey).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["messages/\(chatKey)/\(messageKey)"] = message.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            success?(true)
        })
    }
    
    static func observeMessages(forChatKey chatKey: String, completion: @escaping (DatabaseReference, Message?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child("messages").child(chatKey)
        
        return messagesRef.observe(.childAdded, with: { snapshot in
            guard let message = Message(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
            
            completion(messagesRef, message)
        })
    }
}

