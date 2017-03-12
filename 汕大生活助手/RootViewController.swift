//
//  RootViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/22.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import JGProgressHUD
import AFNetworking


class RootViewController: DLHamburguerViewController {
    
//    var isFirstOpen = true
//    let coverView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        coverView.frame = self.view.frame
//        coverView.backgroundColor = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
//        self.view.addSubview(coverView)

        
        let currentUser: AVUser? = AVUser.current()
        let currentUsername = currentUser?.username ?? "visitor"
        

        let userDefault = UserDefaults.standard
        
        if let username = userDefault.object(forKey: "username") {
            
            let password = userDefault.object(forKey: "password")
            
            print("已有帐号")
            
            //送出登入的要求
            LCUser.logIn(username: username as! String, password: password as! String) { result in
                
                switch result {
                case .success(let user):
                    print("root2")
                    
                    AVUser.logIn(withUsername: username as! String, password: password as! String)
                    
                    self.isToken()
                    
                    
                case .failure(let error):
                    
                    print(error)
                    
                    
                    let HUD1 = JGProgressHUD(style: .dark)
                    HUD1?.textLabel.text = "网络连接出错>_<"
                    HUD1?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    HUD1?.show(in: self.view)
                    HUD1?.dismiss(afterDelay: 2.0, animated: true)
                    
                }
            }
            
        } else {
            print("游客")
            print("root3")
            
        }
        
   
  
    }
    
    
    func isToken() {
        // 取得token

        if let currentUser = LCUser.current {

            let userId = (currentUser.username?.value)!  // 用username作为userID
            let username = (currentUser.username?.value)!

            var portraitUri: String?
            // portraitStr
            let query = LCQuery(className: "_User")
            query.whereKey("username", .prefixedBy(username))
            query.getFirst { result in
                switch result {
                case .success(let todo):

                    if let token = todo.get("token")?.jsonString, token != nil {
                        // 有token了
                        print("已有token")
                        print(token)

                        self.connectWithToken(token: token)

                        

                    } else {

                        if let str = todo.get("image")?.jsonString {
                            let urls = getUrls(str)
                            portraitUri = urls[0]
                        } else {
                            portraitUri = "http://ac-56d0xu1v.clouddn.com/a1a80f5d4c67764ccb0d.png" // defaultPortrait.png
                        }
                        // 获取Token
                        self.getToken(username: username, userId: userId, portraitUri: portraitUri!)

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
        
    }

    func getToken(username: String, userId: String, portraitUri: String) {
        // 获取token

        let parameters = [
            "userId": userId,
            "name": username,
            "portraitUri": portraitUri
        ]

        let Timestamp = String(format: "%.0f",NSDate().timeIntervalSince1970)

        let Nonce: String = String(arc4random())
        let appSec = "kommELdadmw"

        let manage = AFHTTPRequestOperationManager()


        var sha1 = appSec + Nonce + Timestamp
        sha1 = (sha1 as NSString).sha1()
        let url = "https://api.cn.ronghub.com/user/getToken.json"
        let request = NSMutableURLRequest()
        request.timeoutInterval = 6

        request.httpMethod = "POST"

        manage.requestSerializer.setValue("y745wfm8yu1xv", forHTTPHeaderField: "App-Key")
        manage.requestSerializer.setValue(Nonce, forHTTPHeaderField: "Nonce")

        manage.requestSerializer.setValue(Timestamp, forHTTPHeaderField: "Timestamp")

        manage.requestSerializer.setValue(sha1, forHTTPHeaderField: "Signature")

        manage.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        manage.post(url, parameters: parameters, success: { (operation, data) -> Void in

            let dataDic = data as! NSDictionary
            let token = dataDic["token"] as! String
            print("获取并保存token")
            // 上传数据到LeanCloud
            let currentUser = AVUser.current
            currentUser()?.setObject(token, forKey: "token")

            currentUser()?.saveInBackground({ (succeed, error) in
                if succeed {

                    self.connectWithToken(token: token)

                }
            })
            
            
        }) { (operation, error) -> Void in
            
            print(error)
        }
        
    }

    
    func connectWithToken(token: String) {
        
        RCIM.shared().connect(withToken: token, success: { (_) -> Void in
            

            
        }, error: { (sender : RCConnectErrorCode) -> Void in
            
            print("连接失败")
            let HUD = JGProgressHUD(style: .dark)
            HUD?.textLabel.text = "连接失败>_<"
            HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2.0, animated: true)
        }) { () -> Void in
            
            print("token失效")
            let HUD = JGProgressHUD(style: .dark)
            HUD?.textLabel.text = "连接失败>_<"
            HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2.0, animated: true)
            
        }
        
    }



    

    override func viewDidAppear(_ animated: Bool) {
        
//        if self.isFirstOpen {
//            self.isFirstOpen = false
//            launchAnimation()
//        }
    }
    



//    func launchAnimation() {
//        
//        
//        let viewController: UIViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
//        let launchView = viewController.view
//        let mainWindow = UIApplication.shared.keyWindow
//        launchView?.frame = (mainWindow?.frame)!
//        mainWindow?.addSubview(launchView!)
//        
//        UIView.animate(withDuration: 2.0, delay: 0.5, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
//            launchView?.alpha = 0.0
//            launchView?.layer.transform = CATransform3DScale(CATransform3DIdentity, 2.0, 2.0, 2.0)
////            self.coverView.removeFromSuperview()
//        }) { (finished) in
//            launchView?.removeFromSuperview()
//            
//            
//        }
//        
//    }
    
    override func awakeFromNib() {

        print("#left")
        self.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeView")
        self.menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenuVC")
        
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
