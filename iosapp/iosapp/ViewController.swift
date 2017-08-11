//
//  ViewController.swift
//  iosapp
//
//  Created by Sky Xu on 7/24/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import YelpAPI
import BrightFutures
//import GeoFire
import FirebaseDatabase
import Kingfisher
import FirebaseAuth
class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var runnerImage: UIImageView!
    @IBOutlet weak var map: MKMapView!
    var postalCode: String?
    var checker: String?
    var keyArr: [String]?
    //    get random bar within 1 mile of current location:userCoordinate
    let appId = "0NsM7ain72A2QREFFs9OjA"
    let appSecret = "F3JrqW9WU4ARGrJtzWg5FoMGdqRqIPEiq1L4MSznAsklpn2YCxDMFp1b47eVMq6E"
    let manager = CLLocationManager()
    var long: Double?
    var lat: Double?
    var userCoordinate : YLPCoordinate?

    func locationManager(_ manage: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
            
        self.long = Double((location?.coordinate.longitude)!)
        self.lat = Double((location?.coordinate.latitude)!)
        //map zoomed in aspect
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
        print(location!)
        self.manager.stopUpdatingLocation()
        self.manager.delegate = nil
        let currentUser = User.current
        let dataCoordinate = Location(lat: lat!, long: long!)
        let dict = dataCoordinate.dictValue
        let locationRef = Database.database().reference().child("location").child(currentUser.uid)
        locationRef.updateChildValues(dict)
        
        CLGeocoder().reverseGeocodeLocation((manager.location)!, completionHandler: {(CLPlacemark, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error: \(String(describing: error?.localizedDescription))")
                return
            }
            if (CLPlacemark?.count)!>0{
                let placemark = CLPlacemark?.last!
                self.postalCode = placemark!.postalCode
                
                let zipRef = Database.database().reference().child("zipcode").child(self.postalCode!).child("userUID")
                zipRef.setValue(currentUser.uid)
                let code = String(describing: self.postalCode!)
                
                let first2 = code.substring(to:code.index(code.startIndex, offsetBy: 2))
                self.checker = first2
                
                let zipGroupRef = Database.database().reference().child("zipGroup").child(first2).child(currentUser.uid)
                zipGroupRef.setValue(currentUser.uid)
                //    create an array of uids under the same zipcode of current user
                let checkerRef = Database.database().reference().child("zipGroup")
                checkerRef.child(first2).observeSingleEvent(of: .value, with: {(snapshot) in
                    let keyDict = snapshot.value as? [String: String]
                    let temp = keyDict!.keys.sorted()
                    self.keyArr = temp.filter{$0 != "\(currentUser.uid)"}
                })
                
            }else{
                print("no placemarks found")
            }
        })
        
        }
    
    @IBAction func BarButtonTapped(_ sender: UIButton) {
        let fakeCoordinate = YLPCoordinate(latitude: 23.293, longitude: -123.233)
//        userCoordinate = YLPCoordinate(latitude: lat!, longitude: long!)
        print(userCoordinate!)
        let query = YLPQuery(coordinate: fakeCoordinate)
        query.term = "bar"
        query.limit = 3
        
        YLPClient.authorize(withAppId: appId, secret: appSecret).flatMap { client in
            client.search(withQuery: query)
            }.onSuccess { search in
                if let topBusiness = search.businesses.first {
                    print("Top business: \(topBusiness.name)+\(topBusiness.categories.description.description)")
                    print(topBusiness.location.address)
//                    print(topBusiness.categories)
                } else {
                    print("No businesses found")
                }
        
            }.onFailure { error in
                print("Search errored: \(error)")
                exit(EXIT_FAILURE)
        }
        
    }
    
  override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
         manager.startUpdatingLocation()
    if (keyArr?.isEmpty) == nil {
        let fakeURL = URL(string: "https://img.usmagazine.com/social/katy-perry-taylor-swift-08322c54-b352-4a33-8d81-a57a3dc1b366.jpg")
        self.runnerImage.contentMode = .scaleAspectFit
        self.runnerImage.kf.setImage(with: fakeURL)
        print("Yo we done")
    } else {
        let randomUID = keyArr?[0]
        let queryRef = Database.database().reference().child("users").child(randomUID!)
        queryRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? [String : Any]
            let imageString = value?["profile_pic"] as? String ?? ""
            print(imageString)
            let profileImage = URL(string: imageString)
            self.runnerImage.contentMode = .scaleAspectFit
            self.runnerImage.kf.setImage(with: profileImage)
        })
     }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

