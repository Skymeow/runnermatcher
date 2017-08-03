//
//  CreateUsernameViewController.swift
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


class CreateUsernameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
//        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
//            selectedImageFromPicker = editedImage
//            profileImageView.image = selectedImageFromPicker
//        }else
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImageFromPicker = originalImage
            profileImageView.image = selectedImageFromPicker
//            UserService.create(for: profileImageView.image!)
        }
//        if let selectedImage = profileImageView{
//            profileImageView = selectedImage
//        }
        dismiss(animated: true, completion: nil)
        
    }
    
        
    @IBAction func nextButtonTapped(_ sender: UIButton) {
       UserService.create(for: profileImageView.image!)
        let firUser = Auth.auth().currentUser
        
        if let username = usernameTextField.text {
            if let miles = Double(milesTextField.text!) {
                if let age = Int(ageTextField.text!) {
                   
                    let currentUser = User(uid: (firUser?.uid)!, username: username, age: age, miles: miles, imageURL: "", imageHeight: 50) // temporary
                    
                    let dictValue = currentUser.dictValue
                    
                    UserService.createProfile(firUser!, dictValue: dictValue){ (user) in
                        guard let user = user else {
                            // handle error
                            return
                        }
                        
                        User.setCurrent(user, writeToUserDefaults: true)
                        
                        let initialViewController = UIStoryboard.initialViewController(for: .main)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                    }
                    let ref = Database.database().reference().child("users").child((firUser?.uid)!)
                    ref.setValue(dictValue) { (error, ref) in
                        if let error = error {
                            assertionFailure(error.localizedDescription)
                            return
                        }
                        ref.observeSingleEvent(of: .value, with: { (snapshot) in
                            _ = User(snapshot: snapshot)
                        })
                    }
                }
            }
        }

            
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 6
        profileImageView.clipsToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


// 1) In next button tapped, create dictionary of user attributes
// 2) Pass dictionary into UserService "create" method 
// 3) Modify "create" method in UserService so that it works with your attributes
