//
//  MainViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/7/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Did Recieve Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // GOTO: Login
    @IBAction func logInButtonTapped(_ sender: Any) {
        let showLogInVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInVC")
        self.present(showLogInVC!, animated: false, completion: nil)
    }
    
    // GOTO: Register
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let showInvitationAccessVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC")
        self.present(showInvitationAccessVC!, animated: false, completion: nil)
    }

}
