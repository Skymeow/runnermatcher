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

class ViewController: UIViewController, CLLocationManagerDelegate {
//    temporary as bar image , change into user img after
    @IBOutlet weak var barImage: UIImageView!
    @IBOutlet weak var map: MKMapView!
//    get random bar within 1 mile of current location:userCoordinate
    var userCoordinate : YLPCoordinate?
    let appId = "0NsM7ain72A2QREFFs9OjA"
    let appSecret = "F3JrqW9WU4ARGrJtzWg5FoMGdqRqIPEiq1L4MSznAsklpn2YCxDMFp1b47eVMq6E"
    
    let manager = CLLocationManager()
    func locationManager(_ manage: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let long = Double((location?.coordinate.longitude)!)
        let lat = Double((location?.coordinate.latitude)!)
        //map zoomed in aspect
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
//        userCoordinate = YLPCoordinate(latitude: newLat, longitude: newLong)
        let currentUser = User.current
        let dataLocation = Location(lat: lat, long: long)
        let dict = dataLocation.dictValue
        let locationRef = Database.database().reference().child("location").child(currentUser.uid).childByAutoId()
        locationRef.updateChildValues(dict)
        
        self.map.showsUserLocation = true
    }
    
    
    
    @IBAction func BarButtonTapped(_ sender: UIButton) {
        let query = YLPQuery(coordinate: userCoordinate!)
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
    
    
    
    @IBAction func getGeoButtontapped(_ sender: UIButton) {
//        let geofireRef = Database.database().reference()
//        let geoFire = GeoFire(firebaseRef: geofireRef)
//        geoFire?.getLocationForKey("firebase-hq", withCallback: { (location, error) in
//            if (error != nil) {
//                print("An error occurred getting the location for \"firebase-hq\": \(error?.localizedDescription)")
//            } else if (location != nil) {
//                print("Location for \"firebase-hq\" is [\(location?.coordinate.latitude), \(location?.coordinate.longitude)]")
//            } else {
//                print("GeoFire does not contain a location for \"firebase-hq\"")
//            }
//        })
//
    }
       override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.distanceFilter = 1;
        manager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

