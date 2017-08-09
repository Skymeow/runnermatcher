//
//  LoginViewController.swift
//  iosapp
//
//  Created by Sky Xu on 7/28/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//
import UIKit
import Foundation
import FirebaseAuth
import FirebaseAuthUI
import FirebaseDatabase
import FirebaseFacebookAuthUI
import Firebase
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit



typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
    var profile_pic: String?
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            //                get facebook profile picture
//            func getFBUserData() {
                let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
                let _ = request?.start(completionHandler: { (connection, result, error) in
                    guard let userInfo = result as? [String: Any] else { return } //handle the error
                    
                    //The url is nested 3 layers deep into the result so it’s pretty messy
                    if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        print(imageURL)//Download image from imageURL
                        self.profile_pic = imageURL
                        //                            if let checkedUrl = URL(string: imageURL) {
                        //                                self.grabURL = checkedUrl
                        //                                self.profilePicture.contentMode = .scaleAspectFit
                        //                                self.downloadImage(url: checkedUrl)
                        //                            }
                    }
                })
//            }

            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
                //add a completion handler to make uid create first
                
                UserService.saveToFirebase(user!, email: (user?.email!)!, profile_pic: self.profile_pic!) { (data) in
                    guard let user = data
                        else {  return  }
                    User.setCurrent(user, writeToUserDefaults: true)
                    self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
                    //                    let initialViewController = UIStoryboard.initialViewController(for: .main)
                    //                    self.view.window?.rootViewController = initialViewController
                    //                    self.view.window?.makeKeyAndVisible()
                }
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
}
