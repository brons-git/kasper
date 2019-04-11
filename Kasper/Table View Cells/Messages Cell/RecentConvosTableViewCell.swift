//
//  RecentConvosTableViewCell.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/17/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit

class RecentConvosTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var cellMessage: UILabel!
    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var cellProPic: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
