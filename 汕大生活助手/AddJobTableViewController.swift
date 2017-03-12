//
//  AddJobTableViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/30.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud
import JGProgressHUD

class AddJobTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var contactInfoTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate
        self.typeTextField.delegate = self
        self.contentTextField.delegate = self
        self.placeTextField.delegate = self
        self.timeTextField.delegate = self
        self.remarkTextField.delegate = self
        self.contactInfoTextField.delegate = self
        self.priceTextField.delegate = self
        
        // 清楚按钮
        self.typeTextField.clearButtonMode = .whileEditing
        self.contentTextField.clearButtonMode = .whileEditing
        self.placeTextField.clearButtonMode = .whileEditing
        self.timeTextField.clearButtonMode = .whileEditing
        self.remarkTextField.clearButtonMode = .whileEditing
        self.contactInfoTextField.clearButtonMode = .whileEditing
        self.priceTextField.clearButtonMode = .whileEditing

        // 键盘属性
        self.typeTextField.returnKeyType = .done
        self.contentTextField.returnKeyType = .done
        self.placeTextField.returnKeyType = .done
        self.timeTextField.returnKeyType = .done
        self.remarkTextField.returnKeyType = .done
        self.contactInfoTextField.returnKeyType = .done
        self.priceTextField.keyboardType = .decimalPad
        
        // 左边距
        self.typeTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.contentTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.placeTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.timeTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.priceTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.remarkTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.contactInfoTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.contactInfoTextField.leftViewMode = .always
        self.priceTextField.leftViewMode = .always
        self.remarkTextField.leftViewMode = .always
        self.placeTextField.leftViewMode = .always
        self.timeTextField.leftViewMode = .always
        self.typeTextField.leftViewMode = .always
        self.contentTextField.leftViewMode = .always

        // 去掉多余的线
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

              
    }
    


    @IBAction func saveBtnClicked(_ sender: Any) {
        //收回键盘
        view.endEditing(true)
        
        if let type = typeTextField.text, type == "" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入兼职类型"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else if let content = contentTextField.text, content == "" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入兼职具体内容"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else if let place = placeTextField.text, place == "" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入兼职地点"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else if let time = timeTextField.text, time == "" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入兼职时间"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else if let contactInfo = contactInfoTextField.text, contactInfo == "" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入联系方式"
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
                    
                    // set属性
                    let todo = LCObject(className: "Job")
                    todo.set("username", value: username)
                    todo.set("type", value: (self.typeTextField.text)!)
                    todo.set("contactInfo", value: (self.contactInfoTextField.text)!)
                    // description
                    let array = [self.contentTextField.text!, self.placeTextField.text!, self.timeTextField.text!, self.priceTextField.text!,self.remarkTextField.text!]
                    let des = array[0] + "。兼职地点是" + array[1] + "。兼职时间是" + array[2] + "。" + "薪水是" + array[3] + "元。" + array[4]
                    print(des)
                    todo.set("description", value: (des))

                    
                    // Pointer关联到具体的user对象
                    let user = LCObject(className: "_User", objectId: userId)
                    todo.set("toUser", value: user)
                    
                    todo.save { (result) in
                        // 网络活动指示器
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if result.isSuccess {
                            
                            
                            // 发送通知
                            let center = NotificationCenter.default
                            center.post(name: NSNotification.Name(rawValue: "passValue_Job"), object: nil)
                            center.post(name: NSNotification.Name(rawValue: "passValue_delete_other"), object: nil)
                            
                            let HUD1 = JGProgressHUD(style: .dark)
                            HUD1?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                            HUD1?.textLabel.text = "发布成功"
                            HUD1?.square = true
                            HUD?.dismiss()
                            HUD1?.show(in: self.view)
                            HUD1?.dismiss(afterDelay: 2, animated: true)
                            
                            var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(AddJobTableViewController.doDismiss), userInfo: nil, repeats: false)
                            
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
            
            _ = alert.showCustom("请仔细阅读", subTitle: "我们只为您提供发布消息的平台\n当别人想要此兼职时会主动联系您\n更近一步交流还得麻烦您\n当此兼职被领走后，请自觉删除掉\n以免受到不必要的骚扰", color: color, icon: icon!)
            
            
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
    
    
    // 回收键盘
    @IBAction func handleTap(_ sender: Any) {
        self.typeTextField.resignFirstResponder()
        self.contentTextField.resignFirstResponder()
        self.placeTextField.resignFirstResponder()
        self.timeTextField.resignFirstResponder()
        self.remarkTextField.resignFirstResponder()
        self.contactInfoTextField.resignFirstResponder()
    }

    // MARK: - Table view   data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 5
        } else {
            return 2
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
