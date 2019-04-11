//
//  User.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/26/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Foundation

class User {
    var id: String
    var email: String
    var firstname: String
    var lastname: String
    var propicref: String
    var rank: String
    var username: String
    
    init(idString: String, emailString: String, firstnameString: String, lastnameString: String, propicrefString: String, rankString: String, usernameString: String) {
        id = idString
        email = emailString
        firstname = firstnameString
        lastname = lastnameString
        propicref = propicrefString
        rank = rankString
        username = usernameString
    }
}
