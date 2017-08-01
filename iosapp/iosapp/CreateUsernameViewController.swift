//
//  CreateUsernameViewController.swift
//  iosapp
//
//  Created by Sky Xu on 7/28/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import UIKit
import Foundation
import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseDatabase


class CreateUsernameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var milesTextField: UITextField!
    @IBOutlet weak var uploadPicture: UIButton!
    
    @IBAction func uploadPictureTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self 
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
        
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        
////        var selectedImageFromPicker: UIImage?
//        
//        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
//            profileImageView = editedImage
//        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
//            profileImageView = originalImage
//        }
//        if let selectedImage = profileImageView{
//            profile_image.image = selectedImage
//        }
//        dismiss(animated: true, completion: nil)
//    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let firUser = Auth.auth().currentUser,
            let username = usernameTextField.text,
            let miles = milesTextField.text,
            let age = ageTextField.text,
            let imageURL = profileImageView,
            let imageHeight: CGFloat = 50,
            !username.isEmpty else { return }
        
        // initialize
        let user = ["username" : username,
                         "miles" : miles,
                         "age" : age,
                         "imageURL" : imageURL,
                         "imageHeight" : imageHeight] as [String : Any]
        
        
        UserService.create(firUser, dictValue: user) { (user) in
            guard let user = user else {
                // handle error
                return
            }
            
            User.setCurrent(user, writeToUserDefaults: true)
            
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }
        //        maybe should delete this?
        let userAttrs = ["username": username]
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                _ = User(snapshot: snapshot)
            })
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 6

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


// 1) In next button tapped, create dictionary of user attributes
// 2) Pass dictionary into UserService "create" method 
// 3) Modify "create" method in UserService so that it works with your attributes
