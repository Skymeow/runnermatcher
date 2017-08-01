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
//import GeoFire
import FirebaseDatabase

class ViewController: UIViewController ,CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    let manager = CLLocationManager()
    
    func locationManager(_ manage: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        //map zoomed in aspect
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        print(location.altitude)
        print(location.speed)

        
        self.map.showsUserLocation = true
        
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

    }
    @IBOutlet weak var getGeoButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

