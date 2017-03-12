//
//  AddBuyTableViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/29.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud
import JGProgressHUD

class AddBuyTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var contactInfoTextField: UITextField!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    var needGetNew: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate
        self.descriptionTextView.delegate = self
        self.contactInfoTextField.delegate = self
        
        // contactInfoTextField
        self.contactInfoTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.contactInfoTextField.leftViewMode = .always
        self.contactInfoTextField.clearButtonMode = .whileEditing
        self.contactInfoTextField.returnKeyType = .done
       
        // textView
        self.placeHolderLabel.alpha = 0.2

        
        // 去掉多余的线
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        
    }
    
    // 实现textView的类似placeholder属性
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            placeHolderLabel.text = "描述一下你的宝贝"
        } else {
            placeHolderLabel.text = ""
        }
    }
    
    // 回收键盘
    @IBAction func handleTap(_ sender: Any) {
        self.descriptionTextView.resignFirstResponder()
        self.contactInfoTextField.resignFirstResponder()
    }
    
    
    
    // MARK: 点击保存按钮
    @IBAction func saveBtnClicked(_ sender: Any) {
        //收回键盘
        view.endEditing(true)
        
        if let description = descriptionTextView.text, description == "" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请描述一下你的宝贝"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else if let contactInfo = contactInfoTextField.text, contactInfo == "" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请留下你的联系方式"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else {
            //询问是否添加
            
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: false,
                dynamicAnimatorActive: true
            )
            let alert = SCLAlertView(appearance: appearance)
            let icon = UIImage(named: "添加帖子.png")
            let color = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
            _ = alert.addButton("确定添加") {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let HUD = JGProgressHUD(style: .dark)
                    HUD?.show(in: self.view)
                    
                    // 网络活动指示器
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    
                    // 上传数据到LeanCloud
                    let currentUser = LCUser.current!
                    let username = (currentUser.username?.value)!
                    let userId = (currentUser.objectId?.value)!
                    
                    let todo = AVObject(className: "Buy")
                    todo.setObject(self.descriptionTextView.text, forKey: "description")
                    todo.setObject((self.contactInfoTextField.text)!, forKey: "contactInfo")
                    todo.setObject(username, forKey: "username")
                    
                    // Pointer关联到具体的user对象
                    let user = AVObject(className: "_User", objectId: userId)
                    todo.setObject(user, forKey: "toUser")
                    
                    todo.saveInBackground({ (succeeded, error) in
                        // 网络活动指示器
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if succeeded {
                            
                            
                            // 发送通知
                            let center = NotificationCenter.default
                            center.post(name: NSNotification.Name(rawValue: "passValue_secondhand"), object: nil)
                            center.post(name: NSNotification.Name(rawValue: "passValue_delete_other"), object: nil)
                            
                            let HUD1 = JGProgressHUD(style: .dark)
                            HUD1?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                            HUD1?.textLabel.text = "发布成功"
                            HUD1?.square = true
                            HUD?.dismiss()
                            HUD1?.show(in: self.view)
                            HUD1?.dismiss(afterDelay: 2, animated: true)
                            
                            var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(AddBuyTableViewController.doDismiss), userInfo: nil, repeats: false)
                            
                            
                        } else {
                            print(error)
                            let HUD1 = JGProgressHUD(style: .dark)
                            HUD1?.textLabel.text = "网络连接出错>_<"
                            HUD1?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                            HUD?.dismiss()
                            HUD1?.show(in: self.view)
                            HUD1?.dismiss(afterDelay: 2.0, animated: true)
                            
                        }
                    })

                    
                })
            }
            _ = alert.addButton("取消") {
                
            }
            
            _ = alert.showCustom("请仔细阅读", subTitle: "我们只为您提供发布消息的平台\n当别人想卖给您时会主动联系您\n具体解释、讨价还价等还得麻烦您\n当不需要这个贴时，请自觉删除掉\n以免受到不必要的骚扰", color: color, icon: icon!)
            
            
        }

    }

    

    
    func doDismiss() {
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)

    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}
