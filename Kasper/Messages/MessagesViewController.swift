//
//  MessagesViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/6/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePic: UIImageView!
    
    // Variables
    var posts = [Post]()
    var users = [User]()
    var notifications = [Notifications]()
    var recentconvos = [RecentConvo]()
    
    var firstname = ""
    var id = ""
    var lastname = ""
    var username = ""
    
    var myFirstname = ""
    var myId = ""
    var myLastname = ""
    var myUsername = ""
    
    // Constants
    let uid = Auth.auth().currentUser?.uid
    
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        banCheck()
        setupProPic()
        fetchRecentMsgs()
        fetchChanges()
        fetchRemovals()
        currentFirstname()
        currentId()
        currentLastname()
        currentUsername()
        
        // Table View
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
    
    // Setup Profile Picture
    fileprivate func setupProPic() {
        let uid = Auth.auth().currentUser?.uid
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
    
    // Did Recieve Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // GOTO: People
    @IBAction func peopleTabButtonTapped(_ sender: Any) {
        // Pass to next
        let passToVC = self.storyboard?.instantiateViewController(withIdentifier: "PeopleVC") as? PeopleViewController
        passToVC?.posts = posts
        passToVC?.users = users
        passToVC?.notifications = notifications
        passToVC?.recentconvos = recentconvos
        // Go to next
        let showPeopleVC = self.storyboard?.instantiateViewController(withIdentifier: "PeopleVC")
        self.present(showPeopleVC!, animated: false, completion: nil)
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
    
    // Fetch Recent Messages
    func fetchRecentMsgs() {
        // Direct to database child
        Database.database().reference().child("recent-msgs").child(uid!).observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? NSDictionary {
                print(dict)
                print(dict.allKeys)
                let keys = dict.allKeys
                for key in keys {
                    print(key)
                    if let nestedDict = dict[key] as? [String: Any] {
                        print(nestedDict)
                        let firstnameData = nestedDict["firstname"] as! String
                        let idData = nestedDict["id"] as! String
                        let lastnameData = nestedDict["lastname"] as! String
                        let messageData = nestedDict["message"] as! String
                        let usernameData = nestedDict["username"] as! String
                        
                        // Fetch Rank using existing "idData" from above
                        Database.database().reference().child("users").child(idData).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
                            let rankData = snapshot.value as? String
                            
                            // Fetch ProPicRef using existing "idData" from above
                            Database.database().reference().child("users").child(idData).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
                                let propicrefData = snapshot.value as? String
                                
                                // Add data to RecentConvo.swift
                                let convoinfo = RecentConvo(firstnameString: firstnameData, idString: idData, lastnameString: lastnameData, messageString: messageData, usernameString: usernameData, rankString: rankData!, propicrefString: propicrefData!)
                                self.recentconvos.append(convoinfo)
                                print(self.recentconvos)
                                
                                // Reload Table
                                self.tableView.reloadData()
                            }
                                
                            )}
                        )}
                }
            }
        }
    }
    
    // Fetch Removals
    func fetchRemovals() {
        Database.database().reference().child("recent-msgs").child(uid!).observe(.childRemoved) { (snapshot: DataSnapshot) in
            
        }
    }
    
    // Fetch Changes
    func fetchChanges() {
        Database.database().reference().child("recent-msgs").child(uid!).observe(.childChanged) { (snapshot: DataSnapshot) in
            //self.tableView.reloadData()??????
        }
    }
    
    // Retrieve Current Users Firstname
    func currentFirstname() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("firstname").observeSingleEvent(of: .value, with: { (snapshot) in
            let currentFirstname = snapshot.value as? String
            self.myFirstname = currentFirstname!
            print(self.myFirstname)
        }
        )}
    
    // Retrieve Current Users ID
    func currentId() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("id").observeSingleEvent(of: .value, with: { (snapshot) in
            let currentRank = snapshot.value as? String
            self.myId = currentRank!
            print(self.myId)
        }
        )}
    
    // Retrieve Current Users Lastname
    func currentLastname() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("lastname").observeSingleEvent(of: .value, with: { (snapshot) in
            let currentLastname = snapshot.value as? String
            self.myLastname = currentLastname!
            print(self.myLastname)
        }
        )}
    
    // Retrieve Current Users Username
    func currentUsername() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            let currentUsername = snapshot.value as? String
            self.myUsername = currentUsername!
            print(self.myUsername)
        }
        )}
    
    // Swipe Action: Delete Conversation
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let userid = self.recentconvos[indexPath.row].id
            Database.database().reference().child("recent-msgs").child(self.uid!).child(userid).removeValue()
            Database.database().reference().child("messages").child(self.uid!).child(userid).removeValue()
            self.recentconvos.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        action.backgroundColor = .red
        return action
    }
}


// Table and Cells
extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentconvos.count
    }
    
    // Table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentConvoCell", for: indexPath) as! RecentConvosTableViewCell
        
        // Selected Color
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = bgColorView
        
        // Cell Data
        let message = recentconvos[indexPath.row].message
        let fname = recentconvos[indexPath.row].firstname
        let lname = recentconvos[indexPath.row].lastname
        let fullname = fname + " " + lname
        cell.cellName.text = fullname
        cell.cellMessage.text = message
        
        // ADMIN
        if recentconvos[indexPath.row].rank == "admin" {
            cell.cellName.textColor = UIColor.red
            cell.cellMessage.textColor = UIColor.red
        }
        else {
            cell.cellName.textColor = UIColor.cyan
            cell.cellMessage.textColor = UIColor.gray
        }
        
        // Cell Data
        let proPicRefe = recentconvos[indexPath.row].propicref
        let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe)
        if let proPicUrl = proPicUrlRefe as URL? {
            cell.cellProPic.sd_setImage(with: proPicUrl)
            cell.cellProPic.layer.cornerRadius = 30.0
            cell.cellProPic.clipsToBounds = true
        }
        return cell
    }
    
    // Cell Profile Linking
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationVC = self.storyboard?.instantiateViewController(withIdentifier: "ConversationVC") as? ConversationViewController
        
        conversationVC?.firstname = self.recentconvos[indexPath.row].firstname
        conversationVC?.id = self.recentconvos[indexPath.row].id
        conversationVC?.lastname = self.recentconvos[indexPath.row].lastname
        conversationVC?.username = self.recentconvos[indexPath.row].username
        
        conversationVC?.myFirstname = self.myFirstname
        conversationVC?.myId = self.myId
        conversationVC?.myLastname = self.myLastname
        conversationVC?.myUsername = self.myUsername
        
        self.present(conversationVC!, animated: false, completion: nil)
    }
}
