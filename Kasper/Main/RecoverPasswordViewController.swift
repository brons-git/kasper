//
//  RecoverPasswordViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/6/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import UIKit

class RecoverPasswordViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailInvalidLabel: UILabel!
    @IBOutlet weak var successfulRecoveryLabel: UILabel!
    @IBOutlet weak var invalidEmailLabel: UILabel!
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        self.emailTextField.delegate = self
    }
    
    // GO: Back
    @IBAction func backButtonTapped(_ sender: Any) {
        let showLogInVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInVC")
        self.present(showLogInVC!, animated: false, completion: nil)
    }
    
    // Recovery Request
    @IBAction func recoverButtonPressed(_ sender: Any) {
        emailTextField.resignFirstResponder()
        let email = emailTextField.text
        Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
            if error == nil {
                print("Email sent!")
                self.successfulRecoveryLabel.isHidden = false
                self.emailInvalidLabel.isHidden = true
                self.invalidEmailLabel.isHidden = true
            } else {
                print("Error")
                self.emailInvalidLabel.isHidden = false
                self.invalidEmailLabel.isHidden = false
                self.successfulRecoveryLabel.isHidden = true
            }
        }
    }
    
    //Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Hide keyboard when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        return (true)
    }
}
