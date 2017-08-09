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
    //    let miles: Double
    //    let age: Int
    //    let imageHeight: CGFloat
    let email: String
    var dictValue: [String : Any] {
        get{
            return ["email" : email,
                    "profile_pic" : profile_pic
                //            "username" : username,
                //                "miles" : miles,
                //                "age" : age,
                //                "imageHeight" : imageHeight
            ]
        }
    }
    // MARK: - Init
    
    init(uid: String, email: String, profile_pic: String) {
        self.uid = uid
        self.email = email
                self.profile_pic = profile_pic
        //        self.miles = miles
        //        self.imageHeight = imageHeight
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let email = dict["email"] as? String,
                        let profile_pic = dict["profile_pic"] as? String
            //            let miles = dict["miles"] as? Double,
            //            let age = dict["age"] as? Int,
            //            let imageHeight = dict["imageHeight"] as? CGFloat
            else { return nil }
        self.uid = snapshot.key
        self.email = email
                self.profile_pic = profile_pic
        //        self.miles = miles
        //        self.age = age
        //        self.imageHeight = imageHeight
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let email = aDecoder.decodeObject(forKey: Constants.UserDefaults.email) as? String,
            let profile_pic = aDecoder.decodeObject(forKey: Constants.UserDefaults.profile_pic) as? String
            //            let age = aDecoder.decodeObject(forKey: Constants.UserDefaults.age) as? Int,
            //            let imageHeight = aDecoder.decodeObject(forKey: Constants.UserDefaults.imageHeight) as? CGFloat
            
            else { return nil }
        self.uid = uid
        self.email = email
        self.profile_pic = profile_pic
        //        self.age = age
        //        self.imageHeight = imageHeight
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
        aCoder.encode(email, forKey: Constants.UserDefaults.email)
                aCoder.encode(profile_pic, forKey: Constants.UserDefaults.profile_pic)
        //        aCoder.encode(miles, forKey: Constants.UserDefaults.miles)
        //        aCoder.encode(imageHeight, forKey: Constants.UserDefaults.imageHeight)
    }
}
