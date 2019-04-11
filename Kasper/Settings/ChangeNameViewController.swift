//
//  ChangeNameViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 9/19/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ChangeNameViewController: UIViewController {

    // Outlets
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var invalidInfoLabel: UILabel!
    
    // Variables
    var firstname = String()
    var lastname = String()
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Did Recieve Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // GO: Back
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Update Name
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        if firstNameField.text != nil {
            invalidInfoLabel.isHidden = true
        }
        if lastNameField.text != nil {
            invalidInfoLabel.isHidden = true
        }
        guard let firstname = firstNameField.text, firstname.characters.count > 0 else {
            print("Invalid firstname!")
            invalidInfoLabel.isHidden = false
            self.invalidInfoLabel.text = "*ENTER FIRST NAME*"
            return
        }
        guard let lastname = lastNameField.text, lastname.characters.count > 0 else {
            print("Invalid lastname!")
            invalidInfoLabel.isHidden = false
            self.invalidInfoLabel.text = "*ENTER LAST NAME*"
            return
        }
        let uid = Auth.auth().currentUser?.uid
        let updateValues = ["firstname": firstname,
                          "lastname": lastname] as [String : AnyObject]
        Database.database().reference().child("users").child(uid!).updateChildValues(updateValues, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to update:", err)
                return
            } else {
                print("Successfully updated!")
                let showFeedVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC")
                self.present(showFeedVC!, animated: false, completion: nil)
            }
        })
    }
}
