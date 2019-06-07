//
//  ControlPanelViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/3/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase

class ControlPanelViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var commandInput: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        self.userInput.delegate = self
        self.commandInput.delegate = self

    }

    @IBAction func commandButtonTapped(_ sender: Any) {
        if userInput.text != "" {
            let user = userInput.text?.lowercased()
            let command = commandInput.text?.lowercased()
            Database.database().reference().child("uids").child(user!).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                let uuid = snapshot.value as? String
                if uuid != nil {
                    // Command : ban (Ban Users Account)
                    if command == "$ban" {
                        let updateValues = ["rank": "banned"] as [String : AnyObject]
                        Database.database().reference().child("users").child(uuid!).updateChildValues(updateValues, withCompletionBlock: { (err, ref) in
                            self.infoLabel.text = "uid: " + uuid! + " has been banned!"
                            self.infoLabel.isHidden = false
                            // Display notification globally
                        }
                    // Command : sban (Silently Ban Users Account)
                    )} else if command == "$sban" {
                        let updateValues = ["rank": "banned"] as [String : AnyObject]
                        Database.database().reference().child("users").child(uuid!).updateChildValues(updateValues, withCompletionBlock: { (err, ref) in
                            self.infoLabel.text = "uid: " + uuid! + " has been silently banned!"
                            self.infoLabel.isHidden = false
                        }
                    // Command : mute (Mute Users Account)
                    )} else if command == "$mute" {
                        let updateValues = ["rank": "muted"] as [String : AnyObject]
                        Database.database().reference().child("users").child(uuid!).updateChildValues(updateValues, withCompletionBlock: { (err, ref) in
                            self.infoLabel.text = "uid: " + uuid! + " has been muted!"
                            self.infoLabel.isHidden = false
                            // Display notification globally
                        }
                    // Command : smute (Silently Mute Users Account)
                    )} else if command == "$smute" {
                        let updateValues = ["rank": "muted"] as [String : AnyObject]
                        Database.database().reference().child("users").child(uuid!).updateChildValues(updateValues, withCompletionBlock: { (err, ref) in
                            self.infoLabel.text = "uid: " + uuid! + " has been silently muted!"
                            self.infoLabel.isHidden = false
                        }
                    // Command : guest (Set User Rank to Guest)
                    )} else if command == "$rank guest" {
                        let updateValues = ["rank": "guest"] as [String : AnyObject]
                        Database.database().reference().child("users").child(uuid!).updateChildValues(updateValues, withCompletionBlock: { (err, ref) in
                            self.infoLabel.text = "uid: " + uuid! + " is now a guest!"
                            self.infoLabel.isHidden = false
                        }
                    // Command : admin (Set user rank to admin)
                    )} else if command == "$rank admin" {
                        let updateValues = ["rank": "admin"] as [String : AnyObject]
                        Database.database().reference().child("users").child(uuid!).updateChildValues(updateValues, withCompletionBlock: { (err, ref) in
                            self.infoLabel.text = "uid: " + uuid! + " is now an ADMIN!"
                            self.infoLabel.isHidden = false
                        }
                    // Command : redadmin (Set user rank to redadmin)
                    )} else if command == "$rank redadmin" {
                        let updateValues = ["rank": "redadmin"] as [String : AnyObject]
                        Database.database().reference().child("users").child(uuid!).updateChildValues(updateValues, withCompletionBlock: { (err, ref) in
                            self.infoLabel.text = "uid: " + uuid! + " is now a REDADMIN!"
                            self.infoLabel.isHidden = false
                        }
                    // Command : info (show info about user)
                    )} else if command == "$info" {
                        self.infoLabel.text = "uid: " + uuid!
                        self.infoLabel.isHidden = false
        
                    // Invalid Command
                    } else {
                        self.infoLabel.text = "invalid command"
                        self.infoLabel.isHidden = false
                    }
                    
                } else {
                    self.infoLabel.text = "no matching uid to username: " + user!
                    self.infoLabel.isHidden = false
                }
            }
        )} else {
            self.infoLabel.text = "enter a username"
            self.infoLabel.isHidden = false
        }
    }
    
    // GO: Back
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    //HIDE KEYBOARD WHEN USER TOUCHES OUTSIDE OF THE KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //HIDE KEYBOARD WHEN RETURN KEY IS PRESSED
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userInput.resignFirstResponder()
        commandInput.resignFirstResponder()
        return (true)
    }

}
