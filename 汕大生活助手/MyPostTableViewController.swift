//
//  MyPostTableViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/12/15.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import AVOSCloud
import LeanCloud
import JGProgressHUD

class MyPostTableViewController: UITableViewController, UITextFieldDelegate {
    
    var createdAt: [String] = []
    var type: [String] = []
    var content: [String] = []
    var className: [String] = []
    var objectId: [String] = []

    var isEmpty: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

        self.createdAt = []
        self.type = []
        self.content = []
        self.className = []
        self.objectId = []

        
        getNewData()
        

        // 创建一个重用的单元格
        self.tableView!.register(UINib(nibName:"MyPostTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"MyPostCell")
        

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)


        
        // 自适应高度
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        // 下拉刷新
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        self.refreshControl?.tintColor = UIColor.lightGray
        self.refreshControl?.addTarget(self, action: #selector(MyPostTableViewController.getNewData), for: .valueChanged)
        
        // 删除的
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
      
    }


      func getNewData() {
        self.isEmpty = true

        getBuyRecord(true)
        getSellRecord(true)
        getJobRecord(true)
        getAskExpressRecord(true)
        getHelpExpressRecord(true)
        getCarpoolRecord(true)
        
        
        
        var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(MyPostTableViewController.judgeEmpty), userInfo: nil, repeats: false)

    }
    
    func judgeEmpty() {
        

        if self.isEmpty == true {
            let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400))
            emptyView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
            let imageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - self.view.bounds.width/5, y: self.view.bounds.height/6, width: self.view.bounds.width/2, height: self.view.bounds.height/5))
            imageView.image = UIImage(named: "空白页.png")
            
            
            let label1 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 144 / 2, y: self.view.bounds.height / 2.3, width: 144, height: 21))
            label1.textColor = UIColor.black
            label1.font = UIFont.systemFont(ofSize: 19.0)
            label1.text = "你没有任何帖子"
            label1.textAlignment = NSTextAlignment.center
            
            let label2 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 88 / 2, y: self.view.bounds.height / 2, width: 88, height: 21))
            label2.textColor = UIColor(colorLiteralRed: 146/255, green: 158/255, blue: 170/255, alpha: 1)
            label2.font = UIFont.systemFont(ofSize: 17.0)
            label2.text = "快去添加吧"
            label2.textAlignment = NSTextAlignment.center
            
            emptyView.addSubview(imageView)
            emptyView.addSubview(label1)
            emptyView.addSubview(label2)
            
            self.tableView.tableFooterView = emptyView
            
        } else {
            self.tableView.tableFooterView = UIView(frame: CGRect.zero)
            
            
            
            
            
            
        }
        
        self.tableView.reloadData()

    

    }
    
    // MARK: 从云端获取数据
    
    func getBuyRecord(_ needNew: Bool = false) {
        
        
        let currentUser = LCUser.current
        let currentUsername = (currentUser?.username?.value)!
        // 网络活动指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let query = AVQuery(className: "Buy")
        
        query.whereKey("username", equalTo: currentUsername)
        query.order(byDescending: "createdAt") //降序排列
        
        
        if needNew {
            query.cachePolicy = .ignoreCache
        } else {
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2
        }
        
        if (query.hasCachedResult()) {
            print("从缓存中查询")
        }
        
        
        
        self.createdAt = []
        self.type = []
        self.content = []
        self.className = []
        self.objectId = []
        

        query.findObjectsInBackground { (objects, error) in
            
            if let error = error {  //保证没有错误，否则就退出
                
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400))
                emptyView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
                let imageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - self.view.bounds.width/5, y: self.view.bounds.height/6, width: self.view.bounds.width/2, height: self.view.bounds.height/5))
                imageView.image = UIImage(named: "空白页.png")
                
                
                let label1 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 144 / 2, y: self.view.bounds.height / 2.3, width: 144, height: 21))
                label1.textColor = UIColor.black
                label1.font = UIFont.systemFont(ofSize: 19.0)
                label1.text = "获取不到数据哟"
                label1.textAlignment = NSTextAlignment.center
                
                let label2 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 88 / 2, y: self.view.bounds.height / 2, width: 88, height: 21))
                label2.textColor = UIColor(colorLiteralRed: 146/255, green: 158/255, blue: 170/255, alpha: 1)
                label2.font = UIFont.systemFont(ofSize: 17.0)
                label2.text = "网络不给力"
                label2.textAlignment = NSTextAlignment.center
                
                emptyView.addSubview(imageView)
                emptyView.addSubview(label1)
                emptyView.addSubview(label2)
                
                self.tableView.tableFooterView = emptyView
                
                
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(MyPostTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
            }
            
            if let objects = objects as? [AVObject] {
                
                for object in objects {
                    
                    let createdAt = object.object(forKey: "createdAt") as! Date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd hh:mm"
                    let createdAtStr = formatter.string(from: createdAt)
                    
                    self.createdAt.append(createdAtStr)
                    self.type.append("二手买卖")
                    self.content.append(object.object(forKey: "description") as! String)
                    self.className.append("Buy")
                    self.objectId.append(object.objectId!)

                }
                
                if objects.isEmpty != true {
                    print("有")
                    self.isEmpty = false
                }
                
                OperationQueue.main.addOperation {
                    // 在主线程中更新数据，不会卡顿
                    self.tableView.reloadData()
                    // 网络活动指示器
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.refreshControl?.endRefreshing()
                }
                
            }
            
        }
        
    }
    
    func getSellRecord(_ needNew: Bool = false) {
        
        let currentUser = LCUser.current
        let currentUsername = (currentUser?.username?.value)!
        // 网络活动指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let query = AVQuery(className: "Sell")
        
        query.whereKey("username", equalTo: currentUsername)
        query.order(byDescending: "createdAt") //降序排列
        
        
        if needNew {
            query.cachePolicy = .ignoreCache
        } else {
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2
        }
        
        if (query.hasCachedResult()) {
            print("从缓存中查询")
        }
        
        query.findObjectsInBackground { (objects, error) in
            
            if let error = error {  //保证没有错误，否则就退出
                
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400))
                emptyView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
                let imageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - self.view.bounds.width/5, y: self.view.bounds.height/6, width: self.view.bounds.width/2, height: self.view.bounds.height/5))
                imageView.image = UIImage(named: "空白页.png")
                
                
                let label1 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 144 / 2, y: self.view.bounds.height / 2.3, width: 144, height: 21))
                label1.textColor = UIColor.black
                label1.font = UIFont.systemFont(ofSize: 19.0)
                label1.text = "获取不到数据哟"
                label1.textAlignment = NSTextAlignment.center
                
                let label2 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 88 / 2, y: self.view.bounds.height / 2, width: 88, height: 21))
                label2.textColor = UIColor(colorLiteralRed: 146/255, green: 158/255, blue: 170/255, alpha: 1)
                label2.font = UIFont.systemFont(ofSize: 17.0)
                label2.text = "网络不给力"
                label2.textAlignment = NSTextAlignment.center
                
                emptyView.addSubview(imageView)
                emptyView.addSubview(label1)
                emptyView.addSubview(label2)

                
                self.tableView.tableFooterView = emptyView
                
                
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(MyPostTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
            }
            
            if let objects = objects as? [AVObject] {
                
                for object in objects {
                    
                    let createdAt = object.object(forKey: "createdAt") as! Date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd hh:mm"
                    let createdAtStr = formatter.string(from: createdAt)
                    
                    self.createdAt.append(createdAtStr)
                    self.type.append("二手买卖")
                    self.content.append(object.object(forKey: "title") as! String)
                    self.className.append("Sell")
                    self.objectId.append(object.objectId!)
                    
                }
                
                if objects.isEmpty != true {
                    self.isEmpty = false
                }
                
                OperationQueue.main.addOperation {
                    // 在主线程中更新数据，不会卡顿
                    self.tableView.reloadData()
                    // 网络活动指示器
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.refreshControl?.endRefreshing()
                }
                
            }
            
        }
        
    }
    
    func getJobRecord(_ needNew: Bool = false) {
        
        let currentUser = LCUser.current
        let currentUsername = (currentUser?.username?.value)!
        // 网络活动指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let query = AVQuery(className: "Job")
        
        query.whereKey("username", equalTo: currentUsername)
        query.order(byDescending: "createdAt") //降序排列
        
        
        if needNew {
            query.cachePolicy = .ignoreCache
        } else {
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2
        }
        
        if (query.hasCachedResult()) {
            print("从缓存中查询")
        }
        
        query.findObjectsInBackground { (objects, error) in
            
            if let error = error {  //保证没有错误，否则就退出
                
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400))
                emptyView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
                let imageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - self.view.bounds.width/5, y: self.view.bounds.height/6, width: self.view.bounds.width/2, height: self.view.bounds.height/5))
                imageView.image = UIImage(named: "空白页.png")
                
                
                let label1 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 144 / 2, y: self.view.bounds.height / 2.3, width: 144, height: 21))
                label1.textColor = UIColor.black
                label1.font = UIFont.systemFont(ofSize: 19.0)
                label1.text = "获取不到数据哟"
                label1.textAlignment = NSTextAlignment.center
                
                let label2 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 88 / 2, y: self.view.bounds.height / 2, width: 88, height: 21))
                label2.textColor = UIColor(colorLiteralRed: 146/255, green: 158/255, blue: 170/255, alpha: 1)
                label2.font = UIFont.systemFont(ofSize: 17.0)
                label2.text = "网络不给力"
                label2.textAlignment = NSTextAlignment.center
                
                emptyView.addSubview(imageView)
                emptyView.addSubview(label1)
                emptyView.addSubview(label2)
                
                self.tableView.tableFooterView = emptyView
                
                
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(MyPostTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
            }
            
            if let objects = objects as? [AVObject] {
                
                for object in objects {
                    
                    let createdAt = object.object(forKey: "createdAt") as! Date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd hh:mm"
                    let createdAtStr = formatter.string(from: createdAt)
                    
                    self.createdAt.append(createdAtStr)
                    self.type.append("兼职交流")
                    self.content.append(object.object(forKey: "description") as! String)
                    self.className.append("Job")
                    self.objectId.append(object.objectId!)
                    
                }
                
                if objects.isEmpty != true {
                    self.isEmpty = false
                }
                
                OperationQueue.main.addOperation {
                    // 在主线程中更新数据，不会卡顿
                    self.tableView.reloadData()
                    // 网络活动指示器
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.refreshControl?.endRefreshing()
                }
                
            }
            
        }
        
    }
    
    func getAskExpressRecord(_ needNew: Bool = false) {
        
        let currentUser = LCUser.current
        let currentUsername = (currentUser?.username?.value)!
        // 网络活动指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let query = AVQuery(className: "AskExpress")
        
        query.whereKey("username", equalTo: currentUsername)
        query.order(byDescending: "createdAt") //降序排列
        
        
        if needNew {
            query.cachePolicy = .ignoreCache
        } else {
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2
        }
        
        if (query.hasCachedResult()) {
            print("从缓存中查询")
        }
        
        query.findObjectsInBackground { (objects, error) in
            
            if let error = error {  //保证没有错误，否则就退出
                
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400))
                emptyView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
                let imageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - self.view.bounds.width/5, y: self.view.bounds.height/6, width: self.view.bounds.width/2, height: self.view.bounds.height/5))
                imageView.image = UIImage(named: "空白页.png")
                
                
                let label1 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 144 / 2, y: self.view.bounds.height / 2.3, width: 144, height: 21))
                label1.textColor = UIColor.black
                label1.font = UIFont.systemFont(ofSize: 19.0)
                label1.text = "获取不到数据哟"
                label1.textAlignment = NSTextAlignment.center
                
                let label2 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 88 / 2, y: self.view.bounds.height / 2, width: 88, height: 21))
                label2.textColor = UIColor(colorLiteralRed: 146/255, green: 158/255, blue: 170/255, alpha: 1)
                label2.font = UIFont.systemFont(ofSize: 17.0)
                label2.text = "网络不给力"
                label2.textAlignment = NSTextAlignment.center
                
                emptyView.addSubview(imageView)
                emptyView.addSubview(label1)
                emptyView.addSubview(label2)
                
                self.tableView.tableFooterView = emptyView
                
                
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(MyPostTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
            }
            
            if let objects = objects as? [AVObject] {
                
                for object in objects {
                    
                    let createdAt = object.object(forKey: "createdAt") as! Date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd hh:mm"
                    let createdAtStr = formatter.string(from: createdAt)
                    
                    self.createdAt.append(createdAtStr)
                    self.type.append("快递帮拿")
                    self.content.append(object.object(forKey: "description") as! String)
                    self.className.append("AskExpress")
                    self.objectId.append(object.objectId!)
                    
                }
                
                if objects.isEmpty != true {
                    self.isEmpty = false
                }
                
                OperationQueue.main.addOperation {
                    // 在主线程中更新数据，不会卡顿
                    self.tableView.reloadData()
                    // 网络活动指示器
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.refreshControl?.endRefreshing()
                }
                
            }
            
        }
        
    }
    
    func getHelpExpressRecord(_ needNew: Bool = false) {
        
        let currentUser = LCUser.current
        let currentUsername = (currentUser?.username?.value)!
        // 网络活动指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let query = AVQuery(className: "HelpExpress")
        
        query.whereKey("username", equalTo: currentUsername)
        query.order(byDescending: "createdAt") //降序排列
        
        
        if needNew {
            query.cachePolicy = .ignoreCache
        } else {
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2
        }
        
        if (query.hasCachedResult()) {
            print("从缓存中查询")
        }
        
        query.findObjectsInBackground { (objects, error) in
            
            if let error = error {  //保证没有错误，否则就退出
                
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400))
                emptyView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
                let imageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - self.view.bounds.width/5, y: self.view.bounds.height/6, width: self.view.bounds.width/2, height: self.view.bounds.height/5))
                imageView.image = UIImage(named: "空白页.png")
                
                
                let label1 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 144 / 2, y: self.view.bounds.height / 2.3, width: 144, height: 21))
                label1.textColor = UIColor.black
                label1.font = UIFont.systemFont(ofSize: 19.0)
                label1.text = "获取不到数据哟"
                label1.textAlignment = NSTextAlignment.center
                
                let label2 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 88 / 2, y: self.view.bounds.height / 2, width: 88, height: 21))
                label2.textColor = UIColor(colorLiteralRed: 146/255, green: 158/255, blue: 170/255, alpha: 1)
                label2.font = UIFont.systemFont(ofSize: 17.0)
                label2.text = "网络不给力"
                label2.textAlignment = NSTextAlignment.center
                
                emptyView.addSubview(imageView)
                emptyView.addSubview(label1)
                emptyView.addSubview(label2)
                
                self.tableView.tableFooterView = emptyView
                
                
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(MyPostTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
            }
            
            if let objects = objects as? [AVObject] {
                
                for object in objects {
                    
                    let createdAt = object.object(forKey: "createdAt") as! Date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd hh:mm"
                    let createdAtStr = formatter.string(from: createdAt)
                    
                    self.createdAt.append(createdAtStr)
                    self.type.append("快递帮拿")
                    self.content.append(object.object(forKey: "description") as! String)
                    self.className.append("HelpExpress")
                    self.objectId.append(object.objectId!)
                    
                }
                
                if objects.isEmpty != true {
                    self.isEmpty = false
                }
                
                OperationQueue.main.addOperation {
                    // 在主线程中更新数据，不会卡顿
                    self.tableView.reloadData()
                    // 网络活动指示器
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.refreshControl?.endRefreshing()
                }
                
            }
            
        }
        
    }

    
    func getCarpoolRecord(_ needNew: Bool = false) {
        
        let currentUser = LCUser.current
        let currentUsername = (currentUser?.username?.value)!
        // 网络活动指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let query = AVQuery(className: "Carpool")
        
        query.whereKey("username", equalTo: currentUsername)
        query.order(byDescending: "createdAt") //降序排列
        
        
        if needNew {
            query.cachePolicy = .ignoreCache
        } else {
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2
        }
        
        if (query.hasCachedResult()) {
            print("从缓存中查询")
        }
        
        query.findObjectsInBackground { (objects, error) in
            
            if let error = error {  //保证没有错误，否则就退出
                
                // 网络活动指示器
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400))
                emptyView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
                let imageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - self.view.bounds.width/5, y: self.view.bounds.height/6, width: self.view.bounds.width/2, height: self.view.bounds.height/5))
                imageView.image = UIImage(named: "空白页.png")
                
                
                let label1 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 144 / 2, y: self.view.bounds.height / 2.3, width: 144, height: 21))
                label1.textColor = UIColor.black
                label1.font = UIFont.systemFont(ofSize: 19.0)
                label1.text = "获取不到数据哟"
                label1.textAlignment = NSTextAlignment.center
                
                let label2 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 88 / 2, y: self.view.bounds.height / 2, width: 88, height: 21))
                label2.textColor = UIColor(colorLiteralRed: 146/255, green: 158/255, blue: 170/255, alpha: 1)
                label2.font = UIFont.systemFont(ofSize: 17.0)
                label2.text = "网络不给力"
                label2.textAlignment = NSTextAlignment.center
                
                emptyView.addSubview(imageView)
                emptyView.addSubview(label1)
                emptyView.addSubview(label2)
                
                self.tableView.tableFooterView = emptyView
                
                
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(MyPostTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
            }
            
            if let objects = objects as? [AVObject] {
                
                for object in objects {
                    
                    let createdAt = object.object(forKey: "createdAt") as! Date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd hh:mm"
                    let createdAtStr = formatter.string(from: createdAt)
                    
                    self.createdAt.append(createdAtStr)
                    self.type.append("我要拼车")
                    
                    let start = object.object(forKey: "place_start") as! String
                    let end = object.object(forKey: "place_end") as! String
                    
                    let need_num = object.object(forKey: "need_num") as! String

                    
                    let content = "\(start) 到 \(end)\n\n尚缺\(need_num)人"
                    
                    self.content.append(content)
                    self.className.append("Carpool")
                    self.objectId.append(object.objectId!)
                    
                }
                
                if objects.isEmpty != true {
                    self.isEmpty = false
                }
                
                

                
                OperationQueue.main.addOperation {
                    // 在主线程中更新数据，不会卡顿
                    self.tableView.reloadData()
                    // 网络活动指示器
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.refreshControl?.endRefreshing()
                }
                
            }
            
        }
        
    }

    
    func doEndRefreshing() {
        self.refreshControl?.endRefreshing()

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.createdAt.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    
    // section间隔
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 8))
        view.backgroundColor = UIColor.clear
        return view
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPostCell", for: indexPath) as! MyPostTableViewCell
        
        cell.typeLabel.text = self.type[indexPath.section]
        cell.contentTextView.text = self.content[indexPath.section]
        cell.createAtLabel.text = self.createdAt[indexPath.section]
        
        
        return cell

    }

    // MARK: UITableViewCellActions
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRow(at: indexPath) as! MyPostTableViewCell


        let edit = UITableViewRowAction(style: .normal, title: "修改") { action, index in
            
            
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alert = SCLAlertView(appearance: appearance)
            

            let txt = alert.addTextField("尚缺人数")
            txt.delegate = self
            txt.keyboardType = .numberPad
            
            
            _ = alert.addButton("确认") {
                print("Text value: \(txt.text)")
                let objectId = self.objectId[indexPath.section]
                
                let todo = LCObject(className: "Carpool", objectId: objectId)
                
                
                if (txt.text!) != "" {
                    
                    todo.set("need_num", value: txt.text!)
                    
                    todo.save { result in
                        switch result {
                        case .success:
                            
                            // 发送通知
                            let center = NotificationCenter.default
                            center.post(name: NSNotification.Name(rawValue: "passValue_delete_myPost"), object: nil)
                            
                            var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(MyPostTableViewController.reload), userInfo: nil, repeats: false)
                            
                            let HUD = JGProgressHUD(style: .dark)
                            HUD?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                            HUD?.textLabel.text = "成功"
                            HUD?.square = true
                            HUD?.show(in: self.view)
                            HUD?.dismiss(afterDelay: 2, animated: true)
                            
                            self.tableView.isEditing = false
                            
                        case .failure(let error):
                            print(error)
                            let HUD = JGProgressHUD(style: .dark)
                            HUD?.textLabel.text = "网络连接出错>_<"
                            HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                            HUD?.show(in: self.view)
                            HUD?.dismiss(afterDelay: 2.0, animated: true)
                            self.tableView.isEditing = false
                            
                            
                            
                        }
                    }

                } else {
                    
                    let HUD = JGProgressHUD(style: .dark)
                    HUD?.textLabel.text = "人数不能为空"
                    HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    HUD?.show(in: self.view)
                    HUD?.dismiss(afterDelay: 2.0, animated: true)
                }
                
                
            }
            _ = alert.showEdit("修改", subTitle:"请输入变动后的拼车人数")

            
        }
        edit.backgroundColor = UIColor.lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "删除") { action, index in
            
            
            let todo = LCObject(className: self.className[indexPath.section], objectId: self.objectId[indexPath.section])
            
            todo.delete { result in
                switch result {
                case .success:
                    print("#1")
                    self.type.remove(at: indexPath.section)
                    self.content.remove(at: indexPath.section)
                    self.createdAt.remove(at: indexPath.section)
                    self.className.remove(at: indexPath.section)
                    self.objectId.remove(at: indexPath.section)
                    print("#2")

                    tableView.deleteSections([indexPath.section], with: .automatic)
                    
//                    tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                    print("#3")

                    // 发送通知
                    let center = NotificationCenter.default
                    center.post(name: NSNotification.Name(rawValue: "passValue_delete_myPost"), object: nil)
                    
//                    var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(MyPostTableViewController.reload), userInfo: nil, repeats: false)
                    
                    let HUD = JGProgressHUD(style: .dark)
                    HUD?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                    HUD?.textLabel.text = "成功"
                    HUD?.square = true
                    HUD?.show(in: self.view)
                    HUD?.dismiss(afterDelay: 2, animated: true)
                    
                case .failure(let error):
                    print(error)
                    // 删除失败
                    let HUD = JGProgressHUD(style: .dark)
                    HUD?.textLabel.text = "网络连接出错>_<"
                    HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    HUD?.show(in: self.view)
                    HUD?.dismiss(afterDelay: 2.0, animated: true)
                    
                }
            }
            
        }
        delete.backgroundColor = UIColor.red
        
        if (cell.typeLabel.text)! == "我要拼车" {
            return [delete, edit]
        } else {
            return [delete]
        }

    }
    

    func reload() {
        self.getNewData()
    }
    // 单击状态栏滚到顶部
    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        return true
    }
    
    
    
}
