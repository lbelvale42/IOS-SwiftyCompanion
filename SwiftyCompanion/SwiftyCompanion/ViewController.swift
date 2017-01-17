//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Lucas BELVALETTE on 11/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireSwiftyJSON
import SwiftyJSON

class ViewController: UIViewController, API42Delegate {

    var tokenObj: Token?
    var api: APIController?
    var delegate: API42Delegate?
    var user: User?

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var searchField: UITextField!
    
    
    @IBAction func searchLogin(_ sender: UIButton) {
        searchButton.isHidden = true
        activityMonitor.isHidden = false
        activityMonitor.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if self.searchField.text?.isEmpty == true {
            self.delegate?.handleError(error: "please enter valid login")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "\(self.tokenObj!)"
        ]
        Alamofire.request("https://api.intra.42.fr/oauth/token/info", headers: headers).responseSwiftyJSON { response in
            let expire = response.result.value!["expires_in_seconds"].int
//            let expire: Int? = nil
            if let e = expire {
                print("token expire in : \(e)")
                DispatchQueue.main.async {
                    self.api?.getUser(xlogin: self.searchField.text!)
                }
            }
            else {
                let queue = DispatchQueue.global(qos: .background)
                let params = "grant_type=client_credentials&client_id=\(Key.Id)&client_secret=\(Key.Secret)"
                Alamofire.request("https://api.intra.42.fr/oauth/token?\(params)", method: .post).responseSwiftyJSON(queue: queue) { response in
                    if (response.result.isSuccess) {
                        if response.result.value!["error"].string != nil{
                            DispatchQueue.main.async {
                                self.delegate?.handleError(error: "Fail to load token : " + response.result.value!["error_description"].string!)
                                return
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.tokenObj = Token(token: response.result.value!)
                                self.api = APIController(delegate: self.delegate, token: self.tokenObj!)
                                self.api?.getUser(xlogin: self.searchField.text!)
                                print("token has been refresh")
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.delegate?.handleError(error: "Fail to load token")
                            return
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg")!)
        self.searchButton.layer.cornerRadius = 5
        self.searchButton.isHidden = true
        self.activityMonitor.isHidden = false
        self.activityMonitor.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let queue = DispatchQueue.global(qos: .background)
        let params = "grant_type=client_credentials&client_id=\(Key.Id)&client_secret=\(Key.Secret)"
        Alamofire.request("https://api.intra.42.fr/oauth/token?\(params)", method: .post).responseSwiftyJSON(queue: queue) { response in
            if (response.result.isSuccess) {
                if response.result.value!["error"].string != nil{
                    DispatchQueue.main.async {
                        self.activityMonitor.isHidden = true
                        self.activityMonitor.stopAnimating()
                        let alert = UIAlertController(title: "Error", message: "Fail to load token : " + response.result.value!["error_description"].string!, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.tokenObj = Token(token: response.result.value!)
                        self.api = APIController(delegate: self.delegate, token: self.tokenObj!)
                        self.searchButton.isHidden = false
                        self.activityMonitor.isHidden = true
                        self.activityMonitor.stopAnimating()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.activityMonitor.isHidden = true
                    self.activityMonitor.stopAnimating()
                    let alert = UIAlertController(title: "Error", message: "Fail to load token", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }

    }
    
    func handleResponse(user: JSON) {
        self.user = User(json: user)
        self.searchButton.isHidden = false
        self.activityMonitor.isHidden = true
        self.activityMonitor.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        performSegue(withIdentifier: "goProfil", sender: "Foo")
    }
    
    func handleError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.searchButton.isHidden = false
        self.activityMonitor.isHidden = true
        self.activityMonitor.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goProfil" {
            if let vc = segue.destination as? ProfilViewController {
                vc.user = self.user
            }
        }
    }
}
