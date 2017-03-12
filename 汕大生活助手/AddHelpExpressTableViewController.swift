//
//  AddHelpExpressTableViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/30.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud
import JGProgressHUD

class AddHelpExpressTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var placeHolderLabel2: UILabel!
    @IBOutlet weak var placeHolderLabel3: UILabel!
    @IBOutlet weak var contactInfoTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.descriptionTextView.delegate = self
        self.contactInfoTextField.delegate = self
        
        // 左边距
        self.contactInfoTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.contactInfoTextField.leftViewMode = .always
        
        // 清除按钮
        self.contactInfoTextField.clearButtonMode = .whileEditing
        
        
        self.placeHolderLabel.alpha = 0.2
        self.placeHolderLabel2.alpha = 0.2
        self.placeHolderLabel3.alpha = 0.2
        
        // 去掉tableView多余的横线
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // 设置datePicker
        let date: Date = Date()
        self.datePicker.setDate(date as Date, animated: false)
        self.datePicker.minimumDate = date as Date
        
        if self.view.bounds.width == 320 {
            self.placeHolderLabel.text = "输入你想说的话（时间段、只拿哪个地方"
            self.placeHolderLabel2.text = "的快递、是否送上宿舍、送到哪些宿舍、"
            self.placeHolderLabel3.text = "在哪里找我拿、是否收费等）"
            
        } else if self.view.bounds.width == 375 {
            self.placeHolderLabel.text = "输入你想说的话（时间段、只拿哪个地方的快递、"
            self.placeHolderLabel2.text = "是否送上宿舍、送到哪些宿舍、在哪里找我拿、是"
            self.placeHolderLabel3.text = "否收费等）"
            
        } else if self.view.bounds.width == 414 {
            self.placeHolderLabel.text = "输入你想说的话（时间段、只拿哪个地方的快递、是否"
            self.placeHolderLabel2.text = "送上宿舍、送到哪些宿舍、在哪里找我拿、是否收费等)"
            self.placeHolderLabel3.text = ""
            
        }

        
        
        
    }
    
    
    
    // 实现textView的类似placeholder属性
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            
            if self.view.bounds.width == 320 {
                self.placeHolderLabel.text = "输入你想说的话（时间段、只拿哪个地方"
                self.placeHolderLabel2.text = "的快递、是否送上宿舍、送到哪些宿舍、"
                self.placeHolderLabel3.text = "在哪里找我拿、是否收费等）"
                
            } else if self.view.bounds.width == 375 {
                self.placeHolderLabel.text = "输入你想说的话（时间段、只拿哪个地方的快递、"
                self.placeHolderLabel2.text = "是否送上宿舍、送到哪些宿舍、在哪里找我拿、是"
                self.placeHolderLabel3.text = "否收费等）"
                
            } else if self.view.bounds.width == 414 {
                self.placeHolderLabel.text = "输入你想说的话（时间段、只拿哪个地方的快递、是否"
                self.placeHolderLabel2.text = "送上宿舍、送到哪些宿舍、在哪里找我拿、是否收费等)"
                self.placeHolderLabel3.text = ""
                
            }

        } else {
            placeHolderLabel.text = ""
            placeHolderLabel2.text = ""
            placeHolderLabel3.text = ""
        }
    }
    
    // 收回键盘
    @IBAction func handleTap(_ sender: Any) {
        self.descriptionTextView.resignFirstResponder()
        self.contactInfoTextField.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    

    @IBAction func saveBtnClicked(_ sender: Any){
        //收回键盘
        view.endEditing(true)
        
        if let description = descriptionTextView.text, description == "" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入求助信息"
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
                    
                    let todo = LCObject(className: "HelpExpress")
                    todo.set("username", value: username)
                    todo.set("description", value: self.descriptionTextView.text)
                    todo.set("contactInfo", value: (self.contactInfoTextField.text)!)
                    todo.set("deadline", value: self.datePicker.date)
                    
                    // Pointer关联到具体的user对象
                    let user = LCObject(className: "_User", objectId: userId)
                    todo.set("toUser", value: user)
                    
                    todo.save { (result) in
                        // 网络活动指示器
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if result.isSuccess {
                            
                            
                            // 发送通知
                            let center = NotificationCenter.default
                            center.post(name: NSNotification.Name(rawValue: "passValue_express"), object: nil)
                            center.post(name: NSNotification.Name(rawValue: "passValue_delete_other"), object: nil)
                            
                            let HUD1 = JGProgressHUD(style: .dark)
                            HUD1?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                            HUD1?.textLabel.text = "发布成功"
                            HUD1?.square = true
                            HUD?.dismiss()
                            HUD1?.show(in: self.view)
                            HUD1?.dismiss(afterDelay: 2, animated: true)
                            
                            var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(AddHelpExpressTableViewController.doDismiss), userInfo: nil, repeats: false)
                            
                        } else {
                            print(result.error)
                            let HUD1 = JGProgressHUD(style: .dark)
                            HUD1?.textLabel.text = "网络连接出错>_<"
                            HUD1?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                            HUD?.dismiss()
                            HUD1?.show(in: self.view)
                            HUD1?.dismiss(afterDelay: 2.0, animated: true)
                            
                            
                        }
                        
                        
                    }

                    
                })
            }
            _ = alert.addButton("取消") {
                
            }
            
            _ = alert.showCustom("请仔细阅读", subTitle: "我们只为您提供发布消息的平台\n当有人想找您帮时才会联系您\n如需更近一步交流还得麻烦您\n当不再接受请求，请删除掉这个贴\n以免受到不必要的骚扰\n超过截止时间会自动删除\n贵重物品最好让TA自己去拿哦", color: color, icon: icon!)
        }
        
    }

    
    func doDismiss() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 35
        } else {
            return 20
        }
    }
}
