//
//  CameraPreviewMediaViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/6/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import AVKit
import Firebase

class CameraPreviewMediaViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var photo: UIImageView!
    var image = UIImage()

    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
    }
    
    // Cancel
    @IBAction func cancelButton(_ sender: Any) {
        let showCameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC")
        self.present(showCameraVC!, animated: false, completion: nil)
    }
    
    // Save Media to Camera Roll
    @IBAction func saveButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    // Post Photo
    @IBAction func postPhoto(_ sender: Any) {
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
                                                  "username": username,
                                                  "rank": rank,
                                                  "propicref": propicref] as [String : AnyObject]
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
        )}
    )}

    // Did Recieve Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
