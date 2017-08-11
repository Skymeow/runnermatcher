//
//  Zipcode.swift
//  iosapp
//
//  Created by Sky Xu on 8/10/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase.FIRDataSnapshot

//class Zipcode {
//    var key: String?
//    let lat: Double
//    let long: Double
//    
//    var dictValue: [String: Any] {
//        return ["lat" : lat,
//                "long" : long]
//    }
//    
//    init(lat: Double, long: Double) {
//        self.lat = lat
//        self.long = long
//    }
//    
//    init?(snapshot: DataSnapshot) {
//        guard let dict = snapshot.value as?[String: Any],
//            let lat = dict["lat"] as? Double,
//            let long = dict["long"] as? Double
//            else { return nil }
//        self.lat = lat
//        self.long = long
//        
//    }
//}
