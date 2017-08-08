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



typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
    
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
                 UserService.saveToFirebase(user!, email: (user?.email!)!) { (data) in
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
