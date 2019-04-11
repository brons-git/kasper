//
//  ProfileViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/6/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Image Picker
    @IBOutlet weak var userImagePicker: UIImageView!
    
    // Variables
    var posts = [Post]()
    let uid = Auth.auth().currentUser?.uid
    var fullname: String!
    
    // Image Picker
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        let cellNib = UINib(nibName: "ProfileVCTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "profCell")
        banCheck()
        setupProfile()
        fetchPosts()
        fetchRemovals()
        fetchChanges()
        
        // Image Picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
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
        let uid = Auth.auth().currentUser?.uid
        // Rank
        Database.database().reference().child("users").child(uid!).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let rank = snapshot.value as? String
            // Username
            Database.database().reference().child("users").child(uid!).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                let username = snapshot.value as? String
                self.usernameLabel.isHidden = false
                
                // ADMIN
                if rank == "admin" {
                    self.usernameLabel.textColor = UIColor.red
                    self.fullnameLabel.textColor = UIColor.red
                    self.usernameLabel.text = username
                }
                else {
                    self.usernameLabel.textColor = UIColor.cyan
                    self.fullnameLabel.textColor = UIColor.cyan
                    self.usernameLabel.text = "@" + username!
                }
            })
        })
        
        // Full Name
        Database.database().reference().child("users").child(uid!).child("firstname").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let firstname = snapshot.value as? String
            Database.database().reference().child("users").child(uid!).child("lastname").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                let lastname = snapshot.value as? String
                self.fullname = firstname! + " " + lastname!
                self.fullnameLabel.text = self.fullname
                self.fullnameLabel.isHidden = false
            })
        })
        
        // Profile Picture
        Database.database().reference().child("users").child(uid!).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let proPicRefe = snapshot.value as? String
            let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe!)
            if let proPicUrl = proPicUrlRefe as URL? {
                self.profilePic.sd_setImage(with: proPicUrl)
                self.profilePic.layer.cornerRadius = 60.0
                self.profilePic.clipsToBounds = true
            }
        })
    }
    
    // Fetch Posts
    func fetchPosts() {
        // Direct to database child
        Database.database().reference().child("users_profile_posts").child(uid!).observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
                // Store data in post.swift model
                let postType = dict["postType"] as! String
                let idData = dict["id"] as! String
                let dateData = dict["date"] as! String
                let textPostData = dict["textPost"] as! String
                let imagePostData = dict["imagePost"] as! String
                let usernameData = dict["username"] as! String
                
                // Fetch Rank using existing "idData" from above
                Database.database().reference().child("users").child(idData).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
                    let rankData = snapshot.value as? String
                    
                    // Fetch ProPicRef using existing "idData" from above
                    Database.database().reference().child("users").child(idData).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
                        let propicrefData = snapshot.value as? String
                        
                        // Add data to Post.swift model
                        let postinfo = Post(postTypeString: postType, idString: idData, dateString: dateData, textPostString: textPostData, imagePostString: imagePostData, usernameString: usernameData, rankString: rankData!, propicrefString: propicrefData!)
                        self.posts.append(postinfo)
                        
                        // Reload Table with Data
                        self.tableView.reloadData()
                    }
                    )}
                )}
        }
    }
    
    // Fetch Removals
    func fetchRemovals() {
        Database.database().reference().child("users_profile_posts").child(uid!).observe(.childRemoved) { (snapshot: DataSnapshot) in
            self.tableView.reloadData()
        }
    }
    
    // Fetch Changes
    func fetchChanges() {
        Database.database().reference().child("users_profile_posts").child(uid!).observe(.childChanged) { (snapshot: DataSnapshot) in
            self.tableView.reloadData()
        }
    }
    
    // GOTO: Settings
    @IBAction func settingsButtonTapped(_ sender: Any) {
        let showSettingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC")
        self.present(showSettingsVC!, animated: false, completion: nil)
    }
    
    // GOTO: Friend List
    @IBAction func friendListButtonTapped(_ sender: Any) {
        let showFriendListVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendListVC")
        self.present(showFriendListVC!, animated: false, completion: nil)
    }
    
    // GO: Back
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // GOTO: New Post
    @IBAction func newPostTapped(_ sender: Any) {
        let showNewPostVC = self.storyboard?.instantiateViewController(withIdentifier: "NewPostVC")
        self.present(showNewPostVC!, animated: false, completion: nil)
    }
    
    // Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userImagePicker.image = image
            imageSelected = true
            self.userImagePicker.layer.cornerRadius = 60.0
            self.userImagePicker.clipsToBounds = true
            if let imgData = UIImageJPEGRepresentation(self.userImagePicker.image!, 0.2) {
                let imgUid = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                // Store User Data
                Storage.storage().reference().child("users").child(uid).child("profile_pic").child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    let newProPic = ["propicref": downloadURL] as [String : AnyObject]
                    Database.database().reference().child("users").child(uid).updateChildValues(newProPic, withCompletionBlock: { (err, ref) in
                    }
            )}
            }
        } else {
            print("image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    @IBAction func selectedImgPicker (_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
}

// Table and Cells
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoTableViewCell
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
        return cell
    }
}


