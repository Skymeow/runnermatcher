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
import FirebaseStorage

class CreateUsernameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
//    @IBOutlet weak var milesTextField: UITextField!
    @IBOutlet weak var uploadPicture: UIButton!
    
    @IBOutlet weak var milesLabel: UILabel!
    @IBAction func slider(_ sender: UISlider) {
        milesLabel.text = String(Double(sender.value))
    }
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
        let firUser = Auth.auth().currentUser
        if let miles = Double(milesLabel.text!) {
               
            let ref = Database.database().reference().child("users").child((firUser!.uid))
                        ref.updateChildValues(["miles": miles])
            UserService.create(for: self.profileImageView.image!)
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
                    
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

