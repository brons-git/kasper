//
//  PopUpRemoveUsrViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/12/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit

class PopUpRemoveUsrViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add name to description label
        self.descriptionLabel.text = ("Would you like to remove '" + username + "' from your friends?")

        // Transparent Background
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }

    // Remove
    @IBAction func removeButtonTapped(_ sender: Any) {
        let userProf = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileViewController
        userProf?.username = self.username
        userProf?.removeUsr()
        self.view.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
    
    // Cancel
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.view.removeFromSuperview()
    }


}
