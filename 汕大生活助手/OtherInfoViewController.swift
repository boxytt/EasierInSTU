//
//  OtherInfoViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/12/21.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import AVOSCloud
import Kingfisher
import JGProgressHUD
import LeanCloud

class OtherInfoViewController: UIViewController {

    var portraitImageView = UIImageView()
    var cicleImageView = UIImageView()
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var chatButton: UIButton!
    
    var user: [AVObject] = []
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true

    
        let user0 = self.user[0]

        self.nicknameLabel.text = user0["nickname"] as! String?
        
        if self.view.bounds.width == 320 {
            self.portraitImageView = UIImageView(frame: CGRect(x: 120, y: 49, width: 80, height: 80))
            self.portraitImageView.layer.cornerRadius = 40
            self.portraitImageView.clipsToBounds = true
            
            self.cicleImageView = UIImageView(frame: CGRect(x: 120, y: 49, width: 86, height: 86))
            self.cicleImageView.layer.cornerRadius = 43
            self.cicleImageView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            self.cicleImageView.layer.borderWidth = 4
            self.cicleImageView.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
            self.cicleImageView.center = self.portraitImageView.center



        } else if self.view.bounds.width == 375 {
            print("375")
            self.portraitImageView = UIImageView(frame: CGRect(x: 142, y: 59, width: 90, height: 90))
            self.portraitImageView.layer.cornerRadius = 45
            self.portraitImageView.clipsToBounds = true
            
            self.cicleImageView = UIImageView(frame: CGRect(x: 120, y: 49, width: 96, height: 96))
            self.cicleImageView.layer.cornerRadius = 48
            self.cicleImageView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            self.cicleImageView.layer.borderWidth = 4
            self.cicleImageView.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
            self.cicleImageView.center = self.portraitImageView.center

 

        } else if self.view.bounds.width == 414 {
            self.portraitImageView = UIImageView(frame: CGRect(x: 157, y: 56, width: 100, height: 100))
            self.portraitImageView.layer.cornerRadius = 50
            self.portraitImageView.clipsToBounds = true
            
            self.cicleImageView = UIImageView(frame: CGRect(x: 120, y: 49, width: 106, height: 106))
            self.cicleImageView.layer.cornerRadius = 53
            self.cicleImageView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            self.cicleImageView.layer.borderWidth = 4
            self.cicleImageView.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
            self.cicleImageView.center = self.portraitImageView.center
            


        }
        
        // 头像
        let imgFile = user0["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        self.portraitImageView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)

        self.contentView.addSubview(self.cicleImageView)
        self.contentView.addSubview(self.portraitImageView)
        
        // 发消息按钮
        let currentUser = AVUser.current()
        let currentUsername = (currentUser?.username)!
        
        
        
        if currentUsername == user0["username"] as! String? {
            
            self.chatButton.isHidden = true
            
        } else {
            print("false")
            self.chatButton.isHidden = false
            self.chatButton.clipsToBounds = true
            self.chatButton.layer.cornerRadius = 5
            self.chatButton.addTarget(self, action: #selector(OtherInfoViewController.chatBtnClicked(_:)), for: .touchUpInside)

        }
        
        

        
    }
    
    

    
   
    func chatBtnClicked(_ button: UIButton) {
        
        print("chatBtnClicked")
        
     
        let user0 = self.user[0]
        let username = user0["nickname"] as! String?
        let userId = user0["username"] as! String   // 申请token时，用username作为userId
        let token = user0["token"] as! String
        
        // 判断是不是iPhone
        let query = LCQuery(className: "_User")
        
        query.whereKey("username", .prefixedBy(userId))
        
        query.getFirst { result in
            switch result {
            case .success(let todo):
                if let deviceModel = todo.get("deviceModel")?.jsonString {
                    
                    if deviceModel as! String == "iPhone" {
                        let vc = ChatViewController(conversationType: .ConversationType_PRIVATE, targetId: userId)
                        vc?.title = username
  
                        self.navigationController?.pushViewController(vc!, animated: true)

                    } else {
                        
                        let HUD = JGProgressHUD(style: .dark)
                        HUD?.textLabel.text = "暂时不能与安卓手机进行通讯>_<"
                        HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                        HUD?.show(in: self.view)
                        HUD?.dismiss(afterDelay: 2.0, animated: true)
                        
                    }
                    
                } else {
                    let HUD = JGProgressHUD(style: .dark)
                    HUD?.textLabel.text = "暂时不能与安卓手机进行通讯>_<"
                    HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    HUD?.show(in: self.view)
                    HUD?.dismiss(afterDelay: 2.0, animated: true)

                }
            case .failure(let error):
                print(error)
            }
        }
  
        
    }
    
 
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    //传给staticTableView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStatic" {
            print("prepare")
            let controller = segue.destination as! OtherStaticTableViewController
            controller.user = self.user
        }
    }
}
