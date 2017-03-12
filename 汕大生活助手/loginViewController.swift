//
//  loginViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/16.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud
import JGProgressHUD
import AFNetworking



class loginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var translucentView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.clearAllNotice()
        // view
        self.view.backgroundColor = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
        self.translucentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        // delegate
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        // textField右边清除按钮
        self.usernameField.clearButtonMode = .whileEditing
        self.passwordField.clearButtonMode = .whileEditing
        
        // 键盘属性
        self.usernameField.keyboardType = .asciiCapable
        self.passwordField.keyboardType = .asciiCapable
        self.usernameField.returnKeyType = .done
        self.passwordField.returnKeyType = .done
        
        self.passwordField.isSecureTextEntry = true
        
        let currentUser: AVUser? = AVUser.current()
        let currentUsername = currentUser?.username ?? "visitor"
        
        
        if currentUsername == "visitor" {
            print("visitor")
            self.closeButton.isEnabled = true
            self.closeButton.isHidden = false
        } else {
            print("not visitor")
            self.closeButton.isEnabled = false
            self.closeButton.isHidden = true
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        

        
    }
    

    @IBAction func closeBtnClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
 
    @IBAction func loginAction(_ sender: Any) {
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        // 验证textField
        if let username = username, username.characters.count < 5 {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "用户名长度必须大于5个字符"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
            
            
        } else if let password = password, password.characters.count < 5 {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "密码长度必须大于5个字符"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
            
        } else {
            // 旋转活动指示器
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.show(in: self.view)
            
            
            // 网络活动指示器
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            //送出登入的要求
            LCUser.logIn(username: username!, password: password!) { result in
                
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                switch result {
                case .success(let user):
                    AVUser.logIn(withUsername: username!, password: password!)
                    
                    let userDefault = UserDefaults.standard
                    userDefault.set(username, forKey: "username")
                    userDefault.set(password, forKey: "password")
                    userDefault.synchronize()
                    
                    HUD?.dismiss()
                    
//                    self.isToken()
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootView")
                    self.present(viewController, animated: true, completion: nil)
                   

                    
                case .failure(let error):
                    
                    
                    let code: Int = (error.code)
                    var reason: String = ""
                    if code == 210 {
                        reason = "用户名和密码不匹配>_<"
                    } else if code == 211 {
                        reason = "找不到用户>_<"
                    } else if code == 216 {
                        reason = "未验证的邮箱地址>_<"
                    } else {
                        reason = "网络连接出错>_<"
                    }
                    
                    let HUD1 = JGProgressHUD(style: .dark)
                    HUD1?.textLabel.text = reason
                    HUD1?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    HUD?.dismiss()
                    HUD1?.show(in: self.view)
                    HUD1?.dismiss(afterDelay: 3.0, animated: true)
                    
                }
            }
            
        }
        
        
    }
    
//    func isToken() {
//        // 取得token
//        
//        if let currentUser = LCUser.current {
//            
//            let userId = (currentUser.username?.value)!  // 用username作为userID
//            let username = (currentUser.username?.value)!
//            
//            var portraitUri: String?
//            // portraitStr
//            let query = LCQuery(className: "_User")
//            query.whereKey("username", .prefixedBy(username))
//            query.getFirst { result in
//                switch result {
//                case .success(let todo):
//                    
//                    if let token = todo.get("token")?.jsonString, token != nil {
//                        // 有token了
//                        print("已有token")
//
//                        self.connectWithToken(token: token)
//                        
//                    } else {
//                        
//                        if let str = todo.get("image")?.jsonString {
//                            let urls = getUrls(str)
//                            portraitUri = urls[0]
//                        } else {
//                            portraitUri = "http://ac-56d0xu1v.clouddn.com/a1a80f5d4c67764ccb0d.png" // defaultPortrait.png
//                        }
//                        // 获取Token
//                        self.getToken(username: username, userId: userId, portraitUri: portraitUri!)
//                        
//                        }
//                    
//                    
//                case .failure(let error):
//                    print(error)
//                    
//                    let HUD = JGProgressHUD(style: .dark)
//                    HUD?.textLabel.text = "网络连接出错>_<"
//                    HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
//                    HUD?.show(in: self.view)
//                    HUD?.dismiss(afterDelay: 2.0, animated: true)
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//    
//    func getToken(username: String, userId: String, portraitUri: String) {
//        // 获取token
//        
//        let parameters = [
//            "userId": userId,
//            "name": username,
//            "portraitUri": portraitUri
//        ]
//        
//        let Timestamp = String(format: "%.0f",NSDate().timeIntervalSince1970)
//        
//        let Nonce: String = String(arc4random())
//        let appSec = "kommELdadmw"
//        
//        let manage = AFHTTPRequestOperationManager()
//        
//        
//        var sha1 = appSec + Nonce + Timestamp
//        sha1 = (sha1 as NSString).sha1()
//        let url = "https://api.cn.ronghub.com/user/getToken.json"
//        let request = NSMutableURLRequest()
//        request.timeoutInterval = 6
//        
//        request.httpMethod = "POST"
//        
//        manage.requestSerializer.setValue("y745wfm8yu1xv", forHTTPHeaderField: "App-Key")
//        manage.requestSerializer.setValue(Nonce, forHTTPHeaderField: "Nonce")
//        
//        manage.requestSerializer.setValue(Timestamp, forHTTPHeaderField: "Timestamp")
//        
//        manage.requestSerializer.setValue(sha1, forHTTPHeaderField: "Signature")
//        
//        manage.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        manage.post(url, parameters: parameters, success: { (operation, data) -> Void in
//            
//            let dataDic = data as! NSDictionary
//            let token = dataDic["token"] as! String
//            print("获取并保存token")
//            // 上传数据到LeanCloud
//            let currentUser = AVUser.current
//            currentUser()?.setObject(token, forKey: "token")
//            
//            currentUser()?.saveInBackground({ (succeed, error) in
//                if succeed {
//                    
//                    self.connectWithToken(token: token)
//
//                }
//            })
//            
//            
//        }) { (operation, error) -> Void in
//            
//            print(error)
//        }
//        
//    }
//    
//
//    func connectWithToken(token: String) {
//        
//        RCIM.shared().connect(withToken: token, success: { (_) -> Void in
//            print(token)
//            
//            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeView")
//
//            DispatchQueue.main.sync {
//                
//                self.present(viewController, animated: true, completion: nil)
//                UIView.setAnimationsEnabled(true)
//
//            }
//            
//        }, error: { (sender : RCConnectErrorCode) -> Void in
//            print("连接失败")
//            let HUD = JGProgressHUD(style: .dark)
//            HUD?.textLabel.text = "连接失败>_<"
//            HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
//            HUD?.show(in: self.view)
//            HUD?.dismiss(afterDelay: 2.0, animated: true)
//        }) { () -> Void in
//            
//            print("token失效")
//            let HUD = JGProgressHUD(style: .dark)
//            HUD?.textLabel.text = "连接失败>_<"
//            HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
//            HUD?.show(in: self.view)
//            HUD?.dismiss(afterDelay: 2.0, animated: true)
//            
//        }
//
//    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        let deviceModel = UIDevice.current.model //获取设备的型号 例如：iPhone
        
        let currentUser = AVUser.current
        currentUser()?.setObject(deviceModel, forKey: "deviceModel")
        
        currentUser()?.save()

 
    }
    
    
    // MARK: 键盘事件
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        self.clearAllNotice()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
