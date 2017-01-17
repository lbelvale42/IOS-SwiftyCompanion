//
//  ProfilViewController.swift
//  SwiftyCompanion
//
//  Created by Lucas BELVALETTE on 11/7/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class ProfilViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var profilImage: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var lvlLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var staffLabel: UILabel!
    @IBOutlet weak var cursusLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var skillsTable: UITableView!
    @IBOutlet weak var projectsTable: UITableView!

    var user: User?
    var skills: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        staffLabel.isHidden = true
        skillsTable.layer.cornerRadius = 5
        projectsTable.layer.cornerRadius = 5
        progressBar.layer.cornerRadius = progressBar.frame.size.height * 2
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.contentSize = (contentView?.frame.size)!
        scrollView.zoomScale = 1.0
        scrollView.bounces = false
        if let loc = user?.location {
            locationLabel.text = loc
        }
        else {
            locationLabel.text = "Unavailable"
        }
        profilImage.layer.cornerRadius = profilImage.frame.size.width / 2
        profilImage.clipsToBounds = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let cursusName = user?.cursus?["cursus"]["name"].string
        if let grade = user?.cursus?["grade"].string {
         cursusLabel.text = "Cursus : " + cursusName! + " - Grade : \(grade)"
        }
        else {
            cursusLabel.text = "Cursus : " + cursusName!
        }
        let float = user?.cursus!["level"].float
        let arr = String(describing: float!).components(separatedBy: ".")
        let lvl = arr[0]
        let percent = arr[1]
        if (user?.isStaff! == true) {
            staffLabel.layer.cornerRadius = 5
            staffLabel.clipsToBounds = true
            staffLabel.isHidden = false
        }
        self.skills = user?.cursus?["skills"].array
        if skills?.count == 0 {
            skillsTable.isHidden = true
        }
        let proj = user?.cursus?["skills"].array
        if proj?.count == 0 {
            projectsTable.isHidden = true
        }
        infoLabel.text = "Wallet : \((user?.wallet!)!) - CP : \((user?.correctionPoint!)!)"
        lvlLabel.text = "lvl " + lvl + "-" + percent + "%"
        var curTitle = user?.titles!.last?["formatter"].string
        if (curTitle != nil) {
            curTitle = curTitle?.replacingOccurrences(of: "%login", with: (user?.login)!)
        }
        else {
            curTitle = user?.login
        }
        nameLabel.text = (user?.firstname!)! + " " + (user?.lastname!)! + " - " + curTitle!
        progressBar.progress = Float(percent)! / Float(100)
        Alamofire.request((user?.image_url)!).responseImage { response in
            DispatchQueue.main.async {
                self.profilImage.image = response.result.value
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "skills" {
            return (self.skills!.count)
        }
        else {
            return (user?.projects_users?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.restorationIdentifier == "skills" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "skillCell") as! SkillTableViewCell
            cell.nameLabel.text = skills?[indexPath.row]["name"].string
            let note = skills?[indexPath.row]["level"].float
            cell.noteLabel.text = String(describing: note!)
            let rate = note! / 20.00
            cell.progressView.progress = rate
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell") as! ProjectTableViewCell
            cell.nameLabel.text = user?.projects_users?[indexPath.row]["project"]["name"].string
            let validate = user?.projects_users?[indexPath.row]["validated?"].bool
            let finish = user?.projects_users?[indexPath.row]["status"].string
            let note = user?.projects_users?[indexPath.row]["final_mark"].int
            if let f = finish {
                if let v = validate {
                    if v == true {
                      cell.noteLabel.textColor = UIColor(red: 0, green: 132/255, blue: 13/255, alpha: 1)
                    }
                    else {
                        cell.noteLabel.textColor = UIColor.red
                    }
                    if let n = note {
                        cell.noteLabel.text = String(n)
                        cell.progressView.progress = Float(n) / 125.00
                    }
                }
                else {
                    if f == "in_progress" {
                        cell.noteLabel.text = "In progress"
                        cell.progressView.progress = 0.00
                        cell.noteLabel.textColor = UIColor.black
                    }
                    else if f == "parent" {
                        cell.noteLabel.text = "X"
                        cell.progressView.progress = 0.00
                        cell.noteLabel.textColor = UIColor.red
                    }
                    else {
                        cell.noteLabel.text = "???"
                        cell.progressView.progress = 0.00
                        cell.noteLabel.textColor = UIColor.black
                    }
                }
            }
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.restorationIdentifier == "skills" {
            return "Skills"
        }
        else {
            return "Projects"
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
