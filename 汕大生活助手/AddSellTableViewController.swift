//
//  AddSellTableViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/29.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud
import JGProgressHUD

class AddSellTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate, ISImagePickerControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var contactInfoTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var picturesView: UIView!
    var images = [UIImage]()
    
   
    var imageView1: UIImageView!
    var imageView2: UIImageView!
    var imageView3: UIImageView!
    var addImageBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // delegete
        self.titleTextField.delegate = self
        self.descriptionTextView.delegate = self
        self.priceTextField.delegate = self
        self.contactInfoTextField.delegate = self
        self.priceTextField.delegate = self
        
        self.titleTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.priceTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        self.contactInfoTextField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 4, height: 0))
        
        self.titleTextField.leftViewMode = .always
        self.priceTextField.leftViewMode = .always
        self.contactInfoTextField.leftViewMode = .always
        
        self.titleTextField.clearButtonMode = .whileEditing
        self.contactInfoTextField.clearButtonMode = .whileEditing
        self.priceTextField.clearButtonMode = .whileEditing
        
        self.descriptionTextView.delegate = self
        
        self.placeHolderLabel.alpha = 0.2
        
        // 键盘属性
        self.priceTextField.keyboardType = .decimalPad
        
        self.titleTextField.returnKeyType = .done
        self.priceTextField.returnKeyType = .done
        self.contactInfoTextField.returnKeyType = .done
        

        // 去掉多余的横线
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        

        if self.view.bounds.width == 320 {
            self.addImageBtn = UIButton(frame: CGRect(x: 320 - 70 - 8, y: 10, width: 70, height: 70))
            self.imageView1 = UIImageView(frame: CGRect(x: 8, y: 10, width: 70, height: 70))
            self.imageView2 = UIImageView(frame: CGRect(x: 86, y: 10, width: 70, height: 70))
            self.imageView3 = UIImageView(frame: CGRect(x: 164, y: 10, width: 70, height: 70))
            
        } else if self.view.bounds.width == 375 {
            self.addImageBtn = UIButton(frame: CGRect(x: 375 - 80 - 11, y: 10, width: 80, height: 80))
            self.imageView1 = UIImageView(frame: CGRect(x: 11, y: 10, width: 80, height: 80))
            self.imageView2 = UIImageView(frame: CGRect(x: 102, y: 10, width: 80, height: 80))
            self.imageView3 = UIImageView(frame: CGRect(x: 193, y: 10, width: 80, height: 80))
            
        } else if self.view.bounds.width == 414 {
            self.addImageBtn = UIButton(frame: CGRect(x: 414 - 90 - 10.8, y: 10, width: 90, height: 90))

            self.imageView1 = UIImageView(frame: CGRect(x: 10.8, y: 10, width: 90, height: 90))
            self.imageView2 = UIImageView(frame: CGRect(x: 111.6, y: 10, width: 90, height: 90))
            self.imageView3 = UIImageView(frame: CGRect(x: 223.2, y: 10, width: 90, height: 90))
           
        }
        
        // addImageBtn
        self.addImageBtn.setImage(UIImage(named: "添加.png"), for: .normal)

        self.addImageBtn.addTarget(self, action: #selector(pickImage(_:)), for: .touchUpInside)
        self.picturesView.addSubview(self.addImageBtn)
        self.picturesView.addSubview(self.imageView1)
        self.picturesView.addSubview(self.imageView2)
        self.picturesView.addSubview(self.imageView3)

        
        
    }
    
    
    
    
    
    // 实现textView的类似placeholder属性
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            placeHolderLabel.text = "描述一下你的宝贝"
        } else {
            placeHolderLabel.text = ""
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)

    }
    
    
    
    
    // MARK: 键盘事件
    
    @IBAction func handleTap(_ sender: Any) {
        self.titleTextField.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
        self.contactInfoTextField.resignFirstResponder()
        self.priceTextField.resignFirstResponder()
    }
    
    
    
    // MARK: 图片选择
    
    func pickImage(_ button: UIButton) {
    
        let options:[ISImagePickerOption] = [
            .maxImagesCount(3),  // 可选照片张数
            ISImagePickerOption.isPickVideo(false),
            .isPickImage(true),
            .isShowTakePictureBtn(true),
            .columnCount(4),
            .columnMargin(5),
            .bundle("ISImagePicker.bundle"),
            .selImg("photo_sel_photoPickerVc.png"),
            .unSelImg("photo_def_previewVc.png"),
            .preNumImg("preview_number_icon.png"),
            .navBackItemImg("navi_back.png"),
            .navBarTintColor(UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
            ),
            .navBarItemColor(UIColor.white),
            ISImagePickerOption.previewImageMaxZoom(20),
            .expectImageWidth(400.0),
            .isAllowSelecteOrignalImage(true)
        ]
        let imagePicker = ISImagePickerController(options: options)
        imagePicker.imagePickerDelegate = self

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            self.present(imagePicker, animated: true) { Void in
                print("初始化为空")
                // 初始化为空
                self.images = []
                self.addImageBtn.setImage(UIImage(named: "添加.png"), for: .normal)

                // 清空imageView
                self.imageView1.image = nil
                self.imageView2.image = nil
                self.imageView3.image = nil
                
            }
        }

    }
    
    

    func imagePicker(_ picker:ISImagePickerController , didFinishPickImages images:[UIImage], sourceAssets assets:[ISAssetModel] ,isSelectOriginalImage:Bool ){

        self.images = images
        
        let count = images.count
        
        
        // UI
        if count > 0 {
            self.addImageBtn.setImage(UIImage(named: "更换.png"), for: .normal)
        }
        
        switch count {
        case 1:
            self.imageView1.image = images[0]
        case 2:
            self.imageView1.image = images[0]
            self.imageView2.image = images[1]
        case 3:
            self.imageView1.image = images[0]
            self.imageView2.image = images[1]
            self.imageView3.image = images[2]
        default:
            break
        }
 
        
    }
    
    func imagePickerDidCancel(_ picker:ISImagePickerController){
        
    }
    
    
    
    // MARK: 点击保存按钮
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        //收回键盘
        view.endEditing(true)
        
        if let title = titleTextField.text, title == "" {
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请输入标题"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else if let description = descriptionTextView.text, description == "" {
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
        } else if let price = priceTextField.text, price == "" {
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请填写价格"
            HUD?.position = JGProgressHUDPosition.center
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2, animated: true)
            
        } else if self.images == [] {
            let HUD = JGProgressHUD(style: .dark)
            HUD?.indicatorView = nil
            HUD?.textLabel.text = "请添加图片"
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
                    let price = Double((self.priceTextField.text)!)!
                    
                    let todo = AVObject(className: "Sell")
                    todo.setObject((self.titleTextField.text)!, forKey: "title")
                    todo.setObject(self.descriptionTextView.text, forKey: "description")
                    todo.setObject((self.contactInfoTextField.text)!, forKey: "contactInfo")
                    todo.setObject(price, forKey: "price")
                    todo.setObject(username, forKey: "username")
                    
                    // Pointer关联到具体的user对象
                    let user = AVObject(className: "_User", objectId: userId)
                    todo.setObject(user, forKey: "toUser")
                    
                    var imgArray : Array<Any> = []
                    // 上传图片
                    for image in self.images {
                        // 将UIImage的图片转换为Data
                        let salFac = image.size.width > 600 ? 600 / image.size.width : 1
                        let image_data = UIImageJPEGRepresentation(image, salFac)
                        
                        // Data型的原图和压缩图
                        let originImg = UIImage(data: image_data! as Data)!
                        let scalingFac = (originImg.size.width > 1024) ? 1024 / originImg.size.width : 1.0
                        let scaleImg = UIImage(data: image_data! as Data, scale: scalingFac)
                        
                        // AVFile文件
                        let imgFile = AVFile(name: "\(username).jpg", data: UIImageJPEGRepresentation(scaleImg!, 0.8)!)
                        
                        imgFile.saveInBackground()
                        
                        imgArray.append(imgFile)
                    }
                    
                    todo.setObject(imgArray, forKey: "images")
                    
                    todo.saveInBackground({ (succeeded, error) in
                        // 网络活动指示器
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if succeeded {
                            
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
                            
                            var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(AddSellTableViewController.doDismiss), userInfo: nil, repeats: false)
                            
                            
                        } else {
                            
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
            
            _ = alert.showCustom("请仔细阅读", subTitle: "我们只为您提供发布消息的平台\n当别人想买时才显示您的联系方式\n具体解释、讨价还价等还得麻烦您\n当不需要这个贴时，请自觉删除掉\n以免受到不必要的骚扰", color: color, icon: icon!)
            
        }

        

    }
    
 
    func doDismiss() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }

    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count: Int = 0
        
        if section == 0 {
            count = 4
        } else if section == 1 {
            count = 1
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if self.view.bounds.width == 320 {
                return 90
            } else if self.view.bounds.width == 375 {
                return 100
            } else if self.view.bounds.width == 414 {
                return 110
            } else {
                return 0
            }
        } else {
            if indexPath.row == 0 {
                return 44
            } else if indexPath.row == 1 {
                return 188
            } else if indexPath.row == 2 {
                return 44
            } else {
                return 44
            }
        }
    }
    

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }



}
