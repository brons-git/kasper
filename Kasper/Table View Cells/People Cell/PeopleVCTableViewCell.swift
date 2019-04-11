//
//  PeopleVCTableViewCell.swift
//  Kasper
//
//  Created by Bronson Berwald on 6/24/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit

class PeopleVCTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var cellProPic: UIImageView!
    @IBOutlet weak var cellUsername: UILabel!
    @IBOutlet weak var cellFullname: UILabel!
    @IBOutlet weak var cellUserProfBTN: UIButton!
    @IBOutlet weak var cellppbtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    
}
