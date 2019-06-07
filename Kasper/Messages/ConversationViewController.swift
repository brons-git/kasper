//
//  GlobalChatViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/6/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ConversationViewController: UIViewController {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var firstnameLabel: UILabel!
    var conversations = [Conversation]()
    
    var id = ""
    var firstname = ""
    var lastname = ""
    var username = ""
    
    var myId = ""
    var myFirstname = ""
    var myLastname = ""
    var myUsername = ""
    
    var text = ""
    
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        // AUTOMATICALLY pull up keyboard
        postText.becomeFirstResponder()
        
        // Initialize
        setupProPic()
        setupFirstnameLabel()
        fetchConversation()
        fetchRemovals()
        fetchChanges()
    }
    
    // Setup Firstname for conversation w/ user
    func setupFirstnameLabel () {
        self.firstnameLabel.text = firstname
        Database.database().reference().child("users").child(self.id).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let rank = snapshot.value as? String
            if rank == "redadmin" {
                self.firstnameLabel.textColor = UIColor.red
            } else {
                self.firstnameLabel.textColor = UIColor.cyan
            }
            
        }
    )}
    
    // Setup Profile Picture for Self
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
    
    func fetchConversation() {
        // Direct to database child
        Database.database().reference().child("messages").child(uid!).child(id).observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
                // Store data in post.swift model
                let firstnameData = dict["firstname"] as! String
                let idData = dict["id"] as! String
                let lastnameData = dict["lastname"] as! String
                let messageData = dict["message"] as! String
                let usernameData = dict["username"] as! String
                
                // Fetch Rank using existing "idData" from above
                Database.database().reference().child("users").child(idData).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
                    let rankData = snapshot.value as? String
                    
                    // Fetch ProPicRef using existing "idData" from above
                    Database.database().reference().child("users").child(idData).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
                        let propicrefData = snapshot.value as? String
                        
                        // Add data to Post.swift model
                        let messageinfo = Conversation(firstnameString: firstnameData, idString: idData, lastnameString: lastnameData, messageString: messageData, usernameString: usernameData, rankString: rankData!, propicrefString: propicrefData!)
                        self.conversations.append(messageinfo)
                        
                        // Reload Table with Data
                        self.tableView.reloadData()
                    }
                    )}
                )}
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
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // GO: Back
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Update recent-msgs in firebase database
    func updateRecentMsgs() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("recent-msgs").child(self.id).child(uid!).removeValue()
        Database.database().reference().child("recent-msgs").child(uid!).child(self.id).removeValue()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        let recentMsgValues = ["firstname": firstname,
                             "id": id,
                             "lastname": lastname,
                             "message": text,
                             "username": username]
        let newRecentMsgValues = [dateString: recentMsgValues]
        let theirRecentMsgValues = ["firstname": myFirstname,
                                    "id": myId,
                                    "lastname": myLastname,
                                    "message": text,
                                    "username": myUsername]
        let newTheirRecentMsgValues = [dateString: theirRecentMsgValues]
        Database.database().reference().child("recent-msgs").child(uid!).child(self.id).updateChildValues(newRecentMsgValues, withCompletionBlock: { (err, ref) in
            Database.database().reference().child("recent-msgs").child(self.id).child(uid!).updateChildValues(newTheirRecentMsgValues, withCompletionBlock: { (err, ref) in
            }
        )}
    )}
    
    
    @IBAction func storeData(_ sender: UIButton) {
        let text = self.postText.text
        if text != "" {
            self.postButton.isEnabled = false
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                let username = snapshot.value as? String
                Database.database().reference().child("users").child(uid!).child("firstname").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    let firstname = snapshot.value as? String
                    Database.database().reference().child("users").child(uid!).child("lastname").observeSingleEvent(of: .value, with: { (snapshot) in
                        print(snapshot)
                        let lastname = snapshot.value as? String
                        let text = self.postText.text
                        let date = Date()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateString = formatter.string(from: date)
                        let messageValues = ["firstname": firstname,
                                             "id": uid,
                                             "lastname": lastname,
                                             "message": text,
                                             "username": username]
                        let newMessageValues = [dateString: messageValues]
                        
                        // Store Message Data in VC
                        self.text = text!
                        
                        Database.database().reference().child("messages").child(uid!).child(self.id).updateChildValues(newMessageValues, withCompletionBlock: { (err, ref) in
                            Database.database().reference().child("messages").child(self.id).child(uid!).updateChildValues(newMessageValues, withCompletionBlock: { (err, ref) in
                                if err != nil {
                                    print("Error with upload!")
                                } else {
                                    self.updateRecentMsgs()
                                    self.postText.text = nil
                                    self.postButton.isEnabled = true
                                }
                            })
                        })
                    })
                })
            })
        } else {
            print("No text in field / Nothing to post")
        }
    }
    
    
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "msgConCell", for: indexPath) as! MsgContentTableViewCell
        let convosRe = Array(conversations.reversed())
        
        cell.cellMessage.text = convosRe[indexPath.row].message

        
        // Check to see who each message belongs to
        let msgId = convosRe[indexPath.row].id
        if msgId == myId {
            // My Message Bubble & Details
            cell.cellMessage.textColor = UIColor.green
        } else if msgId == id {
            // Their Message Bubble & Details
            cell.cellMessage.textColor = UIColor.cyan
        }
        
        tableView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        return cell
    }
    
    
}
