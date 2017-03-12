//
//  ResetPasswordViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/16.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import JGProgressHUD

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var translucentView: UIView!
    @IBOutlet weak var mailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view
        self.view.backgroundColor = UIColor(red: 114/255, green: 211/255, blue: 206/255, alpha: 1)
        self.translucentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        // delegate
        self.mailField.delegate = self
        
        // textField右边清除按钮
        self.mailField.clearButtonMode = .whileEditing
        
        // 键盘属性
        self.mailField.keyboardType = .emailAddress
        self.mailField.returnKeyType = .done

    }
    
    
    @IBAction func passwordReset(_ sender: Any) {
        
        let email = self.mailField.text
        let finalEmail = email!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if let email = email, email.characters.count < 8 {   // 限定汕大邮箱
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入合法的汕大邮箱"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
        } else {

            LCUser.requestPasswordReset(email: finalEmail) { (result) in
                
                switch result{
                case .success:
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                        showCloseButton: false,
                        dynamicAnimatorActive: true
                    )
                    let alert = SCLAlertView(appearance: appearance)
                    let icon = UIImage(named: "邮箱.png")
                    let color = UIColor(red: 114/255, green: 211/255, blue: 206/255, alpha: 1)

                    _ = alert.addButton("好的") {
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        })
                    }
                    _ = alert.showCustom("注意", subTitle: "请到汕大邮箱中\n完成最后的验证", color: color, icon: icon!)
                case .failure(let error):
                    
                    let code: Int = (error.code)
                    var reason: String = ""
                    
                    if code == 205 {
                        reason = "找不到电子邮箱地址对应的用户>_<"
                    } else {
                        reason = "网络连接出错>_<"
                    }
                    
                    let HUD = JGProgressHUD(style: .dark)
                    HUD?.textLabel.text = reason
                    HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    HUD?.show(in: self.view)
                    HUD?.dismiss(afterDelay: 2, animated: true)
                    

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
    
    // 叉叉X 按钮返回登录界面
    @IBAction func unwindToLoginView(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    

}
