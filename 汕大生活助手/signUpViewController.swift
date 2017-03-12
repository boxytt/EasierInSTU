//
//  signUpViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/16.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud
import JGProgressHUD

class signUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var translucentView: UIView!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        self.mailField.delegate = self
        
        // textField右边清除按钮
        self.usernameField.clearButtonMode = .whileEditing
        self.mailField.clearButtonMode = .whileEditing
        self.passwordField.clearButtonMode = .whileEditing
        
        // view
        self.view.backgroundColor = UIColor(red: 172/255, green: 214/255, blue: 206/255, alpha: 1)
        self.translucentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        // 键盘属性
        self.usernameField.keyboardType = .asciiCapable
        self.passwordField.keyboardType = .asciiCapable
        self.mailField.keyboardType = .emailAddress
        self.usernameField.returnKeyType = .done
        self.passwordField.returnKeyType = .done
        self.mailField.returnKeyType = .done
        self.passwordField.isSecureTextEntry = true
        
        
    }
    
    
    @IBAction func signUpAction(_ sender: Any) {
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.mailField.text
        
        let finalEmail = email!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
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
            
        } else if let email = email, email.characters.count < 11 {
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入合法的汕大邮箱"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else if let email = email, email.range(of: "@stu.edu.cn") == nil {
            print("不合法")
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入合法的汕大邮箱"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else {
            // 旋转活动指示器
            let HUD = JGProgressHUD(style: .dark)
            HUD?.show(in: self.view)
            
            // 网络活动指示器
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
            let newUser = LCUser()
            
            newUser.username = LCString(username!)
            newUser.password = LCString(password!)
            newUser.email = LCString(finalEmail)
            
            newUser.signUp { (result) in
                
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                
                switch result {
                case .success:
                    // 注册成功，则弹出提示框，确认后dismiss到LoginView
                    // 用户注册时，自动发送邮箱验证；未验证邮箱的用户，禁止登陆
                    
                    HUD?.dismiss()

                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                        showCloseButton: false,
                        dynamicAnimatorActive: true
                    )
                    let alert = SCLAlertView(appearance: appearance)
                    let icon = UIImage(named: "邮箱.png")
                    let color = UIColor(red: 172/255, green: 214/255, blue: 206/255, alpha: 1)
                    _ = alert.addButton("好的") {
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        })
                    }
                    _ = alert.showCustom("注意", subTitle: "请到汕大邮箱中\n完成最后的验证", color: color, icon: icon!)
                    
                    
                case .failure(let error):
                    
                    // 注册不成功，则弹出提示框给出错误信息
                    // 用户名被占用或邮箱已注册过都会出错
                    
                    let code: Int = (error.code)
                    var reason: String = ""
                    
                    if code == 202 {
                        reason = "用户名已经被占用>_<"
                    } else if code == 203 {
                        reason = "电子邮箱地址已经被占用>_<"
                    } else {
                        reason = "网络连接出错>_<"
                    }
                    
                    let HUD1 = JGProgressHUD(style: .dark)
                    HUD1?.textLabel.text = reason
                    HUD1?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    HUD?.dismiss()
                    HUD1?.show(in: self.view)
                    HUD1?.dismiss(afterDelay: 2.0, animated: true)
                    

                }
                
            }
            
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: 键盘事件
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // 关闭按钮返回登录界面
    @IBAction func unwindToLoginView(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }

}
