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
    let username: String
//    let email: String
    let miles: Double
    let age: Int
    let imageURL: String
    let imageHeight: CGFloat
    var dictValue: [String : Any] {
        get{
        return ["username" : username,
//                "email" : email,
                "miles" : miles,
            "age" : age,
            "imageURL" : imageURL,
            "imageHeight" : imageHeight]
        }
    }
    // MARK: - Init
    
    init(uid: String, username: String, age: Int, miles: Double, imageURL: String, imageHeight: CGFloat) {
        self.uid = uid
        self.username = username
//        self.email = email
        self.age = age
        self.miles = miles
        self.imageURL = imageURL
        self.imageHeight = imageHeight
    }
    //    backup init , if  required init doesn't happen
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
            let miles = dict["miles"] as? Double,
            let age = dict["age"] as? Int,
            let imageURL = dict["imageURL"] as? String,
            let imageHeight = dict["imageHeight"] as? CGFloat
            else { return nil }
        self.uid = snapshot.key
        self.username = username
        self.miles = miles
        self.age = age
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String,
//            let email = aDecoder.decodeObject(forKey: Constants.UserDefaults.email) as? String,
            let miles = aDecoder.decodeObject(forKey: Constants.UserDefaults.miles) as? Double,
            let age = aDecoder.decodeObject(forKey: Constants.UserDefaults.age) as? Int,
            let imageURL = aDecoder.decodeObject(forKey: Constants.UserDefaults.imageURL) as? String,
            let imageHeight = aDecoder.decodeObject(forKey: Constants.UserDefaults.imageHeight) as? CGFloat
        
            else { return nil }
        self.uid = uid
//        self.email = email
        self.username = username
        self.miles = miles
        self.age = age
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        super.init()
    }
    
    private static var _current: User?
    
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }
    
    static func setCurrent(_ user: User) {
        _current = user
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
//        aCoder.encode(email, forKey: Constants.UserDefaults.email)
        aCoder.encode(username, forKey: Constants.UserDefaults.username)
        aCoder.encode(age, forKey: Constants.UserDefaults.age)
        aCoder.encode(miles, forKey: Constants.UserDefaults.miles)
        aCoder.encode(imageURL, forKey: Constants.UserDefaults.imageURL)
        aCoder.encode(imageHeight, forKey: Constants.UserDefaults.imageHeight)
    }
}

