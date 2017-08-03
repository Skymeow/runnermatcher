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
    
    //    @IBOutlet weak var loginFirstButton: UIButton!
    
    //    @IBAction func loginButtonTapped(_ sender: UIButton) {
    //        //         guard let authUI = FUIAuth.defaultAuthUI()
    //            else {return}
    //                authUI.delegate = self
    //        // configure Auth UI for Facebook login
    //        let providers: [FUIAuthProvider] = [FUIFacebookAuth()]
    //        authUI.providers = providers
    //
    //        let authViewController = authUI.authViewController()
    //        present(authViewController, animated: true)
    
    //    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        loginButton.delegate = self
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}




extension LoginViewController: FBSDKLoginButtonDelegate {
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let accessToken = FBSDKAccessToken.current() else {
            print("Access failed")
            return
        }
        
        
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                assertionFailure("Error signing in: \(error.localizedDescription)")
            } else {
                guard let user = user
                    else {  return  }
                
                UserService.show(forUID: user.uid) { (user) in
                    if let user = user {
                        // handle existing user
                        User.setCurrent(user, writeToUserDefaults: true)
                        
                        let initialViewController = UIStoryboard.initialViewController(for: .main)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                    } else {
                        // handle new user
                        self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("did log out?")
    }
}
