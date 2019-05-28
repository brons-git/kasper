//
//  FeedViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/6/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class FeedViewController: UIViewController {

    // Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    var posts = [Post]()
    var users = [User]()
    var notifications = [Notifications]()
    var recentconvos = [RecentConvo]()
    
    // Constants
    let uid = Auth.auth().currentUser?.uid
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        banCheck()
        setupProPic()
        fetchPosts()
        fetchRemovals()
        fetchChanges()
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
    func setupProPic() {
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
    
    // Fetch Posts
    func fetchPosts() {
        // Direct to database child
        Database.database().reference().child("users_feed_posts").observe(.childAdded) { (snapshot: DataSnapshot) in
                if let dict = snapshot.value as? [String: Any] {
                    
                    // Retrieve Existing Data Stored "users_feed_posts"
                    let postType = dict["postType"] as! String
                    let idData = dict["id"] as! String
                    let dateData = dict["date"] as! String
                    let textPostData = dict["textPost"] as! String
                    let imagePostData = dict["imagePost"] as! String
                    
                    // Fetch Username using existing "idData" from above
                    Database.database().reference().child("users").child(idData).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                        let usernameData = snapshot.value as? String
                    
                        // Fetch Rank using existing "idData" from above
                        Database.database().reference().child("users").child(idData).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
                            let rankData = snapshot.value as? String
                            
                            // Fetch ProPicRef using existing "idData" from above
                            Database.database().reference().child("users").child(idData).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
                                let propicrefData = snapshot.value as? String
                            
                                // Add data to Post.swift model
                                let postinfo = Post(postTypeString: postType, idString: idData, dateString: dateData, textPostString: textPostData, imagePostString: imagePostData, usernameString: usernameData!, rankString: rankData!, propicrefString: propicrefData!)
                                self.posts.append(postinfo)
                                
                                // Reload Table with Data
                                self.tableView.reloadData()
                        }
                    )}
                )}
            )}
        }
    }
    
    // Fetch Removals
    func fetchRemovals() {
        Database.database().reference().child("users_feed_posts").observe(.childRemoved) { (snapshot: DataSnapshot) in
        }
    }
    
    // Fetch Changes
    func fetchChanges() {
        Database.database().reference().child("users_feed_posts").observe(.childChanged) { (snapshot: DataSnapshot) in
        }
    }

    // Did Recieve Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // GOTO: New Post
    @IBAction func newPostTapped(_ sender: Any) {
        let showNewPostVC = self.storyboard?.instantiateViewController(withIdentifier: "NewPostVC")
        self.present(showNewPostVC!, animated: false, completion: nil)
    }

}

// Table and Cells
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoTableViewCell
        let postsRe = Array(self.posts.reversed())
        
        // Add @ Before Username
        cell.cellUsernameLabel.text = "@" + postsRe[indexPath.row].username
        
        // ADMIN Cell
        if postsRe[indexPath.row].rank == "admin" {
            //cell.cellUsernameLabel.textColor = UIColor.red
            cell.cellUsernameLabel.textColor = UIColor.cyan
        }
        // User Cell
        else {
            cell.cellUsernameLabel.textColor = UIColor.cyan
        }
        
        // Cell Data
        Database.database().reference().child("users_feed_posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let postType = dict["postType"] as! String
                if postType == "photo" {
                    let proPicRefe = postsRe[indexPath.row].propicref
                    let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe)
                    if let proPicUrl = proPicUrlRefe as URL? {
                        cell.cellProfPic.sd_setImage(with: proPicUrl)
                        cell.cellProfPic.layer.cornerRadius = 20.0
                        cell.cellProfPic.clipsToBounds = true
                        let imagePostPicRefe = postsRe[indexPath.row].imagePost
                        let imagePostPicUrlRefe:NSURL? = NSURL(string: imagePostPicRefe)
                        if let imagePostPicUrl = imagePostPicUrlRefe as URL? {
                            cell.cellPostPhoto.sd_setImage(with: imagePostPicUrl)
                        }
                    } else {
                        print("error")
                    }
                }
            }
        }
        return cell
    }
}
