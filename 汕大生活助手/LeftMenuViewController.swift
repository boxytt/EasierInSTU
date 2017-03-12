//
//  LeftMenuViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/22.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import Kingfisher
import AVOSCloud
import JGProgressHUD


class LeftMenuViewController: UIViewController {

    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var loginOrQuitButton: UIButton!
    @IBOutlet weak var nicknameLabel_big: UILabel!
    @IBOutlet weak var portraitView: UIImageView!
    @IBOutlet weak var portraitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundView.backgroundColor = UIColor.white
        self.loginOrQuitButton.backgroundColor = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)

        self.portraitButton.backgroundColor = UIColor.clear
        self.portraitButton.layer.cornerRadius = 43
        self.portraitButton.layer.borderWidth = 1.5
        self.portraitButton.layer.borderColor = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1).cgColor
        
        self.portraitView.layer.cornerRadius = 40
        self.portraitView.clipsToBounds = true

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(getNewNickname(_:)), name: NSNotification.Name(rawValue: "passValue_nickname"), object: nil)
        center.addObserver(self, selector: #selector(getNewPortrait(_:)), name: NSNotification.Name(rawValue: "passValue_portrait"), object: nil)

        let currentUser: AVUser? = AVUser.current()
        let currentUsername = currentUser?.username ?? "visitor"
        
        if currentUsername == "visitor" {
            self.loginOrQuitButton.setTitle("登陆", for: .normal)
            self.portraitButton.isEnabled = false
            
          
        } else {
        
            // 网络活动指示器
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            self.portraitButton.isEnabled = true
            getPortrait(currentUsername)
            getNickname(currentUsername)
            self.loginOrQuitButton.setTitle("退出当前帐号", for: .normal)
        }

      
    }
    
    
    // MARK: 从云存储获取数据
    
    func getPortrait(_ username: String) {
        print("getPortrait")

        let query = LCQuery(className: "_User")
        
        query.whereKey("username", .prefixedBy(username))
        
        query.getFirst { result in
            switch result {
            case .success(let todo):
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                
                if let str = todo.get("image")?.jsonString {
                    
                    let urls = getUrls(str)
                    let imageUrlString = urls[0]
                    
                    let url: URL! = URL(string: imageUrlString)
                    
                    
                    self.portraitView.kf.setImage(with: url!, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(0.5))], progressBlock: nil, completionHandler: nil)
                    
                } else {
                    

                    self.portraitView.image = UIImage(named: "defaultPortrait.png")
                    
                    let currentUser = AVUser.current
                    let username = (currentUser()?.username)!
                    
                    let imgFile = AVFile(url: "http://ac-56d0xu1v.clouddn.com/a1a80f5d4c67764ccb0d.png") // defaultPortrait.png
                    currentUser()?.setObject(imgFile, forKey: "image")
                    currentUser()?.setObject(username, forKey: "nickname")
                    currentUser()?.saveInBackground()

                    
                }

            case .failure(let error):
                print(error)
            
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)

            }
        }
        
    }
    
    func getNickname(_ username: String) {
        
        let query = LCQuery(className: "_User")
        
        query.whereKey("username", .prefixedBy(username))
        
        
        query.getFirst { result in
            switch result {
            case .success(let todo):
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if let nickname = todo.get("nickname")?.jsonValue {
                    self.nicknameLabel_big.text = nickname as! String
                } else {
                    self.nicknameLabel_big.text = username
                }
                
            case .failure(let error):
                print(error)
                
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                
            }
        }
        
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginOrQuitBtnClicked(_ sender: Any) {
        
        if self.loginOrQuitButton.titleLabel?.text == "退出当前帐号" {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: false,
                dynamicAnimatorActive: true
            )
            let alert = SCLAlertView(appearance: appearance)
            let icon = UIImage(named: "退出.png")
            let color =  UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
            _ = alert.addButton("确定") {
                DispatchQueue.main.async(execute: { () -> Void in
                    // 将RCIM退出，并删除UserInfo
                    RCIM.shared().logout()
                    RCIM.shared().disconnect()
//                    LCUser.logOut()
//                    AVUser.logOut()
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as! loginViewController
                    self.present(viewController, animated: true, completion: nil)

                })
            }
            _ = alert.addButton("取消") {
                
            }
            
            _ = alert.showCustom("注意", subTitle: "确定退出当前帐号吗?", color: color, icon: icon!)
            
        } else {
            
            
            DispatchQueue.main.async(execute: { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as! loginViewController
                self.present(viewController, animated: true, completion: nil)
            })
        }
        
    }
    

    
    

    
    
    // MARK: - Navigation
    
     func mainNavigationController() -> DLHamburguerNavigationController {
     return self.storyboard?.instantiateViewController(withIdentifier: "DLDemoNavigationViewController") as! DLHamburguerNavigationController
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPortraitView" {
            
            let destinationNavigationController = segue.destination as! UINavigationController
            let destVC = destinationNavigationController.topViewController as! portraitViewController
            destVC.image = self.portraitView.image!
        }
    }


    
    
 
    @IBAction func unwindToLeftMenu(_ segue: UIStoryboardSegue) {
        
        
    }
    
    
    func getNewNickname(_ notification: Notification) {
  
        if let currentUser = LCUser.current {
            let username = (currentUser.username?.value)! // 当前用户名
            getNickname(username)
            
            
        }
    }

    func getNewPortrait(_ notification: Notification) {
  
        if let currentUser = LCUser.current {
            let username = (currentUser.username?.value)! // 当前用户名
            print("收到消息")
            getPortrait(username)
            
        }
    }


    


}
