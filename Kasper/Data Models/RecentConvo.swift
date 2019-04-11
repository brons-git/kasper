//
//  RecentConvo.swift
//  Kasper
//
//  Created by Bronson Berwald on 10/17/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Foundation

class RecentConvo {
    var firstname: String
    var id: String
    var lastname: String
    var message: String
    var username: String
    var rank: String
    var propicref: String
    
    init(firstnameString: String, idString: String, lastnameString: String, messageString: String, usernameString: String, rankString: String, propicrefString: String) {
        firstname = firstnameString
        id = idString
        lastname = lastnameString
        message = messageString
        username = usernameString
        rank = rankString
        propicref = propicrefString
    }
}
