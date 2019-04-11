//
//  LogInViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/6/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var invalidInfoLabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegates
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    // GO: Back
    @IBAction func backButtonTapped(_ sender: Any) {
        let showMainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
        self.present(showMainVC!, animated: false, completion: nil)
    }
    
    // GOTO: Recover Password
    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
        let showRecoverPasswordVC = self.storyboard?.instantiateViewController(withIdentifier: "RecoverPasswordVC")
        self.present(showRecoverPasswordVC!, animated: false, completion: nil)
    }
    
    // Login Authentication
    @IBAction func logInButtonTapped(_ sender: Any) {
        
        //CLOSES KEYBOARD
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        //AUTHENTICATION
        let email = emailTextField.text
        let password = passwordTextField.text
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if error == nil {
                self.invalidInfoLabel.isHidden = true
                print("Successfully loggeed back in with user!")
                
                //INITIATION OF NEXT VIEW CONTROLLER
                let loggedInVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC")
                self.present(loggedInVC!, animated: false, completion: nil)
                
            //ERROR HANDLING
            } else {
                print("Failed to sign in with email")
                self.invalidInfoLabel.isHidden = false
            }
        }
    };
    
    //HIDE KEYBOARD WHEN USER TOUCHES OUTSIDE OF THE KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //HIDE KEYBOARD WHEN RETURN KEY IS PRESSED
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return (true)
    }

}
