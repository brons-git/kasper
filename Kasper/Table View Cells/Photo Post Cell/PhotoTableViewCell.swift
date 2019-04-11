//
//  PhotoTableViewCell.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/2/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    //@IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var cellProfPic: UIImageView!
    @IBOutlet weak var cellUsernameLabel: UILabel!
    @IBOutlet weak var cellPostPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
