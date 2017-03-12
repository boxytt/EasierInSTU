//
//  AddCarPoolTableViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/30.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud
import JGProgressHUD


class AddCarPoolTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var startPlaceTextField: UITextField!
    @IBOutlet weak var endPlaceTextField: UITextField!
    @IBOutlet weak var needNumberTextField: UITextField!
    @IBOutlet weak var contactInfoTextField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate
        self.startPlaceTextField.delegate = self
        self.endPlaceTextField.delegate = self
        self.needNumberTextField.delegate = self
        self.contactInfoTextField.delegate = self
        
        
        // 左边距
        self.needNumberTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.contactInfoTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))

        self.needNumberTextField.leftViewMode = .always
        self.contactInfoTextField.leftViewMode = .always
        
        // 清除按钮
        self.startPlaceTextField.clearButtonMode = .whileEditing
        self.endPlaceTextField.clearButtonMode = .whileEditing
        self.needNumberTextField.clearButtonMode = .whileEditing
        self.contactInfoTextField.clearButtonMode = .whileEditing
 
     
        // 键盘属性
        self.needNumberTextField.keyboardType = .numberPad
        
        // 去掉多余的线
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // 设置datePicker
        let time: Date = Date()
        self.timePicker.setDate(time as Date, animated: false)
        self.timePicker.minimumDate = time as Date

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // 回收键盘
    @IBAction func handleTap(_ sender: Any) {
        self.startPlaceTextField.resignFirstResponder()
        self.endPlaceTextField.resignFirstResponder()
        self.needNumberTextField.resignFirstResponder()
        self.contactInfoTextField.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
        
    }
    
    
    // MARK: 上传数据
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        //收回键盘
        view.endEditing(true)
        
        if let startPlace = startPlaceTextField.text, startPlace == "" {

            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入出发地点"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
        } else if let endPlace = endPlaceTextField.text, endPlace == "" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入目的地点"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
        } else if let needNumber = needNumberTextField.text, needNumber == "" {
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入尚缺人数"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
        } else if let contactInfo = contactInfoTextField.text, contactInfo == "" {
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请留下联系方式"
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
                    
                    let todo = LCObject(className: "Carpool")
                    todo.set("username", value: username)
                    todo.set("place_start", value: (self.startPlaceTextField.text)!)
                    todo.set("place_end", value: (self.endPlaceTextField.text)!)
                    todo.set("time", value: self.timePicker.date)
                    todo.set("need_num", value: (self.needNumberTextField.text)!)
                    todo.set("contactInfo", value: (self.contactInfoTextField.text)!)
                    // Pointer关联到具体的user对象
                    let user = LCObject(className: "_User", objectId: userId)
                    todo.set("toUser", value: user)
                    
                    todo.save { (result) in
                        // 网络活动指示器
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if result.isSuccess {
                            
                            
                            // 发送通知
                            let center = NotificationCenter.default
                            center.post(name: NSNotification.Name(rawValue: "passValue_Car"), object: nil)
                            center.post(name: NSNotification.Name(rawValue: "passValue_delete_other"), object: nil)
                            
                            let HUD1 = JGProgressHUD(style: .dark)
                            HUD1?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                            HUD1?.textLabel.text = "发布成功"
                            HUD1?.square = true
                            HUD?.dismiss()
                            HUD1?.show(in: self.view)
                            HUD1?.dismiss(afterDelay: 2, animated: true)
                            
                            var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(AddCarPoolTableViewController.doDismiss), userInfo: nil, repeats: false)
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
            
            _ = alert.showCustom("请仔细阅读", subTitle: "我们只为您提供发布消息的平台\n当别人想和你拼车时会主动联系您\n在个人信息-我的帖子中可修改人数\n当凑够拼车人数时，请自觉删除掉\n以免受到不必要的骚扰", color: color, icon: icon!)
            
            
        }

        
    }
    
    

    
    func doDismiss() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1{
            return 1
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
