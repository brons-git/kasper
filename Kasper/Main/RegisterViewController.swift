//
//  RegisterViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/6/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

//
//  RegisterViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/3/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Outlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var profilePicInvalidLabel: UILabel!
    @IBOutlet weak var emailInvalidLabel: UILabel!
    @IBOutlet weak var usernameInvalidLabel: UILabel!
    @IBOutlet weak var firstnameInvalidLabel: UILabel!
    @IBOutlet weak var lastnameInvalidLabel: UILabel!
    @IBOutlet weak var passwordInvalidLabel: UILabel!
    @IBOutlet weak var confirmPasswordInvalidLabel: UILabel!
    @IBOutlet weak var userImagePicker: UIImageView!
    @IBOutlet weak var imageInvalidLabel: UILabel!
    @IBOutlet weak var describeInfoInvalidLabel: UILabel!
    
    // Variables
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var usernameSens = String()
    var username = String()
    var firstname = String()
    var lastname = String()
    var email = String()
    var password = String()
    var confirmPassword = String()
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Image Picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Assigning text fields as delegates.
        self.emailTextField.delegate = self
        self.usernameTextField.delegate = self
        self.firstnameTextField.delegate = self
        self.lastnameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
    }
    
    // Did Recieve Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Back Button
    @IBAction func backButtonTapped(_ sender: Any) {
        let showMainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
        self.present(showMainVC!, animated: false, completion: nil)
    }
    
    // Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userImagePicker.image = image
            imageSelected = true
            self.userImagePicker.layer.cornerRadius = 60.0
            self.userImagePicker.clipsToBounds = true
        } else {
            print("image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        // Hide All Invalid Labels
        emailInvalidLabel.isHidden = true
        usernameInvalidLabel.isHidden = true
        firstnameInvalidLabel.isHidden = true
        lastnameInvalidLabel.isHidden = true
        passwordInvalidLabel.isHidden = true
        confirmPasswordInvalidLabel.isHidden = true
        profilePicInvalidLabel.isHidden = true
        describeInfoInvalidLabel.isHidden = true
        
        // Resign first responders for keyboard minimizing
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        firstnameTextField.resignFirstResponder()
        lastnameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        
        // Initialize usernameAvailability()
        self.usernameAvailability()
    }
    
    func usernameAvailability() {
    // Checks for username availability.
    Database.database().reference().child("users").queryOrdered(byChild: "username").queryEqual(toValue: self.usernameTextField.text!.lowercased()).observe(.value, with: { (snapshot) in
        if snapshot.exists() == true {
            print("TAKEN")
            self.usernameInvalidLabel.isHidden = false
            self.describeInfoInvalidLabel.isHidden = false
            self.describeInfoInvalidLabel.text = "*TAKEN USERNAME*"
        } else if snapshot.exists() == false {
            print("available")
            self.finishCheck()
        } else {
            print("available/taken error!")
        }
        })
    }
    
    // Checks for proper input requirements.
    func finishCheck() {
        if emailTextField.text != nil {
            emailInvalidLabel.isHidden = true
            describeInfoInvalidLabel.isHidden = true
        }
        if usernameTextField.text != nil {
            usernameInvalidLabel.isHidden = true
            describeInfoInvalidLabel.isHidden = true
        }
        if firstnameTextField.text != nil {
            firstnameInvalidLabel.isHidden = true
            describeInfoInvalidLabel.isHidden = true
        }
        if lastnameTextField.text != nil {
            lastnameInvalidLabel.isHidden = true
            describeInfoInvalidLabel.isHidden = true
        }
        if passwordTextField.text != nil {
            passwordInvalidLabel.isHidden = true
            confirmPasswordInvalidLabel.isHidden = true
            describeInfoInvalidLabel.isHidden = true
        }
        if passwordTextField.text == confirmPasswordTextField.text {
            passwordInvalidLabel.isHidden = true
            confirmPasswordInvalidLabel.isHidden = true
            describeInfoInvalidLabel.isHidden = true
        }
        if imageSelected == true {
            imageInvalidLabel.isHidden = true
        }
        guard let img = userImagePicker.image, imageSelected == true else {
            print("image needs to be selected")
            imageInvalidLabel.isHidden = false
            describeInfoInvalidLabel.isHidden = false
            self.describeInfoInvalidLabel.text = "*UPLOAD IMAGE*"
            return
        }
        guard let email = emailTextField.text, email.characters.count > 0 else {
            print("Invalid email!")
            emailInvalidLabel.isHidden = false
            describeInfoInvalidLabel.isHidden = false
            self.describeInfoInvalidLabel.text = "*INVALID OR TAKEN EMAIL*"
            return
        }
        guard let usernameSens = usernameTextField.text, usernameSens.characters.count > 3, usernameSens.characters.count < 12 else {
            print("Invalid username!")
            usernameInvalidLabel.isHidden = false
            describeInfoInvalidLabel.isHidden = false
            self.describeInfoInvalidLabel.text = "*USERNAME MUST BE BETWEEN 4-12 CHARACTERS*"
            return
        }
        guard let firstname = firstnameTextField.text, firstname.characters.count > 0 else {
            print("Invalid firstname!")
            firstnameInvalidLabel.isHidden = false
            describeInfoInvalidLabel.isHidden = false
            self.describeInfoInvalidLabel.text = "*ENTER FIRST NAME*"
            return
        }
        guard let lastname = lastnameTextField.text, lastname.characters.count > 0 else {
            print("Invalid lastname!")
            lastnameInvalidLabel.isHidden = false
            describeInfoInvalidLabel.isHidden = false
            self.describeInfoInvalidLabel.text = "*ENTER LAST NAME*"
            return
        }
        guard let password = passwordTextField.text, password.characters.count > 7 else {
            print("Invalid password!")
            passwordInvalidLabel.isHidden = false
            confirmPasswordInvalidLabel.isHidden = false
            describeInfoInvalidLabel.isHidden = false
            self.describeInfoInvalidLabel.text = "*PASSWORD MUST BE 7+ CHARACTERS*"
            return
        }
        guard password.characters.count > 7 else {
            passwordInvalidLabel.isHidden = false
            return
        }
        guard passwordTextField.text == confirmPasswordTextField.text else {
            print("Passwords don't match")
            passwordInvalidLabel.isHidden = false
            confirmPasswordInvalidLabel.isHidden = false
            describeInfoInvalidLabel.isHidden = false
            self.describeInfoInvalidLabel.text = "*PASSWORDS DON'T MATCH*"
            return
        }
        
        // Create User
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("Failed to create user.")
                self.emailInvalidLabel.isHidden = false
                self.describeInfoInvalidLabel.isHidden = false
                self.describeInfoInvalidLabel.text = "*INVALID OR TAKEN EMAIL*"
                return
            } else {
                self.describeInfoInvalidLabel.isHidden = true
                self.emailInvalidLabel.isHidden = true
                self.usernameInvalidLabel.isHidden = true
                self.firstnameInvalidLabel.isHidden = true
                self.lastnameInvalidLabel.isHidden = true
                self.passwordInvalidLabel.isHidden = true
                self.confirmPasswordInvalidLabel.isHidden = true
                self.profilePicInvalidLabel.isHidden = true
                self.registerButton.isEnabled = false
                if let imgData = UIImageJPEGRepresentation(self.userImagePicker.image!, 0.2) {
                    let imgUid = NSUUID().uuidString
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    
                    // Store User Data
                    Storage.storage().reference().child("users").child(uid).child("profile_pic").child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                        if error != nil {
                            print("did not upload img")
                            return
                        } else {
                            print("uploaded")
                            let downloadURL = metadata?.downloadURL()?.absoluteString
                            let username = usernameSens.lowercased()
                            let dictionary = ["id": uid,
                                              "username": username,
                                              "firstname": firstname,
                                              "lastname": lastname,
                                              "email": email,
                                              "rank": "guest",
                                              "propicref": downloadURL] as [String : AnyObject]
                            let values = [uid: dictionary]
                            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                                // Rehide username labels to prevent false "TAKEN USERNAME" error
                                self.usernameInvalidLabel.isHidden = true
                                self.describeInfoInvalidLabel.isHidden = true
                                let userxid = [username: uid]
                                Database.database().reference().child("uids").updateChildValues(userxid, withCompletionBlock: { (err, ref) in
                                    
                                    // Create Friend List for User
                                    let newFriendList = ["*": "default-friend"]
                                    Database.database().reference().child("friend-lists").child(uid).updateChildValues(newFriendList, withCompletionBlock: { (err, ref) in
                                        
                                        if let err = err {
                                            print("Failed to save user info into db:", err)
                                            return
                                        } else {
                                            print("Successfully saved user info to db")
                                            
                                            // GOTO: App
                                            let loggedInVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC")
                                            self.present(loggedInVC!, animated: false, completion: nil)
                                            }
                                        }
                                    )}
                                )}
                            )}
                        }
                    }
                }
            }
        )}
    
    // Image Picker
    @IBAction func selectedImgPicker (_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }

    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide keyboard when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        firstnameTextField.resignFirstResponder()
        lastnameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        return (true)
    }
}
