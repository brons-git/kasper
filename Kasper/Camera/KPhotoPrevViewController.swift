//
//  KPhotoPrevViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 9/24/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase

class KPhotoPrevViewController: UIViewController {

    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    
    // Variables
    var takenPhoto: UIImage?
    var image = UIImage()
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.isEnabled = true

        // Initialize
        banCheck()
        
        // Check for available image to display.
        if let availableImage = takenPhoto {
            imageView.image = availableImage
        }
        
    }
    
    // Check if user is banned
    func banCheck() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let rank = snapshot.value as? String
            if rank == "banned" {
                let banAlert = self.storyboard?.instantiateViewController(withIdentifier: "banAlertVC")
                self.present(banAlert!, animated: false, completion: nil)
            }
            if rank != "banned" {
                print("Not banned")
            }
        })
    }
    
    // Cancel
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Save Media to Camera Roll
    @IBAction func saveButton(_ sender: Any) {
        saveBtn.isEnabled = false
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    // Post Photo
    @IBAction func postPhoto(_ sender: Any) {
        self.postBtn.isEnabled = false
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let username = snapshot.value as? String
            if let imgData = UIImageJPEGRepresentation(self.image, 0.2) {
                let imgUid = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Storage.storage().reference().child("users").child(uid).child("posted_photos").child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print("did not upload img")
                        return
                    } else {
                        print("uploaded")
                        let downloadURL = metadata?.downloadURL()?.absoluteString
                        let date = Date()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateString = formatter.string(from: date)
                        let dictionary = ["postType": "photo",
                                            "id": uid,
                                            "date": dateString,
                                            "textPost": "",
                                            "imagePost": downloadURL,
                                            "username": username] as [String : AnyObject]
                        let values = [dateString: dictionary] as [String : AnyObject]
                        Database.database().reference().child("users_feed_posts").updateChildValues(values, withCompletionBlock: { (err, ref) in
                            let postDict = [dateString: dictionary] as [String : AnyObject]
                            Database.database().reference().child("users_profile_posts").child(uid).updateChildValues(postDict, withCompletionBlock: { (err, ref) in
                                if err != nil {
                                    print("Error with upload!")
                                } else {
                                    print("Successfully saved post data to db")
                                    self.dismiss(animated: false, completion: nil)
                                }
                            }
                        )}
                    )}
                }
            }
        }
    )}
}
