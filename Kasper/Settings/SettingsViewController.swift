//
//  SettingsViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/26/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    // Outlets
    @IBOutlet weak var adminBtn: UIButton!
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        banCheck()
        controlPanel()
    }

    // Did Recieve Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    // ADMIN : Control Panel
    func controlPanel() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let rank = snapshot.value as? String
            if (rank == "admin" || rank == "redadmin")  {
                self.adminBtn.isHidden = false
                self.adminBtn.isEnabled = true
            }
            else {
                self.adminBtn.isHidden = true
                self.adminBtn.isEnabled = false
            }
        })
    }
    
    // GOTO: Control Panel
    @IBAction func adminBtnTapped(_ sender: Any) {
        let showControlPanelVC = self.storyboard?.instantiateViewController(withIdentifier: "ControlPanelVC")
        self.present(showControlPanelVC!, animated: false, completion: nil)
    }
    
    // GOTO: Change Name
    @IBAction func changeNameButtonTapped(_ sender: Any) {
        let showChangeNameVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangeNameVC")
        self.present(showChangeNameVC!, animated: false, completion: nil)
    }
    
    // GO: Back
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Log Out
    @IBAction func logOutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("User logged out!")
            let showMainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
            self.present(showMainVC!, animated: false, completion: nil)
        } catch {
            print("Error Signing Out!")
        }
    }
}
