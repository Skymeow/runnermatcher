//
//  Message.swift
//  
//
//  Created by Sky Xu on 8/16/17.
//
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import JSQMessagesViewController
import JSQMessagesViewController.JSQMessage

class Message {
    var key: String?
    let content: String
    let timestamp: Date
    let sender: User
    //  initialization is delayed to runtime whenever the object is first referenced.
    lazy var jsqMessageValue: JSQMessage = {
        return JSQMessage(senderId: self.sender.uid,
                          senderDisplayName: self.sender.first_name,
                          date: self.timestamp,
                          text: self.content)
    }()
    var dictValue: [String : Any] {
        let userDict = ["first_name" : sender.first_name,
                        "uid" : sender.uid]
        return ["sender" : userDict,
                "content" : content,
                "timestamp" : timestamp.timeIntervalSince1970]
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval,
            let userDict = dict["sender"] as? [String : Any],
            let uid = userDict["uid"] as? String,
            let first_name = userDict["first_name"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.content = content
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.sender = User(uid: uid, email: "", profile_pic: "", first_name: first_name, gender:"")
    }
    
    //add another init method to create a message given content as an argument
    init(content: String) {
        self.content = content
        self.timestamp = Date()
        self.sender = User.current
    }
}
