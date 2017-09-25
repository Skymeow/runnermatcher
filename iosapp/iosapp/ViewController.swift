//
//  ViewController.swift
//  iosapp
//
//  Created by Sky Xu on 7/24/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation
import MapKit
import YelpAPI
import BrightFutures
import FirebaseDatabase
import Kingfisher
import FirebaseAuth
import VideoBackground

class ViewController: UIViewController, CLLocationManagerDelegate {
    

    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var profileMiles: UILabel!

    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var detailConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailImg: UIImageView!
    @IBOutlet weak var popupConstraint: NSLayoutConstraint!
    @IBOutlet weak var modalImg: UIImageView!
    @IBOutlet weak var runnerImage: UIImageView!
    @IBOutlet weak var map: MKMapView!
    var postalCode: String?
    var checker: String?
    var keyArr: [String]?
    var newkeyArr: [String]?
    var displayedUID = ""
    //    get random bar within 1 mile of current location:userCoordinate
    let appId = "0NsM7ain72A2QREFFs9OjA"
    let appSecret = "F3JrqW9WU4ARGrJtzWg5FoMGdqRqIPEiq1L4MSznAsklpn2YCxDMFp1b47eVMq6E"
    let manager = CLLocationManager()
    var long: Double?
    var lat: Double?
    var userCoordinate : YLPCoordinate?
    var matchedCoordinate : YLPCoordinate?
    var location1 : CLLocation?
    var location2 : CLLocation?
    func locationManager(_ manage: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.long = Double((location?.coordinate.longitude)!)
        self.lat = Double((location?.coordinate.latitude)!)
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
                let code = String(describing: self.postalCode!)
                
                let first2 = code.substring(to:code.index(code.startIndex, offsetBy: 2))
                self.checker = first2
                
                let zipGroupRef = Database.database().reference().child("zipGroup").child(first2).child(currentUser.uid)
                zipGroupRef.setValue(currentUser.uid)
                let checkerRef = Database.database().reference().child("zipGroup")
                checkerRef.child(self.checker!).observeSingleEvent(of: .value, with: {(snapshot) in
                    let keyDict = snapshot.value as? [String: String]
                    let temp = keyDict!.keys.sorted()
                    let currentUser = User.current
                    self.keyArr = temp.filter{$0 != "\(currentUser.uid)"}
                    self.update()
                })
            }else{
                print("no placemarks found")
            }
        })
        
    }
    //    end of location manager
    func update(){
        if (self.keyArr?.isEmpty) == true {
            let fakeURL = URL(string: "https://img.usmagazine.com/social/katy-perry-taylor-swift-08322c54-b352-4a33-8d81-a57a3dc1b366.jpg")
            self.runnerImage.contentMode = .scaleAspectFit
            self.runnerImage.kf.setImage(with: fakeURL)
            print("Yo we done")
        }else{
            let randomIndex = Int(arc4random_uniform(UInt32((self.keyArr?.count)!)))
            let randomUID = self.keyArr?[randomIndex]
            self.displayedUID = randomUID!
            let checkRef = Database.database().reference().child("swiped").child(self.displayedUID).child("accepted")
            
            checkRef.observeSingleEvent(of: .value, with: {(snapshot) in
                if snapshot.hasChild(User.current.uid) {
                    let matcherRef = Database.database().reference().child("matchers")
                    let matchingRef = Database.database().reference().child("matching")
                    matcherRef.child(self.displayedUID).updateChildValues(["\(User.current.uid)":false])
                    matchingRef.child(User.current.uid).updateChildValues(["\(self.displayedUID)":false])
                } else {
                    print("no one likes you")
                }
            })
            let queryRef = Database.database().reference().child("users").child(randomUID!)
            queryRef.observeSingleEvent(of: .value, with: {(snapshot) in
                guard let value = snapshot.value as? [String : Any],
                    let firstName = value["first_name"] as? String,
                    let miles = value["miles"] as? Double,
                    let imageString = value["profile_pic"] as? String,
                    let detailString = value["imagURL"] as? String
                    else {
                        return
                }
                self.profileName.text = firstName
                self.profileMiles.text = String(format: "%.2f", miles)
                let profileImage = URL(string: imageString)
                self.runnerImage.contentMode = .scaleAspectFit
                self.runnerImage.kf.setImage(with: profileImage)
                let detailImage = URL(string: detailString)
                self.detailImg.contentMode = .scaleAspectFit
                self.detailImg.kf.setImage(with: detailImage)

            })
        }
        
    }
    
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let currentUser = User.current
        let translation = gestureRecognizer.translation(in: view)
        
        let label = gestureRecognizer.view!
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        let scale = min(abs(100 / xFromCenter), 1)
        
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale) // rotation.scaleBy(x: scale, y: scale) is now rotation.scaledBy(x: scale, y: scale)
        
        
        label.transform = stretchAndRotation
        
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            var acceptedOrRejected = ""
            var ignored =  [""]
            let swipedRef = Database.database().reference().child("swiped").child(currentUser.uid)
            if label.center.x < 100 {
                print("not chosen")
                acceptedOrRejected = "rejected"
                swipedRef.child("rejected").updateChildValues(["\(displayedUID)" : true])
                ignored.append("\(displayedUID)")
                
            } else if label.center.x > self.view.bounds.width - 100 {
                print("chosen")
                acceptedOrRejected = "accepted"
                swipedRef.child("accepted").updateChildValues(["\(displayedUID)" : true])
                ignored.append("\(displayedUID)")
                let matcherRef = Database.database().reference().child("matchers")
                let matchingRef = Database.database().reference().child("matching")
                matcherRef.child(displayedUID).updateChildValues(["\(User.current.uid)":true])
                matchingRef.child(User.current.uid).updateChildValues(["\(displayedUID)":true])
                
            }
            if acceptedOrRejected != "" && displayedUID != ""{
                //                 keyArr = keyArr?.filter{$0 != "\(displayedUID)"}
                keyArr = Array(Set(keyArr!).subtracting(ignored))
                update()
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            stretchAndRotation = rotation.scaledBy(x: 1, y: 1) // rotation.scaleBy(x: scale, y: scale) is now rotation.scaledBy(x: scale, y: scale)
            label.transform = stretchAndRotation
            
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
        }
        
    }
    //end wasDragged function
    
    //barbuttontapped is show pop out now
    @IBAction func BarButtonTapped(_ sender: UIButton) {
        
        popupConstraint.constant = 0
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()
        })
        let matchingRef = Database.database().reference().child("matching").child(User.current.uid)
        var matchedArr = [String]()
        let locationRef = Database.database().reference().child("location")
        matchingRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let matchDict = snapshot.value as? [String: Bool]
            for elem in matchDict! {
                if elem.value == true{
                    let matchedKey = elem.key
                    matchedArr.append(matchedKey)
                    let randomMatcher = Int(arc4random() % UInt32(matchedArr.count))
                    let matcherItem = matchedArr[randomMatcher]
                    locationRef.child(matcherItem).observeSingleEvent(of: .value, with: {(snapshot) in
                    let value = snapshot.value as? [String : Double]
                    let lat2 = value?["lat"]
                    let long2 = value?["long"]
                    self.location2 = CLLocation(latitude: lat2!, longitude: long2!)
                    let newlat2 = lat2!*(Double.pi/180)
                    let newlat1 = self.lat!*(Double.pi/180)
                    let dLon: CLLocationDegrees
                    let bx: CLLocationDegrees
                    let by: CLLocationDegrees
                    var latitude: CLLocationDegrees
                    var longitude: CLLocationDegrees
                     dLon = (long2! - self.long!)*(Double.pi/180)
                     bx = cos(newlat2) * cos(dLon)
                     by = cos(newlat2) * sin(dLon)
                     latitude = atan2(sin(newlat1) + sin(newlat2), sqrt((cos(newlat1) + bx) * (cos(newlat1) + bx) + by*by))
                     longitude = self.long!*(Double.pi/180) + atan2(by, cos(newlat1) + bx)
                    longitude = longitude*(180/Double.pi)
                    latitude = latitude*(180/Double.pi)
                        print(latitude)
                    
//                    yelpQuery
                        self.location1 = CLLocation(latitude: self.lat!, longitude: self.long!)
//                        let distanceInMeters = self.location2?.distance(from: self.location1!)
//                        updte midpoint location to firebase
                        let fakeCoordinate = YLPCoordinate(latitude: latitude, longitude: longitude)
                        let midDict = ["lat":latitude,"long":longitude]
                        let midpointRef = Database.database().reference().child("midpoint").child(User.current.uid).child(matcherItem)
                            midpointRef.updateChildValues(midDict)
                        let query = YLPQuery(coordinate: fakeCoordinate)
                        query.term = "bar"
                        query.limit = 3
                        YLPClient.authorize(withAppId: self.appId, secret: self.appSecret).flatMap { client in
                            client.search(withQuery: query)
                            }.onSuccess { search in
                                if let topBusiness = search.businesses.first {
                                    print("Top business: \(topBusiness.name)")
//                                    .url is yelp on safari
                                    let barImg = topBusiness.imageURL
                                    self.modalImg.contentMode = .scaleAspectFit
                                    
                                    self.modalImg.kf.setImage(with: barImg)
                                } else {
                                    print("No businesses found")
                                }
                                
                            }.onFailure { error in
                                print("Search errored: \(error)")
                                exit(EXIT_FAILURE)
                        }
                    })
                }
            }
            
        })
    }
    
    
    @IBAction func popupClosed(_ sender: UIButton) {
        popupConstraint.constant = -400
        UIView.animate(withDuration: 0.1, animations: {self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func backgroundDetailTapped(_ sender: Any) {
        detailConstraint.constant = -400
        UIView.animate(withDuration: 0.1, animations: {self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func detailClicked(_ sender: Any) {
        
        detailConstraint.constant = 133
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()
        })
    }
    
    func removeSubview(){
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
            
        }else{
            print("No!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let videoPath = Bundle.main.path(forResource: "run", ofType:"mp4")
        let imagePath = Bundle.main.path(forResource: "runner", ofType: "jpeg")!
        let options = VideoOptions(pathToVideo: videoPath!, pathToImage: imagePath, isMuted: true, shouldLoop: true)
        let videoView = VideoBackground(frame: view.frame, options: options)
        videoView.tag = 100
        videoView.isUserInteractionEnabled = true
        view.addSubview(videoView)
        
        let aSelector : Selector = #selector(ViewController.removeSubview)
        let tapGesture = UITapGestureRecognizer(target:self, action: aSelector)
        videoView.addGestureRecognizer(tapGesture)
        
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 30))
        textLabel.center = CGPoint(x: 160, y: 285)
        textLabel.textAlignment = .center
        textLabel.isUserInteractionEnabled = true
        self.view.addSubview(textLabel)
        textLabel.fadeIn(completion: {
            (finished: Bool) -> Void in
            textLabel.text = "Tap screen to get started!"
        })
        
        textLabel.fadeOut()
      
    //for location manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        //    handle swiping
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        runnerImage.isUserInteractionEnabled = true
        runnerImage.addGestureRecognizer(gesture)
        //for popup
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        detailView.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}

extension UIView {

    func fadeIn(_ duration: TimeInterval = 5.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 9.0, delay: TimeInterval = 1.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}

