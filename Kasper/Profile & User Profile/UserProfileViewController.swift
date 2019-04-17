//
//  UserProfileViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 6/23/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class UserProfileViewController: UIViewController {

    // Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addRemoveBtn: UIButton!
    @IBOutlet weak var permissionLabel: UILabel!
    @IBOutlet weak var msgUserBtn: UIButton!
    
    // Catching Data
    var posts = [Post]()
    var proPic = ""
    var username = ""
    var firstname = ""
    var lastname = ""
    var fullname = ""
    var rank = ""
    var id = ""
    var friendStatus = ""
    var myUsername = ""
    var myFirstname = ""
    var myLastname = ""
    var myRank = ""
    var myId = ""
    var permission = ""
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table and Cells
        tableView.dataSource = self
        let cellNib = UINib(nibName: "ProfileVCTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "profCell")
        
        // Initalize
        friendCheck()
        currentUsername()
        currentFirstname()
        currentLastname()
        currentRank()
        currentId()
        banCheck()
        setupProfile()
        fetchPosts()
        fetchChanges()
        fetchRemovals()
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
    
    // Setup Profile
    func setupProfile() {
        // Catching Data
        let proPicUrlRefe:NSURL? = NSURL(string: proPic)
        if let proPicUrl = proPicUrlRefe as URL? {
            //self.profilePic.sd_setImage(proPicUrl)
            self.profilePic.sd_setImage(with: proPicUrl)
            self.profilePic.layer.cornerRadius = 60.0
            self.profilePic.clipsToBounds = true
            fullnameLabel.text = (fullname)
        }
        
        // ADMIN
        if rank == "admin" {
            self.usernameLabel.textColor = UIColor.red
            self.fullnameLabel.textColor = UIColor.red
            usernameLabel.text = (username)
        }
        else {
            self.usernameLabel.textColor = UIColor.cyan
            self.fullnameLabel.textColor = UIColor.cyan
            usernameLabel.text = ("@" + username)
        }
    }
    
    // Did Recieve Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // GO: Back
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Create Conversation with User
    func createConvo() {
        let uid = Auth.auth().currentUser?.uid
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        let convoValues = ["firstname": self.myFirstname,
                           "id": self.myId,
                           "lastname": self.myLastname,
                           "message": ("Conversation was started on: " + dateString),
                           "username": self.myUsername]
        let newConvoValues = [dateString: convoValues]
        Database.database().reference().child("messages").child(uid!).child(id).updateChildValues(newConvoValues, withCompletionBlock: { (err, ref) in
            Database.database().reference().child("messages").child(self.id).child(uid!).updateChildValues(newConvoValues, withCompletionBlock: { (err, ref) in
        }
        )}
    )}
    
    // GOTO: Conversation with User
    @IBAction func messageButtonTapped(_ sender: Any) {
        // Check for mutual friendship
        if permission == "granted" {
            
        // Pass Data
        let conversationVC = self.storyboard?.instantiateViewController(withIdentifier: "ConversationVC") as? ConversationViewController
           
        conversationVC?.firstname = self.firstname
        conversationVC?.id = self.id
        conversationVC?.lastname = self.lastname
        conversationVC?.username = self.username
            
        conversationVC?.myFirstname = self.myFirstname
        conversationVC?.myId = self.myId
        conversationVC?.myLastname = self.myLastname
        conversationVC?.myUsername = self.myUsername
            
        // Direct to messages database reference
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("messages").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let friends = snapshot
            
            // Conversation exists
            if friends.hasChild(self.id) == true {
                self.present(conversationVC!, animated: false, completion: nil)
                
            // Conversation DOESN'T exist
            } else {
                self.createConvo()
                self.present(conversationVC!, animated: false, completion: nil)
                }
            }
        )} else {
            // Action for not being friends (messaging isn't allowed)
            print("MUST BE MUTUAL FRIENDS TO MESSAGE")
            let popUpMsgUsr = self.storyboard?.instantiateViewController(withIdentifier: "PopUpMsgUsr") as? PopUpMsgUsrViewController
            //self.present(popUpMsgUsr!, animated: false, completion: nil)
            self.addChildViewController(popUpMsgUsr!)
            popUpMsgUsr!.view.frame = self.view.frame
            self.view.addSubview(popUpMsgUsr!.view)
            popUpMsgUsr?.didMove(toParentViewController: self)
        }
    }

    // Fetch Posts
    func fetchPosts() {
        // Direct to database child
        Database.database().reference().child("users_profile_posts").child(id).observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
                // Store data in post.swift model
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
        Database.database().reference().child("users_profile_posts").child(id).observe(.childRemoved) { (snapshot: DataSnapshot) in
        }
    }
    
    // Fetch Changes
    func fetchChanges() {
        Database.database().reference().child("users_profile_posts").child(id).observe(.childChanged) { (snapshot: DataSnapshot) in
        }
    }
    
    // Friend Check
    func friendCheck() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("friend-lists").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let friends = snapshot
            print(type(of: snapshot))
            if friends.hasChild(self.username) == true {
                print("FRIEND")
                self.addRemoveBtn.setTitle("Remove", for: .normal)
                self.friendStatus = "friend"
                self.permissionToView()
            } else {
                print("NOT-FRIEND")
                self.addRemoveBtn.setTitle("Add", for: .normal)
                self.friendStatus = "not-friend"
                self.permissionToView()
            }
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
    
    // Retrieve Current Users Firstname
    func currentFirstname() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("firstname").observeSingleEvent(of: .value, with: { (snapshot) in
            let currentFirstname = snapshot.value as? String
            self.myFirstname = currentFirstname!
            print(self.myFirstname)
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
    
    // Retrieve Current Users Rank
    func currentRank() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
            let currentRank = snapshot.value as? String
            self.myRank = currentRank!
            print(self.myRank)
        }
    )}
    
    // Retrieve Current Users Profile Picture Reference
    func currentId() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("id").observeSingleEvent(of: .value, with: { (snapshot) in
            let currentId = snapshot.value as? String
            self.myId = currentId!
            print(self.myId)
        }
    )}
    
    // Permission To View Posts
    func permissionToView() {
        if friendStatus == "friend" {
            Database.database().reference().child("friend-lists").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                let friends = snapshot
                if friends.hasChild(self.myUsername) == true {
                    self.permission = "granted"
                    print("GRANTED")
                    self.permissionLabel.isHidden = true
                    self.tableView.reloadData()
                } else {
                    self.permission = "denied"
                    print("DENIED")
                    self.permissionLabel.isHidden = false
                    self.tableView.reloadData()
                }
            }
        )} else {
            self.permission = "denied"
            self.permissionLabel.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    // Add/Remove User as Friend
    @IBAction func addRemoveButtonTapped(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        if friendStatus == "friend" {
            // present pop up
            let popUpRemoveUsr = self.storyboard?.instantiateViewController(withIdentifier: "PopUpRemoveUsr") as? PopUpRemoveUsrViewController
            popUpRemoveUsr?.username = self.username
            self.addChildViewController(popUpRemoveUsr!)
            popUpRemoveUsr!.view.frame = self.view.frame
            self.view.addSubview(popUpRemoveUsr!.view)
            popUpRemoveUsr?.didMove(toParentViewController: self)
        } else {
            let addToFriendList = [self.username: "friend"]
            Database.database().reference().child("friend-lists").child(uid!).updateChildValues(addToFriendList, withCompletionBlock: { (err, ref) in
                
                // Send Notification to User
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = formatter.string(from: date)
                let notifValues = ["username": self.myUsername, "description": "Added you as their friend.", "id": self.myId]
                let dateNotifValues = [dateString: notifValues]
                Database.database().reference().child("notifications").child(self.id).updateChildValues(dateNotifValues, withCompletionBlock: { (err, ref) in
                    
                    
                    // Continue to Friend Check
                    self.friendCheck()
                }
            )}
        )}
    }
    // Remove User
    func removeUsr() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("friend-lists").child(uid!).child(self.username).removeValue()
    }
    
}

// Table and Cells
extension UserProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoTableViewCell
        if permission == "granted" {
            let postsRe = Array(posts.reversed())
            
            // ADMIN
            if postsRe[indexPath.row].rank == "admin" {
                cell.cellUsernameLabel.textColor = UIColor.red
                cell.cellUsernameLabel.text = postsRe[indexPath.row].username
            }
            else {
                cell.cellUsernameLabel.textColor = UIColor.cyan
                cell.cellUsernameLabel.text = "@" + postsRe[indexPath.row].username
            }
            
            // Cell Data
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
            }
            //return cell
        } else {
            print("YOU DONT HAVE PERMISSION TO VIEW POSTS")
            cell.isHidden = true
        }
        
        
        
        
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoTableViewCell
//        let postsRe = Array(posts.reversed())
//
//        // ADMIN
//        if postsRe[indexPath.row].rank == "admin" {
//            cell.cellUsernameLabel.textColor = UIColor.red
//            cell.cellUsernameLabel.text = postsRe[indexPath.row].username
//        }
//        else {
//            cell.cellUsernameLabel.textColor = UIColor.cyan
//            cell.cellUsernameLabel.text = "@" + postsRe[indexPath.row].username
//        }
//
//        // Cell Data
//        let proPicRefe = postsRe[indexPath.row].propicref
//        let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe)
//        if let proPicUrl = proPicUrlRefe as URL? {
//            cell.cellProfPic.sd_setImage(with: proPicUrl)
//            cell.cellProfPic.layer.cornerRadius = 20.0
//            cell.cellProfPic.clipsToBounds = true
//            let imagePostPicRefe = postsRe[indexPath.row].imagePost
//            let imagePostPicUrlRefe:NSURL? = NSURL(string: imagePostPicRefe)
//            if let imagePostPicUrl = imagePostPicUrlRefe as URL? {
//                cell.cellPostPhoto.sd_setImage(with: imagePostPicUrl)
//            }
//        }
        return cell
    }
}
