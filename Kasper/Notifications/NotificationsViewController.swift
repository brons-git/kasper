//
//  NotificationsViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/5/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase

class NotificationsViewController: UIViewController {

    // Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    var posts = [Post]()
    var users = [User]()
    var notifications = [Notifications]()
    var recentconvos = [RecentConvo]()
    
    // Refresher
    var refresher: UIRefreshControl!
    
    // Constants
    let uid = Auth.auth().currentUser?.uid
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize
        banCheck()
        setupProPic()
        fetchNotifications()
        fetchChanges()
        fetchRemovals()
        
        // Table View
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
        Database.database().reference().child("users").child(self.uid!).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    // Fetch Notifications
    func fetchNotifications() {
        // Direct to datbase child
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("notifications").child(uid!).observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                print(dict)
                
                // Store data in notification.swift model
                let descriptionData = dict["description"] as! String
                let idData = dict["id"] as! String
                let timestampData = dict["timestamp"] as! String
                
                // Fetch Rank using existing "idData" from above
                Database.database().reference().child("users").child(idData).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
                    let rankData = snapshot.value as? String
                    
                    // Fetch Username using existing "idData" from above
                    Database.database().reference().child("users").child(idData).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                        let usernameData = snapshot.value as? String
                    
                    // Fetch ProPicRef using existing "idData" from above
                    Database.database().reference().child("users").child(idData).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
                        let propicrefData = snapshot.value as? String
                        
                        let notificationinfo = Notifications(usernameString: usernameData!, descriptionString: descriptionData, idString: idData, timestampString: timestampData, rankString: rankData!, propicrefString: propicrefData!)
                        self.notifications.append(notificationinfo)
                        print(self.notifications)
                        self.tableView.reloadData()
                    }
                    )}
                )}
                )} else {
                print("DON'T FETCH")
            }
        }
    }
    
    // Fetch Removals
    func fetchRemovals() {
        Database.database().reference().child("notifications").observe(.childRemoved) { (snapshot: DataSnapshot) in
        }
    }
    
    // Fetch Changes
    func fetchChanges() {
        Database.database().reference().child("notifications").observe(.childChanged) { (snapshot: DataSnapshot) in
        }
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
    
    // GOTO: Profile
    @IBAction func profileTabButtonTapped(_ sender: Any) {
        let showProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
        self.present(showProfileVC!, animated: false, completion: nil)
    }
    
    // Swipe Action: Delete Notification
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let timestamp = self.notifications[indexPath.row].timestamp
            let usersid = self.notifications[indexPath.row].id
            let notifLoc = timestamp + usersid
            Database.database().reference().child("notifications").child(self.uid!).child(notifLoc).removeValue()
            self.notifications.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        action.backgroundColor = .red
        return action
    }

}

// Table and Cells
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    // Refresher
    @objc func refresh()
    {
        refresher.endRefreshing()
        tableView.reloadData()
    }
    
    // Table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        
        // Reverse Data Indexing
        let notificationsRe = Array(self.notifications.reversed())
        
        // Selected Color
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = bgColorView
        
        // Add @ Before Username
        cell.usernameLabel.text = "@" + notificationsRe[indexPath.row].username
        
        // ADMIN cell
        if notificationsRe[indexPath.row].rank == "redadmin" {
            cell.usernameLabel.textColor = UIColor.red
            cell.descriptionLabel.textColor = UIColor.red
            cell.descriptionLabel.text = notificationsRe[indexPath.row].description
            let proPicRefe = notificationsRe[indexPath.row].propicref
            let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe)
            if let proPicUrl = proPicUrlRefe as URL? {
                cell.proPic.sd_setImage(with: proPicUrl)
                cell.proPic.layer.cornerRadius = 20.0
                cell.proPic.clipsToBounds = true
            }
        }
        // User Cell
        else {
            cell.usernameLabel.textColor = UIColor.cyan
            cell.descriptionLabel.textColor = UIColor.gray
            cell.descriptionLabel.text = notificationsRe[indexPath.row].description
            let proPicRefe = notificationsRe[indexPath.row].propicref
            let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe)
            if let proPicUrl = proPicUrlRefe as URL? {
                cell.proPic.sd_setImage(with: proPicUrl)
                cell.proPic.layer.cornerRadius = 20.0
                cell.proPic.clipsToBounds = true
            }
        }
        return cell
    }
}
