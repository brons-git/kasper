//
//  NewPostViewController.swift
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

class NewPostViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProPic()
        postText.becomeFirstResponder()
    }

    // Did Recieve Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Setup Profile Picture
    func setupProPic() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let proPicRefe = snapshot.value as? String
            let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe!)
            if let proPicUrl = proPicUrlRefe as URL? {
                self.profilePic.sd_setImage(with: proPicUrl)
                self.profilePic.layer.cornerRadius = 20.0
                self.profilePic.clipsToBounds = true
            }
        })
    }
    
    // Store Data
    @IBAction func storeData(_ sender: UIButton) {
        self.postButton.isEnabled = false
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let username = snapshot.value as? String
            Database.database().reference().child("users").child(uid!).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                let rank = snapshot.value as? String
                Database.database().reference().child("users").child(uid!).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    let propicref = snapshot.value as? String
                    let text = self.postText.text
                    if text == "" {
                        print("ERRORRRRRRRRRRRRRRRRRRRRRRR")
                        print("ERRORRRRRRRRRRRRRRRRRRRRRRR")
                        print("ERRORRRRRRRRRRRRRRRRRRRRRRR")
                        print("ERRORRRRRRRRRRRRRRRRRRRRRRR")
                        print("ERRORRRRRRRRRRRRRRRRRRRRRRR")
                        return
                    } else {
                        let date = Date()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateString = formatter.string(from: date)
                        let dictionary = ["postType": "text",
                                          "id": uid,
                                          "date": dateString,
                                          "textPost": text,
                                          "imagePost": "",
                                          "username": username,
                                          "rank": rank,
                                          "propicref": propicref] as [String : AnyObject]
                        let values = [dateString: dictionary] as [String : AnyObject]
                        Database.database().reference().child("users_feed_posts").updateChildValues(values, withCompletionBlock: { (err, ref) in
                            let postDict = [dateString: dictionary] as [String : AnyObject]
                            Database.database().reference().child("users_profile_posts").child(uid!).updateChildValues(postDict, withCompletionBlock: { (err, ref) in
                            if err != nil {
                                print("Error with upload!")
                            } else {
                                print("Successfully saved post data to db")
                                //let showProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
                                //self.present(showProfileVC!, animated: false, completion: nil)
                                self.dismiss(animated: false, completion: nil)
                                }
                            })
                        })
                    }
                })
            })
        }
    )}
    
    // Cancel
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
