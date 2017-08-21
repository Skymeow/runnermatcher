//
//  DestinationChoicesViewController.swift
//  iosapp
//
//  Created by Sky Xu on 8/19/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import YelpAPI
import BrightFutures
import FirebaseDatabase
import FirebaseAuth
import SafariServices

class DestinationChoicesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var lat: Double!
    var long: Double!
    let appId = "0NsM7ain72A2QREFFs9OjA"
    let appSecret = "F3JrqW9WU4ARGrJtzWg5FoMGdqRqIPEiq1L4MSznAsklpn2YCxDMFp1b47eVMq6E"
    var fakeCoordinate: YLPCoordinate?
    var searchItem:String?
    var resultUrl: URL?
    @IBAction func gotapped(_ sender: Any) {
        self.YelpSearch()
    }
    @IBOutlet weak var pickerView: UIPickerView!
    
    let foods = ["pizza", "ice cream", "beers"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component:Int)->String?{
        return foods[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int)->Int{
        return foods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        //        label.text = foods[row]
        if foods[row] == "ice cream"{
            icecreamSpinning()
            self.searchItem = "ice cream"
        } else if foods[row] == "pizza"{
            pizzaSpinning()
            self.searchItem = "pizza"
        } else if foods[row] == "beers"{
            beerSpinning()
            self.searchItem = "beer"
        }
    }
    
    
    func getmid(){
        var matchedArr = [String]()
        let matchingRef = Database.database().reference().child("matching").child(User.current.uid)
        
        matchingRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let matchDict = snapshot.value as? [String: Bool]
            for elem in matchDict! {
                if elem.value == true{
                    let matchedKey = elem.key
                    matchedArr.append(matchedKey)
                    let randomMatcher = Int(arc4random() % UInt32(matchedArr.count))
                    let matcherItem = matchedArr[randomMatcher]
                    
                    let midRef = Database.database().reference().child("midpoint").child(User.current.uid).child(matcherItem)
                    midRef.observeSingleEvent(of: .value, with:{(snapshot) in
                        guard let value = snapshot.value as? [String : Any],
                            let templat = value["lat"],
                            let templong = value["long"]
                            else {
                                return
                        }
                        self.lat = templat as! Double
                        self.long = templong as! Double
                        self.fakeCoordinate = YLPCoordinate(latitude: self.lat, longitude: self.long)
                    })
                    
                } else {
                    print("no one likes you")
                }
            }
        })
    }
    
    func YelpSearch(){
       let query = YLPQuery(coordinate: fakeCoordinate!)
        query.term = self.searchItem!
        query.limit = 3
        query.radiusFilter = 5000
        YLPClient.authorize(withAppId: self.appId, secret: self.appSecret).flatMap { client in
            client.search(withQuery: query)
            }.onSuccess { search in
                if let topBusiness = search.businesses.first {
                    print("Top business: \(topBusiness.name)")
                    self.resultUrl = topBusiness.url
                    let vc = SFSafariViewController(url: self.resultUrl!, entersReaderIfAvailable: true)
                    self.present(vc, animated: true)
//                    let barImg = topBusiness.imageURL
//                    self.modalImg.contentMode = .scaleAspectFit
//                    
//                    self.modalImg.kf.setImage(with: barImg)
                } else {
                    print("No businesses found")
                }
                
            }.onFailure { error in
                print("Search errored: \(error)")
                exit(EXIT_FAILURE)
        }
    }
    
    @IBOutlet weak var icon1: UIImageView!
    
    @IBOutlet weak var icon2: UIImageView!
    
    
    @IBOutlet weak var icon3: UIImageView!
    
    @IBOutlet weak var icon4: UIImageView!
    
    @IBOutlet weak var icon5: UIImageView!
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
        
    }
    
    func icecreamSpinning() {
        icon1.image = UIImage(named:"icecream")
        icon1.startRotating()
        icon2.image = UIImage(named:"icecream")
        icon2.startRotating()
        icon3.image = UIImage(named:"icecream")
        icon3.startRotating()
        icon4.image = UIImage(named:"icecream")
        icon4.startRotating()
        icon5.image = UIImage(named:"icecream")
        icon5.startRotating()
    }
    
    func pizzaSpinning() {
        icon1.image = UIImage(named:"pizza")
        icon1.startRotating()
        icon2.image = UIImage(named:"pizza")
        icon2.startRotating()
        icon3.image = UIImage(named:"pizza")
        icon3.startRotating()
        icon4.image = UIImage(named:"pizza")
        icon4.startRotating()
        icon5.image = UIImage(named:"pizza")
        icon5.startRotating()
    }
    
    func beerSpinning() {
        icon1.image = UIImage(named:"beer")
        icon1.startRotating()
        icon2.image = UIImage(named:"beer")
        icon2.startRotating()
        icon3.image = UIImage(named:"beer")
        icon3.startRotating()
        icon4.image = UIImage(named:"beer")
        icon4.startRotating()
        icon5.image = UIImage(named:"beer")
        icon5.startRotating()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getmid()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension UIView {
    func startRotating(duration: Double = 1) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(Double.pi * 2.0)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    //    func stopRotating() {
    //        let kAnimationKey = "rotation"
    //        
    //        if self.layer.animation(forKey: kAnimationKey) != nil {
    //            self.layer.removeAnimation(forKey: kAnimationKey)
    //        }
    //    }
}
