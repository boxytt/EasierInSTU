//
//  staticTableViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/22.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import JGProgressHUD

class staticTableViewController: UITableViewController {
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var nicknameLabel_small: UILabel!
    
    @IBOutlet weak var nicknameCell: UITableViewCell!
    @IBOutlet weak var myPostCell: UITableViewCell!
    
    var isVisitor = true
    
    var nickname: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionIndexBackgroundColor = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
        
        let currentUser: AVUser? = AVUser.current()
        let currentUsername = currentUser?.username ?? "visitor"
        
        if currentUsername == "visitor" {
            self.isVisitor = true
            self.nicknameCell.accessoryType = .none
            self.myPostCell.accessoryType = .none
            self.nicknameCell.isUserInteractionEnabled = false
            self.myPostCell.isUserInteractionEnabled = false

        } else {
            self.isVisitor = false
            self.nicknameCell.accessoryType = .disclosureIndicator
            self.myPostCell.accessoryType = .disclosureIndicator
            self.nicknameCell.isUserInteractionEnabled = true
            self.myPostCell.isUserInteractionEnabled = true
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        if let currentUser = LCUser.current {
            let email = (currentUser.email?.value)!.lowercased() // 当前用户的邮箱
            let username = (currentUser.username?.value)! // 当前用户名
            
            self.emailLabel.text = email
            self.usernameLabel.text = username
        
            getNickname(username)
            
        }
    }
    
    func getNickname(_ username: String) {
        
        let query = LCQuery(className: "_User")
        
        query.whereKey("username", .prefixedBy(username))
        
        query.getFirst { result in
            switch result {
            case .success(let todo):
                if let nickname = todo.get("nickname")?.jsonValue {
                    self.nicknameLabel_small.text = nickname as! String
                } else {
                    self.nicknameLabel_small.text = username
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDelegate&DataSource methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
        
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell: UITableViewCell! = tableView.cellForRow(at: indexPath)
        
        cell.selectedBackgroundView?.backgroundColor = UIColor(red: 155/255, green: 211/255, blue: 221/255, alpha: 1)
        
    }
    
    


}
