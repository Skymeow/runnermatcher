//
//  UserService.swift
//  iosapp
//
//  Created by Sky Xu on 7/24/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase
import UIKit
import FirebaseStorage


struct UserService {
    
    static func saveToFirebase(_ user: FIRUser, profile_pic: String, first_name: String, gender: String, completion: @escaping (User?) -> Void) {
        let ref =  Database.database().reference().child("users").child((user.uid))
        let userAttrs = ["profile_pic": profile_pic, "first_name": first_name, "gender": gender]
        ref.setValue(userAttrs){ (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
                
            })
        }
    }
    
    static func create(for image: UIImage) {
        let ref = Database.database().reference().child("users").child("\(String(describing: Auth.auth().currentUser!.uid))")
        let imageRef = StorageReference.newProfileImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            print("3333333333333333333333333image url: \(urlString)")
            ref.updateChildValues(["imagURL":urlString])
        }
    }
    
    
    static func createProfile(_ firUser: FIRUser, dictValue: [String : Any] , completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child("\(String(describing: Auth.auth().currentUser?.uid))")
        ref.setValue(dictValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
                
            })
        }
    }
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        //let ref = DatabaseReference.toLocation(.showUser(uid: uid))
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            completion(user)
        })
    }
    
    static func observeChats(for user: User = User.current, withCompletion completion: @escaping (DatabaseReference, [Chat]) -> Void) -> DatabaseHandle {
        let ref = Database.database().reference().child("chats").child(user.uid)
        //if DataeventType is triggered, the completion handler is executed
        //if a new message is sent and lastmes is modified, the completion handler will be executed again
        return ref.observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(ref, [])
            }
            
            let chats = snapshot.flatMap(Chat.init)
            completion(ref, chats)
        })
    }
//retrieve users that current user has matched with 
    static func matching(for user: User = User.current, completion: @escaping ([User]) -> Void) {
        // 1
        let matchingRef = Database.database().reference().child("matching").child(user.uid)
        matchingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // 2
            guard let matchingDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            // 3
            var matching = [User]()
            let dispatchGroup = DispatchGroup()
            
            for uid in matchingDict.keys {
                dispatchGroup.enter()
                
                show(forUID: uid) { user in
                    if let user = user {
                        matching.append(user)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            // 4
            dispatchGroup.notify(queue: .main) {
                completion(matching)
            }
        })
    }
    
}
