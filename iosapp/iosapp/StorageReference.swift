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

extension StorageReference {
    static let dateFormatter = ISO8601DateFormatter()
       static func newProfileImageReference() -> StorageReference {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/users/\(uid)/\(timestamp).jpg")
    }
}
