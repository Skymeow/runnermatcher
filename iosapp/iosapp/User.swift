//
//  User.swift
//  iosapp
//
//  Created by Sky Xu on 7/24/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    
    // MARK: - Properties
    //var isFollowed = false
    let uid: String
    let profile_pic: String
    let first_name: String
//    let email: String
    let gender: String
    var dictValue: [String : Any] {
        get{
            return ["profile_pic" : profile_pic,
                    "first_name" : first_name,
                    "gender" : gender
                    ]
        }
    }
    // MARK: - Init
    
    init(uid: String,profile_pic: String, first_name: String, gender: String) {
        self.uid = uid
        self.first_name = first_name
        self.profile_pic = profile_pic
        self.gender = gender
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let profile_pic = dict["profile_pic"] as? String,
            let first_name = dict["first_name"] as? String,
            let gender = dict["gender"] as? String
            else { return nil }
            self.uid = snapshot.key
            self.first_name = first_name
            self.profile_pic = profile_pic
            self.gender = gender
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let profile_pic = aDecoder.decodeObject(forKey: Constants.UserDefaults.profile_pic) as? String,
            let first_name = aDecoder.decodeObject(forKey: Constants.UserDefaults.first_name) as? String,
            let gender = aDecoder.decodeObject(forKey: Constants.UserDefaults.gender) as? String
            else { return nil }
        self.uid = uid
        self.profile_pic = profile_pic
        self.first_name = first_name
        self.gender = gender
        super.init()
    }
    
    private static var _current: User?
    
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }
    
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        _current = user
    }
    
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(profile_pic, forKey: Constants.UserDefaults.profile_pic)
        aCoder.encode(first_name, forKey: Constants.UserDefaults.first_name)
    }
}
