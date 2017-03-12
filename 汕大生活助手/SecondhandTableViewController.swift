//
//  SecondhandTableViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/20.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud
import Kingfisher
import JGProgressHUD

class SecondhandTableViewController: UITableViewController {

    @IBOutlet weak var segmented: UISegmentedControl!
    
    
    var buys: [AVObject] = []
    var sells: [AVObject] = []
    var users_buy: [AVObject] = []
    var users_sell: [AVObject] = []
    
    var hasCell: Bool = false
    let reachability = Reachability()!
    let redPoint = UIImageView(image: UIImage(named: "小红点_full"))

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let waitView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 600))
        waitView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        self.tableView.backgroundView = waitView
        self.tableView.tableFooterView = waitView

        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        self.tableView.separatorColor = UIColor.clear
        
        getRecordFromCloud_sell()
        getRecordFromCloud_buy()
        

        
        // 下拉刷新
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        self.refreshControl?.tintColor = UIColor.lightGray
        self.refreshControl?.addTarget(self, action: #selector(ExpressTableViewController.getNewData), for: .valueChanged)
        
        
        // cell自适应高度
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200

        
        // 创建一个重用的单元格
        self.tableView!.register(UINib(nibName:"MyBuyTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"MyBuyCell")
        self.tableView!.register(UINib(nibName:"OtherBuyTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"OtherBuyCell")
        
        self.tableView!.register(UINib(nibName:"MySellOneTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"MySellOneCell")
        self.tableView!.register(UINib(nibName:"MySellMultiTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"MySellMultiCell")
        self.tableView!.register(UINib(nibName:"OtherSellOneTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"OtherSellOneCell")
        self.tableView!.register(UINib(nibName:"OtherSellMultiTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"OtherSellMultiCell")
        
        
        // 通知
        let center = NotificationCenter.default
//        center.addObserver(self, selector: #selector(getNewNicknameOrPortrait(_:)), name: NSNotification.Name(rawValue: "passValue_nickname"), object: nil)
//
//        center.addObserver(self, selector: #selector(getNewNicknameOrPortrait(_:)), name: NSNotification.Name(rawValue: "passValue_portrait"), object: nil)

        center.addObserver(self, selector: #selector(getNewNicknameOrPortrait(_:)), name: NSNotification.Name(rawValue: "passValue_delete_myPost"), object: nil)
        center.addObserver(self, selector: #selector(getMessage(_:)), name: NSNotification.Name(rawValue: "getMessage"), object: nil)

        


        
        
        // MARK: 导航栏右边两个按钮
        //消息按钮
        let button1 = UIButton(type: .system)
        button1.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
        button1.setImage(UIImage(named: "消息"), for: .normal)
        button1.addTarget(self, action: #selector(chatListBtnClicked(_:)),for:.touchUpInside)
        let barButton1 = UIBarButtonItem(customView: button1)
        
        //添加按钮
        let button2 = UIButton(type: .system)
        button2.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
        button2.setImage(UIImage(named: "add"), for: .normal)
        

        button2.addTarget(self,action: #selector(addACell(_:)),for:.touchUpInside)
        let barButton2 = UIBarButtonItem(customView: button2)
        
        //按钮间的空隙
        let gap = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
                                  action: nil)
        gap.width = 15;
        
        //用于消除右边边空隙，要不然按钮顶不到最边上
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
                                     action: nil)
        spacer.width = -10;
        
        //设置按钮（注意顺序）
        self.navigationItem.rightBarButtonItems = [spacer,barButton2,gap,barButton1]
        
        // 消息红点
        self.redPoint.isHidden = true
        self.redPoint.frame = CGRect(x: 14, y: 0, width: 8, height: 8)
        button1.addSubview(redPoint)
        

        

        
        
    }
    
    // MARK: 分段控件
    @IBAction func segmentDidChange(_ sender: Any) {

        //获得选项的索引
        
        if self.hasCell == false {
            
            if reachability.isReachable { // 判断网络连接状态
                print("网络连接：可用")
                self.tableView.tableFooterView = UIView(frame: CGRect.zero)
                getNewData()
//                self.tableView.reloadData()

            } else {
                print("网络连接：不可用")
                if self.segmented.selectedSegmentIndex == 1 {
                    DispatchQueue.main.async { // 不加这句导致界面还没初始化完成就打开警告框，这样不行
                        let HUD = JGProgressHUD(style: .dark)
                        print("#5")
                        HUD?.textLabel.text = "网络连接出错>_<"
                        HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                        HUD?.show(in: self.view)
                        HUD?.dismiss(afterDelay: 2.0, animated: true)
                        
                        self.segmented.selectedSegmentIndex = 0
                    }
                }
            }
            
        } else {
            self.tableView.tableFooterView = UIView(frame: CGRect.zero)
            getNewData()
            //            self.tableView.reloadData()
            
        }
        
        
        

    }
    
    
    
    
    
    // MARK：监听网络以配合segmentDidChange()调整segmented
    func NetworkStatusListener() {
        // 1、设置网络状态消息监听 2、获得网络Reachability对象
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            // 3、开启网络状态消息监听
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    // 主动检测网络状态
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability // 准备获取网络连接信息
        
        if reachability.isReachable { // 判断网络连接状态
            print("网络连接：可用")
            self.segmented.setEnabled(true, forSegmentAt: 1)
           
        } else {
            print("网络连接：不可用")
            if hasCell == false {
                self.segmented.setEnabled(false, forSegmentAt: 1)
            }
        }
    }
    
    
    
    func getValue(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "passValue_secondhand"), object: nil)
        
        getNewData()
        self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        
        
    }
    
    
    func getNewNicknameOrPortrait(_ notification: Notification) {
        getRecordFromCloud_buy(true)
        getRecordFromCloud_sell(true)
    }


    
    func getNewData() {
        
        if self.segmented.selectedSegmentIndex == 0 {
            getRecordFromCloud_buy(true)
        } else {
            getRecordFromCloud_sell(true)
        }
        
    }

    
    // MARK: 从云端获取数据
    
    func getRecordFromCloud_buy(_ needNew: Bool = false) {

        // 网络活动指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        
        let query = AVQuery(className: "Buy")
        
        query.order(byDescending: "createdAt") //降序排列
        
        // 关联属性
        query.includeKey("toUser")
        
        
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
                
                print("#1")
                print(error)
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(SecondhandTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
            }
            
            if let objects = objects as? [AVObject] {

                self.buys = objects
                print(self.buys)
                self.users_buy = []
                for object in objects {
                    let user = object.object(forKey: "toUser")
                    self.users_buy.append(user as! AVObject)
                    
                }
                
                if self.buys == [] {
                    // 空白页
                    
                    
                    let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400))
                    emptyView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
                    let imageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - self.view.bounds.width/5, y: self.view.bounds.height/6, width: self.view.bounds.width/2, height: self.view.bounds.height/5))
                    imageView.image = UIImage(named: "空白页.png")
                    
                    
                    let label1 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 144 / 2, y: self.view.bounds.height / 2.3, width: 144, height: 21))
                    label1.textColor = UIColor.black
                    label1.font = UIFont.systemFont(ofSize: 19.0)
                    label1.text = "暂时还没有数据"
                    label1.textAlignment = NSTextAlignment.center
                    
                    let label2 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 88 / 2, y: self.view.bounds.height / 2, width: 88, height: 21))
                    label2.textColor = UIColor(colorLiteralRed: 146/255, green: 158/255, blue: 170/255, alpha: 1)
                    label2.font = UIFont.systemFont(ofSize: 17.0)
                    label2.text = "快来添加吧"
                    label2.textAlignment = NSTextAlignment.center
                    
                    emptyView.addSubview(imageView)
                    emptyView.addSubview(label1)
                    emptyView.addSubview(label2)
                    
                    if self.segmented.selectedSegmentIndex == 0 {
                        self.tableView.tableFooterView = emptyView

                    }
                } else {
                    self.tableView.tableFooterView = UIView(frame: CGRect.zero)
                    
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
    
    func getRecordFromCloud_sell(_ needNew: Bool = false) {
        
        // 网络活动指示器
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        
        let query = AVQuery(className: "Sell")
        
        query.order(byDescending: "createdAt") //降序排列
        
        // 关联属性
        query.includeKey("toUser")
        
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
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(SecondhandTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
                
            }
            
            if let objects = objects as? [AVObject] {
                
                self.sells = objects
                print(self.sells)
                self.users_sell = []
                for object in objects {
                    let user = object.object(forKey: "toUser")
                    self.users_sell.append(user as! AVObject)
                    
                }
                

                if self.sells == [] {
                    
                    let emptyView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 400))
                    emptyView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
                    let imageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - self.view.bounds.width/5, y: self.view.bounds.height/6, width: self.view.bounds.width/2, height: self.view.bounds.height/5))
                    imageView.image = UIImage(named: "空白页.png")
                    
                    
                    let label1 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 144 / 2, y: self.view.bounds.height / 2.3, width: 144, height: 21))
                    label1.textColor = UIColor.black
                    label1.font = UIFont.systemFont(ofSize: 19.0)
                    label1.text = "暂时还没有数据"
                    label1.textAlignment = NSTextAlignment.center
                    
                    let label2 = UILabel(frame: CGRect(x: self.view.bounds.width / 2 - 88 / 2, y: self.view.bounds.height / 2, width: 88, height: 21))
                    label2.textColor = UIColor(colorLiteralRed: 146/255, green: 158/255, blue: 170/255, alpha: 1)
                    label2.font = UIFont.systemFont(ofSize: 17.0)
                    label2.text = "快来添加吧"
                    label2.textAlignment = NSTextAlignment.center
                    
                    emptyView.addSubview(imageView)
                    emptyView.addSubview(label1)
                    emptyView.addSubview(label2)
                    
                    
                    if self.segmented.selectedSegmentIndex == 1 {
                        self.tableView.tableFooterView = emptyView
                    }
                    
                } else {
                    
                   self.tableView.tableFooterView = UIView(frame: CGRect.zero)
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
        
        return 1
    }
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.segmented.selectedSegmentIndex == 0 {
            return buys.count
        } else {
            return sells.count
        }

    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmented.selectedSegmentIndex == 0 {
            
        } else {
            
            let sell = sells[indexPath.row]
            
            let clicks = (sell["clicks"]! as! Int) + 1
            
            let objectId = sell["objectId"] as! String
            
            let todo = AVObject(className: "Sell", objectId: objectId)
            todo.setObject(clicks, forKey: "clicks")
            print("#33")
            todo.saveInBackground { (succeed, error) in
                if succeed {
                    print("333")
                    self.getNewData()
                    self.tableView.reloadData()
                    
                } else {
                    
                    print("#3")
                    print(error)
                    let HUD = JGProgressHUD(style: .dark)
                    HUD?.textLabel.text = "网络连接出错>_<"
                    HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    HUD?.show(in: self.view)
                    HUD?.dismiss(afterDelay: 2.0, animated: true)
                }
            }
            
            let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "SellDetailVC") as! SellDetailViewController
            detailVC.sell = [self.sells[indexPath.row]]
            detailVC.user = [self.users_sell[indexPath.row]]
            
            self.navigationController?.pushViewController(detailVC, animated: true)
            
  
        }

        
    }
    


    // MARK: cell
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let currentUser: AVUser? = AVUser.current()
        let currentUsername = currentUser?.username ?? "visitor"

        if self.segmented.selectedSegmentIndex == 0 {
            let buy = buys[(indexPath as NSIndexPath).row]
            let username_buy = buy["username"] as! String
            
            if username_buy == currentUsername {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyBuyCell", for: indexPath) as! MyBuyTableViewCell
                configureMyBuyCell(cell, cellForRowAt: indexPath)

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherBuyCell", for: indexPath) as! OtherBuyTableViewCell
                configureOtherBuyCell(cell, cellForRowAt: indexPath)

                return cell
                
            }

        } else {
            
            let sell = sells[(indexPath as NSIndexPath).row]
            let username_sell = sell["username"] as! String
            
            var imgCount: Int = 0
            
            for file in (sell["images"])! as! [AVFile] {
                // 得到图片张数
                imgCount = imgCount + 1
                
            }
            
            self.hasCell = true
            if username_sell == currentUsername {
                
                if imgCount == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MySellOneCell", for: indexPath) as! MySellOneTableViewCell
                    configureMySellOneCell(cell, cellForRowAt: indexPath)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MySellMultiCell", for: indexPath) as! MySellMultiTableViewCell
                    configureMySellMultiCell(cell, cellForRowAt: indexPath)
                    return cell
                }
            } else {
                
                if imgCount == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OtherSellOneCell", for: indexPath) as! OtherSellOneTableViewCell
                    configureOtherSellOneCell(cell, cellForRowAt: indexPath)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OtherSellMultiCell", for: indexPath) as! OtherSellMultiTableViewCell
                    configureOtherSellMultiCell(cell, cellForRowAt: indexPath)
                    return cell
                }
                
            }

            
        }
        
    }

    
    
    // buy(no image)
    
    func configureMyBuyCell(_ cell: MyBuyTableViewCell, cellForRowAt indexPath: IndexPath) {
        
        
        let buy = buys[(indexPath as NSIndexPath).row]
        let user = users_buy[(indexPath as NSIndexPath).row]
        
        // createdTime
        let createdTime = buy["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)

        
        cell.descriptionTextView.text = buy["description"] as! String
        
        cell.nameLabel.text = user["nickname"] as! String?
        
        let imgFile = user["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 删除按钮
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteBtnClicked_buy(_:)), for: .touchUpInside)
        
        // 联系TA按钮
        cell.contactButton.tag = indexPath.row
        cell.contactButton.addTarget(self, action: #selector(contactBtnClicked_buy(_:)), for: .touchUpInside)
        
        // 点击头像
        cell.portraitButton.tag = indexPath.row
        cell.portraitButton.addTarget(self, action: #selector(portraitBtnClicked(_:)), for: .touchUpInside)

    }
    
    
    
    func configureOtherBuyCell(_ cell: OtherBuyTableViewCell, cellForRowAt indexPath: IndexPath) {

        
        let buy = buys[(indexPath as NSIndexPath).row]
        let user = users_buy[(indexPath as NSIndexPath).row]
        
        // createdTime
        let createdTime = buy["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)

        
        cell.descriptionTextView.text = buy["description"] as! String
        
        cell.nameLabel.text = user["nickname"] as! String?
        
        let imgFile = user["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 我想要按钮
        cell.contactButton.tag = indexPath.row
        cell.contactButton.addTarget(self, action: #selector(contactBtnClicked_buy(_:)), for: .touchUpInside)
        
        // 点击头像
        cell.portraitButton.tag = indexPath.row
        cell.portraitButton.addTarget(self, action: #selector(portraitBtnClicked(_:)), for: .touchUpInside)


    }
    
    
    
    // MARK: sell(images)
    
    func configureMySellOneCell(_ cell: MySellOneTableViewCell, cellForRowAt indexPath: IndexPath) {

        
        let sell = self.sells[(indexPath as NSIndexPath).row]
        let user = self.users_sell[(indexPath as NSIndexPath).row]

        
        // createdTime
        let createdTime = sell["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)

        
        cell.titleTextView.text = sell["title"] as! String
        
        cell.nameLabel.text = user["nickname"] as! String?
        
        let clicks: String = (sell["clicks"]! as AnyObject).debugDescription
        cell.clicksLabel.text = "点击\((clicks as String?)!)"
        
        // 头像
        let imgFile = user["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        

        // 图片

        var imgURL: [URL] = []
        
        for file in sell["images"] as! [AVFile] {
            let objectId = file.objectId!
            let query = AVQuery(className: "_File")
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2
            
            let imgFile = query.getObjectWithId(objectId)
            let urlStr = (imgFile?["url"])!
            let url: URL! = URL(string: urlStr as! String)
            imgURL.append(url as URL)
            
        }
        
        cell.imageView1.kf.setImage(with: imgURL[0], placeholder: UIImage(named: "图片占位_长.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        
        // 删除按钮
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(SecondhandTableViewController.deleteBtnClicked_sell(_:)), for: .touchUpInside)
        
        // 点击头像
        cell.portraitButton.tag = indexPath.row
        cell.portraitButton.addTarget(self, action: #selector(SecondhandTableViewController.portraitBtnClicked(_:)), for: .touchUpInside)
        
        
    }
    
    func configureOtherSellOneCell(_ cell: OtherSellOneTableViewCell, cellForRowAt indexPath: IndexPath) {
        
        let sell = sells[(indexPath as NSIndexPath).row]
        let user = users_sell[(indexPath as NSIndexPath).row]

        
        // createdTime
        let createdTime = sell["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)

        
        cell.titleTextView.text = sell["title"] as! String
        
        cell.nameLabel.text = user["nickname"] as! String?
        
        let clicks: String = (sell["clicks"]! as AnyObject).debugDescription
        cell.clicksLabel.text = "点击\((clicks as String?)!)"
        
        // 头像
        let imgFile = user["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        
        // 图片

        var imgURL: [URL] = []
        
        for file in sell["images"] as! [AVFile] {
            let objectId = file.objectId!
            let query = AVQuery(className: "_File")
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2
            
            let imgFile = query.getObjectWithId(objectId)
            let urlStr = (imgFile?["url"])!
            let url: URL! = URL(string: urlStr as! String)
            imgURL.append(url as URL)
            
        }

        cell.imageView1.kf.setImage(with: imgURL[0], placeholder: UIImage(named: "图片占位_长.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 点击头像
        cell.portraitButton.tag = indexPath.row
        cell.portraitButton.addTarget(self, action: #selector(portraitBtnClicked(_:)), for: .touchUpInside)


    }
    
    
    func configureMySellMultiCell(_ cell: MySellMultiTableViewCell, cellForRowAt indexPath: IndexPath) {
        
        let sell = sells[(indexPath as NSIndexPath).row]
        let user = users_sell[(indexPath as NSIndexPath).row]
        
        // createdTime
        let createdTime = sell["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)

        
        cell.titleTextView.text = sell["title"] as! String
        
        cell.nameLabel.text = user["nickname"] as! String?
        
        let clicks: String = (sell["clicks"]! as AnyObject).debugDescription
        cell.clicksLabel.text = "点击\((clicks as String?)!)"
        
        // 头像
        let imgFile = user["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 图片
        var imgURL: [URL] = []
        
        for file in sell["images"] as! [AVFile] {
            let objectId = file.objectId!
            let query = AVQuery(className: "_File")
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2

            let imgFile = query.getObjectWithId(objectId)
            let urlStr = (imgFile?["url"])!
            let url: URL! = URL(string: urlStr as! String)
            imgURL.append(url as URL)
            
        }

        let imageNum = imgURL.count
        
        if imageNum == 2 {

            cell.imageView1.kf.setImage(with: imgURL[0], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView2.kf.setImage(with: imgURL[1], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView3.isHidden = true

            
        } else {
          
            cell.imageView1.kf.setImage(with: imgURL[0], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView2.kf.setImage(with: imgURL[1], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView3.kf.setImage(with: imgURL[2], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView3.isHidden = false

        }
        
        
        // 删除按钮
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteBtnClicked_sell(_:)), for: .touchUpInside)
        
        // 点击头像
        cell.portraitButton.tag = indexPath.row
        cell.portraitButton.addTarget(self, action: #selector(portraitBtnClicked(_:)), for: .touchUpInside)
        
    }
    
    func configureOtherSellMultiCell(_ cell: OtherSellMultiTableViewCell, cellForRowAt indexPath: IndexPath) {
        
        let sell = sells[(indexPath as NSIndexPath).row]
        let user = users_sell[(indexPath as NSIndexPath).row]
        
        // createdTime
        let createdTime = sell["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)

        
        cell.titleTextView.text = sell["title"] as! String
        
        cell.nameLabel.text = user["nickname"] as! String?
        
        let clicks: String = (sell["clicks"]! as AnyObject).debugDescription
        cell.clicksLabel.text = "点击\((clicks as String?)!)"
        
        // 头像
        let imgFile = user["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 图片
        var imgURL: [URL] = []
        
        for file in sell["images"] as! [AVFile] {
            let objectId = file.objectId!
            let query = AVQuery(className: "_File")
            // 缓存2mins
            query.cachePolicy = .cacheElseNetwork
            query.maxCacheAge = 60 * 2

            let imgFile = query.getObjectWithId(objectId)
            let urlStr = (imgFile?["url"])!
            let url: URL! = URL(string: urlStr as! String)
            imgURL.append(url as URL)
            
        }

        let imageNum = imgURL.count
        
        if imageNum == 2 {

            
            cell.imageView1.kf.setImage(with: imgURL[0], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView2.kf.setImage(with: imgURL[1], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView3.isHidden = true
            

            
        } else {
            
            cell.imageView1.kf.setImage(with: imgURL[0], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView2.kf.setImage(with: imgURL[1], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView3.kf.setImage(with: imgURL[2], placeholder: UIImage(named: "图片占位_正.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
            cell.imageView3.isHidden = false


            
        }        
        
        // 点击头像
        cell.portraitButton.tag = indexPath.row
        cell.portraitButton.addTarget(self, action: #selector(portraitBtnClicked(_:)), for: .touchUpInside)
 
    }
    

    
    func portraitBtnClicked(_ button: UIButton) {
        
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherInfoVC") as! OtherInfoViewController
        let indexPath = button.tag
        
        let currentUser: AVUser? = AVUser.current()
        let currentUsername = currentUser?.username ?? "visitor"

        
        if self.segmented.selectedSegmentIndex == 0 {
            let user = users_buy[indexPath]
            
            if user["username"] as! String == currentUsername {
                
            } else {
                infoVC.user = [user]
                self.navigationController?.pushViewController(infoVC, animated: true)
            }
        } else {
            let user = users_sell[indexPath]
            if user["username"] as! String == currentUsername {
                
            } else {
                infoVC.user = [user]
                self.navigationController?.pushViewController(infoVC, animated: true)
            }
        }
        
        

    }

    

    func contactBtnClicked_buy(_ button: UIButton) {
        
        let indexPath = button.tag
        let buy = buys[indexPath]
        let contactInfo = buy["contactInfo"] as! String
        

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

    
    func deleteBtnClicked_buy(_ button: UIButton){
        print("删除")
        let row = button.tag
        let indexPath = NSIndexPath(item: row, section: 0)
        
        print(button.tag)
    
        let buy = buys[row]
        let objectId = buy["objectId"] as! String

        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            dynamicAnimatorActive: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let icon = UIImage(named: "删除2.png")
        let color = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
        _ = alert.addButton("确定") {
            DispatchQueue.main.async(execute: { () -> Void in
                let todo = LCObject(className: "Buy", objectId: objectId)
                todo.delete { result in
                    switch result {
                    case .success:
                        // 删除成功
                        self.buys.remove(at: row)
                        self.users_buy.remove(at: row)
                        self.tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                        
                        
                        // 发送通知
                        let center = NotificationCenter.default
                        center.post(name: NSNotification.Name(rawValue: "passValue_delete_other"), object: nil)
                        
                        var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(SecondhandTableViewController.reload), userInfo: nil, repeats: false)
                        
                        
                        let HUD = JGProgressHUD(style: .dark)
                        HUD?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                        HUD?.textLabel.text = "成功"
                        HUD?.square = true
                        HUD?.show(in: self.view)
                        HUD?.dismiss(afterDelay: 2, animated: true)
                
                        
                    case .failure(let error):
                        // 删除失败
                        print("#4")
                        let HUD = JGProgressHUD(style: .dark)
                        HUD?.textLabel.text = "网络连接出错>_<"
                        HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                        HUD?.show(in: self.view)
                        HUD?.dismiss(afterDelay: 2.0, animated: true)
                    }
                }

            })
        }
        _ = alert.addButton("取消") {
            
        }

        _ = alert.showCustom("注意", subTitle: "确定删除这条帖子吗？", color: color, icon: icon!)

    }

    func reload() {
        self.getNewData()
        self.tableView.reloadData()
    }
    
    func deleteBtnClicked_sell(_ button: UIButton){
       
        let row = button.tag
        let indexPath = NSIndexPath(item: row, section: 0)
        
        let sell = sells[row]
        let objectId = sell["objectId"] as! String
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            dynamicAnimatorActive: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let icon = UIImage(named: "删除2.png")
        let color = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
        _ = alert.addButton("确定") {
            DispatchQueue.main.async(execute: { () -> Void in
                let todo = LCObject(className: "Sell", objectId: objectId)
                todo.delete { result in
                    switch result {
                    case .success:
                        // 删除成功

                        self.sells.remove(at: row)
                        self.users_sell.remove(at: row)
                        print("##1")
                        self.tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                        print("##2")

                        // 发送通知
                        let center = NotificationCenter.default
                        center.post(name: NSNotification.Name(rawValue: "passValue_delete_other"), object: nil)
                        
                        var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(SecondhandTableViewController.reload), userInfo: nil, repeats: false)
                        

                        let HUD = JGProgressHUD(style: .dark)
                        HUD?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                        HUD?.textLabel.text = "成功"
                        HUD?.square = true
                        HUD?.show(in: self.view)
                        HUD?.dismiss(afterDelay: 2, animated: true)
                        
                        
                    case .failure(let error):
                        // 删除失败
                        print("#3")

                        let HUD = JGProgressHUD(style: .dark)
                        HUD?.textLabel.text = "网络连接出错>_<"
                        HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                        HUD?.show(in: self.view)
                        HUD?.dismiss(afterDelay: 2.0, animated: true)
                    }
                }
                
            })
        }
        _ = alert.addButton("取消") {
            
        }
        _ = alert.showCustom("注意", subTitle: "确定删除这条帖子吗？", color: color, icon: icon!)
        
    }

    
    // MARK: Action
    @IBAction func menuButtonTouched(_ sender: AnyObject) {
        
        self.findHamburguerViewController()?.showMenuViewController()
    }

    
    @IBAction func unwindToSecondhand(_ segue: UIStoryboardSegue) {
    

    }
    
    // MARK: 添加按钮
    @IBAction func addACell(_ sender: Any) {
        
        let currentUser: AVUser? = AVUser.current()
        let currentUsername = currentUser?.username ?? "visitor"

 
        if currentUsername == "visitor" {
            
            let HUD = JGProgressHUD(style: .dark)
            HUD?.textLabel.text = "请先进行登陆>_<"
            HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
            HUD?.show(in: self.view)
            HUD?.dismiss(afterDelay: 2.0, animated: true)
            
            
        } else {
            
            let center = NotificationCenter.default
            center.addObserver(self, selector: #selector(getValue(_:)), name: NSNotification.Name(rawValue: "passValue_secondhand"), object: nil)
            
            if segmented.selectedSegmentIndex == 0 {
                // 转到 我要买
                let navigationController:UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddBuyView") as! UINavigationController
                self.present(navigationController, animated: true, completion: nil)
                
            } else if segmented.selectedSegmentIndex == 1 {
                // 转到 我要卖
                let navigationController:UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddSellView") as! UINavigationController
                self.present(navigationController, animated: true, completion: nil)
                
            }

            
        }
        
        
    }
    
    // MARK: 消息按钮
    @IBAction func chatListBtnClicked(_ sender: Any) {
        
        print("chatListBtnClicked")
        
        
        let listVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatListVC") as! ChatListViewController
        
        
        self.navigationController?.pushViewController(listVC, animated: true)
        
        
    }
    
    // MARK: 收到消息，红点
    func getMessage(_ notification: Notification) {
        
        print("收到消息了")
        
  
        DispatchQueue.main.sync {
            
            self.redPoint.isHidden = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let unRead = RCIMClient.shared().getTotalUnreadCount()

        
        if unRead >= 1 {

                self.redPoint.isHidden = false
            
        } else {

                self.redPoint.isHidden = true
            
        }
    }
    
    
    
    
    // 单击状态栏滚到顶部
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        
        return true
    }

    
}
