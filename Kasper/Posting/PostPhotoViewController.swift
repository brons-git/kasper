//
//  PostPhotoViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/25/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import RxSwift
import RxCocoa

class PostPhotoViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Outlets
    @IBOutlet weak var userImagePicker: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Variables
    var imagePicker: UIImagePickerController!
    var imageSelected = false

    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Image Picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
    }
    
    // Cancel
    @IBAction func cancelButtonTapped(_ sender: Any) {
        let showProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
        self.present(showProfileVC!, animated: false, completion: nil)
    }
    
    // Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userImagePicker.image = image
            imageSelected = true
            self.userImagePicker.clipsToBounds = true
        } else {
            print("image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    @IBAction func selectedImgPicker (_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Store Data
    @IBAction func storeData(_ sender: UIButton) {
        if imageSelected == true {
            let imgData = UIImageJPEGRepresentation(self.userImagePicker.image!, 0.2)
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Storage.storage().reference().child("users").child(uid).child("profile_posts").child(imgUid).putData(imgData!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("did not upload img")
                } else {
                    print("uploaded")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    let uid = Auth.auth().currentUser?.uid
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dateString = formatter.string(from: date)
                    let value = [dateString : downloadURL] as [String : AnyObject]
                    Database.database().reference().child("users_profile_posts_photos").child(uid!).updateChildValues(value, withCompletionBlock: { (err, ref) in
                        if error != nil {
                            print("Error with upload!")
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = "*UPLOAD IMAGE*"
                        } else {
                            print("Successfully saved post data to db")
                            let showProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
                            self.present(showProfileVC!, animated: false, completion: nil)
                        }
                    }
                )}
            }
        }
    }
}
