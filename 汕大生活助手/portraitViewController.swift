//
//  portraitViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/23.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud
import JGProgressHUD


class portraitViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = image
        
        
        
        /*
         UIBarButtonItem *item = [initWithImage: style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
         item.tintColor = ;
         self.navigationItem.leftBarButtonItem = item;
         
         self.navigationItem.title = @"xxx";
         self.navigationController.navigationBar.barTintColor = ;
 */
        
        
        
    }
    
    func doDismiss() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func moreBtnClicked(_ sender: Any) {
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertVC.preferredStyle
        
        let chooseFromAlbumAction = UIAlertAction(title: "从手机相册选择", style: .default) { (UIAlertAction) -> Void in
            self.getPhotoFromAlbum()
            
        }
        let savePhotoAction = UIAlertAction(title: "保存图片", style: .default) { (UIAlertAction) -> Void in
            UIImageWriteToSavedPhotosAlbum(self.image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cannelAction = UIAlertAction(title: "取消", style: .cancel) { (UIAlertAction) -> Void in
            print("取消")
        }
        

        alertVC.addAction(chooseFromAlbumAction)
        alertVC.addAction(savePhotoAction)
        alertVC.addAction(cannelAction)
        
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    
    // savePhotoAction
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if error == nil {
            let ac = UIAlertController(title: nil, message: "保存成功", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "保存失败", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    // chooseFromAlbumAction
    func getPhotoFromAlbum() {
        
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("######")
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.allowsEditing = true
            
            self.present(picker, animated: true, completion: nil)
        } else {
            print("读取相册错误")
        }
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        
        let image: UIImage!
        
        // 判断，图片是否允许修改
        if (picker.allowsEditing){
            //裁剪后图片
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        } else {
            //原始图片
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        self.imageView.image = image
        
        
        // 旋转活动指示器
        let HUD = JGProgressHUD(style: .dark)
        HUD?.show(in: self.view)
        // 网络活动指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // MARK: 图片上传云端
        let currentUser = AVUser.current
        let username = (currentUser()?.username)!

        // 将UIImage的图片转换为Data
        let salFac = image.size.width > 600 ? 600 / image.size.width : 1
        let image_data = UIImageJPEGRepresentation(image, salFac)
        
        // Data型的原图和压缩图
        let originImg = UIImage(data: image_data! as Data)!
        let scalingFac = (originImg.size.width > 1024) ? 1024 / originImg.size.width : 1.0
        let scaleImg = UIImage(data: image_data! as Data, scale: scalingFac)
        
        // AVFile文件
        let imgFile = AVFile(name: "\(username).jpg", data: UIImageJPEGRepresentation(scaleImg!, 0.8)!)
        
        // 保存到LeanCloud
        imgFile.saveInBackground { (succeeded, error) in
            if succeeded {
                
                
                currentUser()?.setObject(imgFile, forKey: "image")
                currentUser()?.saveInBackground({ (succeed, error) in
                    if succeeded {
                        
                        // 发送通知
                        let center = NotificationCenter.default
                        center.post(name: NSNotification.Name(rawValue: "passValue_portrait"), object: nil)
                        
                        let HUD1 = JGProgressHUD(style: .dark)
                        HUD1?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                        HUD1?.textLabel.text = "成功"
                        HUD1?.square = true
                        HUD?.dismiss()
                        HUD1?.show(in: self.view)
                        HUD1?.dismiss(afterDelay: 2, animated: true)
                        // 网络活动指示器
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false

                    } else {
                        
                        let HUD1 = JGProgressHUD(style: .dark)
                        HUD1?.textLabel.text = "网络连接出错>_<"
                        HUD1?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                        HUD?.dismiss()
                        HUD1?.show(in: self.view)
                        HUD1?.dismiss(afterDelay: 2.0, animated: true)
                    }
                    
                })
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}
