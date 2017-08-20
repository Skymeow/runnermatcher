//
//  DestinationChoicesViewController.swift
//  iosapp
//
//  Created by Sky Xu on 8/19/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import UIKit

class DestinationChoicesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
//    @IBOutlet weak var label: UILabel!
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
        } else if foods[row] == "pizza"{
            pizzaSpinning()
        } else if foods[row] == "beers"{
            beerSpinning()
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
//        label.isHidden = true
        // Do any additional setup after loading the view.
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
