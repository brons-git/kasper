//
//  ProfileVCTableViewCell.swift
//  Kasper
//
//  Created by Bronson Berwald on 6/24/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit

class ProfileVCTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var cellTextPost: UILabel!
    @IBOutlet weak var cellUsername: UILabel!
    @IBOutlet weak var cellProPic: UIImageView!
    @IBOutlet weak var cellUserProfBTN: UIButton!
    
    // Awake From Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
