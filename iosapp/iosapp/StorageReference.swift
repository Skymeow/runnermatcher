//
//  StorageReference.swift
//  iosapp
//
//  Created by Sky Xu on 8/1/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import Foundation
import FirebaseStorage
import UIKit
import FirebaseAuth

extension StorageReference {
    static let dateFormatter = ISO8601DateFormatter()
       static func newProfileImageReference() -> StorageReference {
        let uid = Auth.auth().currentUser?.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/users/\(String(describing: uid))/\(timestamp).jpg")
    }
}
