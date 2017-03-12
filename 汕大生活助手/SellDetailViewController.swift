//
//  SellDetailViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/12/10.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import AVOSCloud
import LeanCloud
import Kingfisher
import JGProgressHUD

class SellDetailViewController: UIViewController, UIScrollViewDelegate {

    var sell: [AVObject] = []
    var user: [AVObject] = []

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var imageView: UIView!
    var imageScrollView: UIScrollView!
    var pageControl: JEEPageControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        let sell0 = self.sell[0]
        let user0 = self.user[0]
        
        // createdTime
        let createdTime = sell0["createdAt"] as! Date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        let createdTimeStr = formatter.string(from: createdTime)
        
        self.timeLabel.text = createdTimeStr
        self.titleTextView.text = sell0["title"] as! String
        self.descriptionTextView.text = sell0["description"] as! String
        
        let price: String = (sell0["price"]! as AnyObject).debugDescription
        self.priceLabel.text = "¥\((price as String?)!)"
        
        self.nameLabel.text = user0["nickname"] as! String?
        
        // 头像
        let imgFile = user0["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        self.portraitImageView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 图片
        var imgURL: [URL] = []
        for file in sell0["images"] as! [AVFile] {
            let objectId = file.objectId!
            let query = AVQuery(className: "_File")
            let imgFile = query.getObjectWithId(objectId)
            let urlStr = (imgFile?["url"])!
            let url: URL! = URL(string: urlStr as! String)
            imgURL.append(url as URL)
        }
        
        // scrollView高度计算
        let statusHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationHeight = self.navigationController?.navigationBar.frame.size.height
        let titleHeight = self.titleTextView.bounds.size.height
        let descriptionHeight = self.descriptionTextView.bounds.size.height
        
        self.scrollView.contentSize = CGSize(width: self.imageView.bounds.width, height: 157 + titleHeight + descriptionHeight + self.imageView.bounds.height + 20 * 4 + 10 + 8 + 20)
        
        
        
        // 图片轮播
        let imageNum: Int = imgURL.count
        if self.view.bounds.width == 320 {
            self.imageScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 500))

        } else if self.view.bounds.width == 375 {
            self.imageScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 500))

        } else if self.view.bounds.width == 414 {
            self.imageScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 414, height: 500))
        }

        self.imageScrollView.isPagingEnabled = true
        self.imageScrollView.showsHorizontalScrollIndicator = false
        self.imageScrollView.contentSize = CGSize(width: Int(self.imageScrollView.bounds.size.width) * imageNum, height: Int(self.imageScrollView.bounds.size.height))
        self.imageView.addSubview(self.imageScrollView)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        
        let item = JEEPageItem(pageNum: imageNum)
        self.pageControl = JEEPageControl(item: item, scrollView: self.imageScrollView)
        let width = 20 + (10 + 12) * (imageNum - 1)
        self.pageControl.frame = CGRect(x:  self.imageView.frame.width / 2 - CGFloat(width) / 2, y: 45 / 48 * self.imageView.frame.height, width: CGFloat(width) - 5, height: 24.0)
        self.pageControl.center.x = self.view.bounds.width/2
        self.imageView.addSubview(pageControl)
        self.pageControl.currentPage = 1
        for i in 0 ..< imageNum {
            let pageFrame = CGRect(x: CGFloat(i) * self.imageScrollView.bounds.size.width, y: 0, width: self.imageScrollView.bounds.size.width, height: self.imageScrollView.bounds.size.height)
            
            
            let imageView = UIImageView(frame: pageFrame)
            imageView.kf.setImage(with: imgURL[i], placeholder: UIImage(named: "图片_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.clipsToBounds = true
            self.imageScrollView.addSubview(imageView)
        }
        
    }

    
    
    @IBAction func wantBtnClicked(_ sender: Any) {
        
        let sell0 = self.sell[0]
        let contactInfo = sell0["contactInfo"] as! String
        
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            dynamicAnimatorActive: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let icon = UIImage(named: "联系.png")
        let color = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
        _ = alert.addButton("好的") {
            
        }
        _ = alert.showCustom("联系方式", subTitle: contactInfo, color: color, icon: icon!)
        


        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
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
