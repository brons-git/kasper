//
//  Post.swift
//  Kasper
//
//  Created by Bronson Berwald on 6/24/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import Foundation

class Post {
    var postType: String
    var id: String
    var date: String
    var textPost: String
    var imagePost: String
    var username: String
    var rank: String
    var propicref: String
    
    init(postTypeString: String, idString: String, dateString: String, textPostString: String, imagePostString: String, usernameString: String, rankString: String, propicrefString: String) {
        postType = postTypeString
        id = idString
        date = dateString
        textPost = textPostString
        imagePost = imagePostString
        username = usernameString
        rank = rankString
        propicref = propicrefString
    }
}
