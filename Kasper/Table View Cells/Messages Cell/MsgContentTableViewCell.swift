//
//  MsgContentTableViewCell.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/20/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit

class MsgContentTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
