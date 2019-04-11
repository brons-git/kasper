//
//  FriendListViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/7/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase

class FriendListViewController: UIViewController, UISearchBarDelegate {

    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Variables
    var users = [User]()
    
    // Search Bar
    var displayedUsers = [User]()
    
    // Constants
    let uid = Auth.auth().currentUser?.uid
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        tableView.dataSource = self
        let cellNib = UINib(nibName: "PeopleVCTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "userCell")
        
        // Calling functions
        banCheck()
        //setupProPic()
        fetchUsers()
        fetchChanges()
        
        // Search Bar
        setupSearchBar()
        
        // Table View
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.isEditing = false
        tableView.isUserInteractionEnabled = true
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
    
    // Search Bar
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    // Setup Profile Picture
//    private func setupProPic() {
//        Database.database().reference().child("users").child(uid!).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot)
//            let proPicRefe = snapshot.value as? String
//            let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe!)
//            if let proPicUrl = proPicUrlRefe as URL? {
//                self.profilePic.sd_setImage(with: proPicUrl)
//                self.profilePic.layer.cornerRadius = 20.0
//                self.profilePic.clipsToBounds = true
//            }
//        })
//    }
    
    // Fetch Users
    func fetchUsers() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                print(dict)
                let idData = dict["id"] as! String
                let emailData = dict["email"] as! String
                let firstnameData = dict["firstname"] as! String
                let lastnameData = dict["lastname"] as! String
                let propicrefData = dict["propicref"] as! String
                let rankData = dict["rank"] as! String
                let usernameData = dict["username"] as! String
                let userinfo = User(idString: idData, emailString: emailData, firstnameString: firstnameData, lastnameString: lastnameData, propicrefString: propicrefData, rankString: rankData, usernameString: usernameData)
                self.users.append(userinfo)
                print(self.users)
                self.displayedUsers = self.users
                self.tableView.reloadData()
            }
        }
    }
    
    // Fetch Removals
    func fetchRemovals() {
        Database.database().reference().child("users").observe(.childRemoved) { (snapshot: DataSnapshot) in
        }
    }
    
    // Fetch Changes
    func fetchChanges() {
        Database.database().reference().child("users").observe(.childChanged) { (snapshot: DataSnapshot) in
        }
    }
    
    // GO: Back
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Close search bar keyboard.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        searchBar.resignFirstResponder()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
}

// Table and Cells
extension FriendListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedUsers.count
    }
    
    // Table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! PeopleVCTableViewCell
        cell.isHidden = true
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("friend-lists").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let friends = snapshot
            print(type(of: snapshot))
            let username = self.displayedUsers[indexPath.row].username
            if friends.hasChild(username) == true {
                print("FRIEND")
                
                // Selected Color
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.black
                cell.selectedBackgroundView = bgColorView
                
                // ADMIN
                if self.displayedUsers[indexPath.row].rank == "admin" {
                    cell.cellUsername.textColor = UIColor.red
                    cell.cellFullname.textColor = UIColor.red
                    cell.cellUsername.text = self.displayedUsers[indexPath.row].username
                }
                else {
                    cell.cellUsername.textColor = UIColor.cyan
                    cell.cellFullname.textColor = UIColor.gray
                    cell.cellUsername.text = "@" + self.displayedUsers[indexPath.row].username
                }
                
                // Cell Data
                let proPicRefe = self.displayedUsers[indexPath.row].propicref
                let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe)
                if let proPicUrl = proPicUrlRefe as URL? {
                    cell.cellProPic.sd_setImage(with: proPicUrl)
                    cell.cellProPic.layer.cornerRadius = 30.0
                    cell.cellProPic.clipsToBounds = true
                    let fname = self.displayedUsers[indexPath.row].firstname
                    let lname = self.displayedUsers[indexPath.row].lastname
                    let fullname = fname + " " + lname
                    cell.cellFullname.text = fullname
                }
                // Show User Cell
                cell.isHidden = false
                self.tableView.rowHeight = 77.0
            } else {
                
                // Remove User Cell (reason: not a friend)
                print("NOT-FRIEND")
                cell.isHidden = true
                self.tableView.rowHeight = 0.0
            }
        })
        return cell
    }
    
    // Cell Profile Linking
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Database.database().reference().child("users").child(uid!).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let currentUser = snapshot.value as? String
            
            // GOTO: Profile
            if self.displayedUsers[indexPath.row].username == currentUser {
                let showProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
                self.present(showProfileVC!, animated: false, completion: nil)
            }
            // GOTO: User Profile
            if self.displayedUsers[indexPath.row].rank != currentUser {
                let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
                selectedCell.contentView.backgroundColor = UIColor.black
                selectedCell.selectionStyle = .none
                let userProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileViewController
                
                // Passing Data
                let fname = self.displayedUsers[indexPath.row].firstname
                let lname = self.displayedUsers[indexPath.row].lastname
                let fullname = fname + " " + lname
                
                userProfileVC?.proPic = self.displayedUsers[indexPath.row].propicref
                userProfileVC?.fullname = fullname
                userProfileVC?.username = self.displayedUsers[indexPath.row].username
                userProfileVC?.rank = self.displayedUsers[indexPath.row].rank
                userProfileVC?.id = self.displayedUsers[indexPath.row].id
                self.present(userProfileVC!, animated: false, completion: nil)
            }
        })
    }
    
    //Search Bar
    func reloadAndScrollToTop() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.contentOffset = CGPoint(x: 0, y: -tableView.contentInset.top)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            displayedUsers = users
            reloadAndScrollToTop()
            return
        }
        displayedUsers = users.filter({ User -> Bool in
            User.username.lowercased().contains(searchText.lowercased())
        })
        reloadAndScrollToTop()
    }
}
