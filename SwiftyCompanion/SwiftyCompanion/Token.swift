//
//  Token.swift
//  SwiftyCompanion
//
//  Created by Lucas BELVALETTE on 11/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
import SwiftyJSON

class Token:  CustomStringConvertible{
    var access_token: String
    var created_at: Int
    var expires_in: Int
    var token_type: String
    
    init (token: JSON) {
        self.access_token = token["access_token"].string!
        self.created_at = token["created_at"].int!
        self.expires_in = token["expires_in"].int!
        self.token_type = token["token_type"].string!
    }
    
    var description: String {
        return "\(token_type) \(access_token)"
    }
}
