//
//  nicknameViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/23.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import JGProgressHUD

class nicknameViewController: UIViewController {

    @IBOutlet weak var nicknameTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textField右边清除按钮
        self.nicknameTextField.clearButtonMode = .whileEditing
        self.nicknameTextField.becomeFirstResponder()
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        if let nickname = self.nicknameTextField.text, nickname.characters.count < 3 {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "昵称必须大于2个字符"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else if let nickname = self.nicknameTextField.text, nickname.characters.count > 10 {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "昵称不能大于10个字符"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.show(in: self.view)
            
            let currentUser = LCUser.current!
            currentUser.set("nickname", value: nicknameTextField.text)
            
            currentUser.save { result in
                
                switch result {
                case .success:
 
//                    // 发送通知
//                    let center = NotificationCenter.default
//                    center.post(name: NSNotification.Name(rawValue: "passValue_nickname"), object: nil)
                    
                    let HUD1 = JGProgressHUD(style: .dark)
                    HUD1?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                    HUD1?.textLabel.text = "成功"
                    HUD1?.square = true
                    HUD?.dismiss()
                    HUD1?.show(in: self.view)
                    HUD1?.dismiss(afterDelay: 2, animated: true)

                    var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(nicknameViewController.doDismiss), userInfo: nil, repeats: false)
                    

                case .failure(let error):
                
                    let HUD1 = JGProgressHUD(style: .dark)
                    HUD1?.textLabel.text =  "网络连接出错>_<"
                    HUD1?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    HUD?.dismiss()
                    HUD1?.show(in: self.view)
                    HUD1?.dismiss(afterDelay: 2.0, animated: true)

                }
                
            }

        }
    }
 
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    func doDismiss() {
        view.endEditing(true)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
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

}
