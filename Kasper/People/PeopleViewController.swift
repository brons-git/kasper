//
//  PeopleViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/26/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class PeopleViewController: UIViewController, UISearchBarDelegate {
    
    // Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Variables
    var posts = [Post]()
    var users = [User]()
    var notifications = [Notifications]()
    var recentconvos = [RecentConvo]()
    
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
        setupProPic()
        fetchUsers()
        fetchChanges()
        fetchRemovals()
        
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
    private func setupProPic() {
        Database.database().reference().child("users").child(uid!).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let proPicRefe = snapshot.value as? String
            let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe!)
            if let proPicUrl = proPicUrlRefe as URL? {
                self.profilePic.sd_setImage(with: proPicUrl)
                self.profilePic.layer.cornerRadius = 20.0
                self.profilePic.clipsToBounds = true
            }
        })
    }

    // Fetch Users
    func fetchUsers() {
        // Direct to database child
        Database.database().reference().child("users").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                print(dict)
                
                // Store data in user.swift model
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
    
    // GOTO: Messages
    @IBAction func messagesTabButtonTapped(_ sender: Any) {
        // Pass to next
        let passToVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagesVC") as? MessagesViewController
        passToVC?.posts = posts
        passToVC?.users = users
        passToVC?.notifications = notifications
        passToVC?.recentconvos = recentconvos
        // Go to next
        let showMessagesVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagesVC")
        self.present(showMessagesVC!, animated: false, completion: nil)
    }
    
    // GOTO: Camera
    @IBAction func cameraTabButtonTapped(_ sender: Any) {
        // Pass to next
        let passToVC = self.storyboard?.instantiateViewController(withIdentifier: "KPhotoCamVC") as? KPhotoCamViewController
        passToVC?.posts = posts
        passToVC?.users = users
        passToVC?.notifications = notifications
        passToVC?.recentconvos = recentconvos
        // Go to next
        let showKPhotoCamVC = self.storyboard?.instantiateViewController(withIdentifier: "KPhotoCamVC")
        self.present(showKPhotoCamVC!, animated: false, completion: nil)
    }
    
    // GOTO: Feed
    @IBAction func feedTabButtonTapped(_ sender: Any) {
        // Pass to next
        let passToVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC") as? FeedViewController
        passToVC?.posts = posts
        passToVC?.users = users
        passToVC?.notifications = notifications
        passToVC?.recentconvos = recentconvos
        // Go to next
        let showFeedVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC")
        self.present(showFeedVC!, animated: false, completion: nil)
    }
    
    // GOTO: Notifications
    @IBAction func notificationsTabButtonTapped(_ sender: Any) {
        // Pass to next
        let passToVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC") as? NotificationsViewController
        passToVC?.posts = posts
        passToVC?.users = users
        passToVC?.notifications = notifications
        passToVC?.recentconvos = recentconvos
        // Go to next
        let showNotificationsVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC")
        self.present(showNotificationsVC!, animated: false, completion: nil)
    }
    
    // GOTO: Profile
    @IBAction func profileTabButtonTapped(_ sender: Any) {
        let showProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
        self.present(showProfileVC!, animated: false, completion: nil)
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
extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedUsers.count
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
        if displayedUsers[indexPath.row].rank == "admin" {
            //cell.cellUsername.textColor = UIColor.red
            //cell.cellFullname.textColor = UIColor.red
            cell.cellUsername.textColor = UIColor.cyan
            cell.cellFullname.textColor = UIColor.gray
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
                userProfileVC?.lastname = self.displayedUsers[indexPath.row].lastname
                userProfileVC?.rank = self.displayedUsers[indexPath.row].rank
                userProfileVC?.id = self.displayedUsers[indexPath.row].id
                userProfileVC?.firstname = self.displayedUsers[indexPath.row].firstname
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









