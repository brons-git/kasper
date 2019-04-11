//
//  FeedPhotoTableViewCell.swift
//  Kasper
//
//  Created by Bronson Berwald on 7/5/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit

class FeedPhotoTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var cellPostPhoto: UIImageView!
    @IBOutlet weak var cellProfPic: UIImageView!
    @IBOutlet weak var cellUsernameLabel: UILabel!
    @IBOutlet weak var cellUserProfBTN: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
