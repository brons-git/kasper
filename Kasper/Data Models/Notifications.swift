//
//  Notifications.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/9/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Foundation

class Notifications {
    var username: String
    var description: String
    var id: String
    var rank: String
    var propicref: String
    var timestamp: String
    
    init(usernameString: String, descriptionString: String, idString: String, timestampString: String, rankString: String, propicrefString: String) {
        username = usernameString
        description = descriptionString
        id = idString
        rank = rankString
        propicref = propicrefString
        timestamp = timestampString
    }
}
