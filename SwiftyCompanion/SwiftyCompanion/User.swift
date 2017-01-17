//
//  User.swift
//  SwiftyCompanion
//
//  Created by Lucas BELVALETTE on 11/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
import SwiftyJSON

class User {
    let partnerships: [JSON]?
    let cursus: JSON?
    let projects_users: [JSON]?
    let image_url: String?
    let email: String?
    let wallet: Int?
    let isStaff: Bool?
    let lastname: String?
    let firstname: String?
    let correctionPoint: Int?
    let login: String?
    let location: String?
    let phone: String?
    let displayname: String?
    let titles: [JSON]?
    let achievements: [JSON]?
    
    init (json: JSON) {
        self.partnerships = json["partnerships"].array
        self.cursus = json["cursus_users"].array?[0]
        self.projects_users = json["projects_users"].array
        self.image_url = json["image_url"].string
        self.email = json["email"].string
        self.wallet = json["wallet"].int
        self.isStaff = json["staff?"].bool
        self.lastname = json["last_name"].string
        self.firstname = json["first_name"].string
        self.correctionPoint = json["correction_point"].int
        self.login = json["login"].string
        self.location = json["location"].string
        self.achievements = json["achievements"].array
        self.phone = json["phone"].string
        self.displayname = json["displayname"].string
        self.titles = json["titles"].array
    }
}
