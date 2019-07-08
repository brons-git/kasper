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
    var myUsername = ""
    
    // Search Bar
    var displayedUsers = [User]()
    
    // Refresher
    var refresher: UIRefreshControl!
    
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
        getMyUsername()
        fetchFriends()
        fetchChanges()
        
        // Search Bar
        setupSearchBar()
        
        // Table View
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.isEditing = false
        tableView.isUserInteractionEnabled = true
        
        // Refresher
        refresher = UIRefreshControl()
        refresher.tintColor = UIColor.cyan
        refresher.addTarget(self, action: #selector(FeedViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
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
    
    // Get My Username
    func getMyUsername() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            let username = snapshot.value as? String
            self.myUsername = username!
        }
    )}
    
    // Fetch Friends
    func fetchFriends() {
        var friends_array = [String]()
        var friends_uids_array = [String]()
        var mutual_friends_array = [String]()
        
        // get friends usernames
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("friend-lists").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let snap = snapshot.value as? [String: Any]
            let friends = snap?.keys
            if friends != nil {
                for friend in friends! {
                    friends_array.append(friend)
                }
                
                // get friends uids
                for friend in friends_array {
                    Database.database().reference().child("uids").child(friend).observeSingleEvent(of: .value, with: { (snapshot) in
                        let uuid = snapshot.value as? String
                        friends_uids_array.append(uuid!)
                        
                        // check if friends are mutual
                        for uuid in friends_uids_array {
                            Database.database().reference().child("friend-lists").child(uuid).observeSingleEvent(of: .value, with: { (snapshot) in
                                let snap = snapshot
                                if snap.hasChild(self.myUsername) == true {
                                    if mutual_friends_array.contains(uuid) {
                                        print("already has uuid in array")
                                    } else {
                                        mutual_friends_array.append(uuid)
                                        self.fetchFriendsStepTwo(passing_uuid: uuid)
                                    }
                                }
                            }
                        )}
                    }
                    )}
            } else {
                print("no friends to fetch")
            }
        }
    )}
    func fetchFriendsStepTwo(passing_uuid: String) {
        let passed_uuid = passing_uuid
        print(passed_uuid)
        Database.database().reference().child("users").child(passed_uuid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
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
            } else {
            }
        }
    )}
    
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
    
    // Refresher
    @objc func refresh()
    {
        refresher.endRefreshing()
        tableView.reloadData()
    }
    
    // Table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! PeopleVCTableViewCell
        
        // Selected Color
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = bgColorView
        
        // Add @ Before Username
        cell.cellUsername.text = "@" + displayedUsers[indexPath.row].username
        
        // ADMIN Cell
        if displayedUsers[indexPath.row].rank == "redadmin" {
            cell.cellUsername.textColor = UIColor.red
            cell.cellFullname.textColor = UIColor.red
        }
            // User Cell
        else {
            cell.cellUsername.textColor = UIColor.cyan
            cell.cellFullname.textColor = UIColor.gray
        }
        
        // Cell Data
        let proPicRefe = displayedUsers[indexPath.row].propicref
        let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe)
        if let proPicUrl = proPicUrlRefe as URL? {
            cell.cellProPic.sd_setImage(with: proPicUrl)
            cell.cellProPic.layer.cornerRadius = 30.0
            cell.cellProPic.clipsToBounds = true
            let fname = displayedUsers[indexPath.row].firstname
            let lname = displayedUsers[indexPath.row].lastname
            let fullname = fname + " " + lname
            cell.cellFullname.text = fullname
        }
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
