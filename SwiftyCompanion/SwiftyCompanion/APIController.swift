//
//  APIController.swift
//  SwiftyCompanion
//
//  Created by Lucas BELVALETTE on 11/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireSwiftyJSON
import SwiftyJSON

class APIController {
    var delegate: API42Delegate?
    var tokenObj: Token?
    
    init(delegate: API42Delegate?, token: Token) {
        self.delegate = delegate
        self.tokenObj = token
    }
    
    func returnUser(id: Int) {
        let url = "https://api.intra.42.fr/v2/users/" + String(id) + "?access_token=" + (self.tokenObj?.access_token)!
        let queue = DispatchQueue.global(qos: .background)
        Alamofire.request(url, method: .get).responseJSON(queue: queue) { response in
            if response.result.isSuccess {
                DispatchQueue.main.async {
                    let ret = JSON(response.result.value!)
                    self.delegate?.handleResponse(user: ret)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.delegate?.handleError(error: "Failed to load user data...")
                }
            }
        }
    }
    
    func getUser(xlogin: String) {
        let login = xlogin.lowercased()
        let url = "https://api.intra.42.fr/v2/users?access_token=" + (self.tokenObj?.access_token)! + "&filter[login]=" + login
        let queue = DispatchQueue.global(qos: .background)
        Alamofire.request(url, method: .get).responseJSON(queue: queue) { response in
            if (response.result.isSuccess) {
                DispatchQueue.main.async {
                    let ret = JSON(response.result.value!)
                    if ret.count != 0 {
                        let user = ret[0]
                        let id = user["id"].int
                        self.returnUser(id: id!)
                    }
                    else {
                        self.delegate?.handleError(error: "No user found for: " + login)
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.delegate?.handleError(error: "failed to request API")
                }
            }
            
        }
    }
}

