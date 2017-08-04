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

    
}

