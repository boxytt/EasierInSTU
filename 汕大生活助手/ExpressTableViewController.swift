//
//  ExpressTableViewController.swift
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

class ExpressTableViewController: UITableViewController {
    @IBOutlet weak var segmented: UISegmentedControl!

    var expresses_ask: [AVObject] = []
    var expresses_help: [AVObject] = []
    var users_ask: [AVObject] = []
    var users_help: [AVObject] = []
    let redPoint = UIImageView(image: UIImage(named: "小红点_full"))

    override func viewDidLoad() {
        super.viewDidLoad()

        // 空白页
        let waitView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 600))
        waitView.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        self.tableView.backgroundView = waitView
        self.tableView.tableFooterView = waitView
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        self.tableView.separatorColor = UIColor.clear

        getNewData()
        
        // 下拉刷新
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        self.refreshControl?.tintColor = UIColor.lightGray
        self.refreshControl?.addTarget(self, action: #selector(ExpressTableViewController.getNewData), for: .valueChanged)

        
        // cell自适应高度
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
        // 创建一个重用的单元格
        self.tableView!.register(UINib(nibName:"MyAskExpressTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"MyAskExpressCell")
        self.tableView!.register(UINib(nibName:"OtherAskExpressTableViewCell", bundle:nil),
                                  forCellReuseIdentifier:"OtherAskExpressCell")
        self.tableView!.register(UINib(nibName:"MyHelpExpressTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"MyHelpExpressCell")
        self.tableView!.register(UINib(nibName:"OtherHelpExpressTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"OtherHelpExpressCell")
        
        
        // 通知
        let center = NotificationCenter.default
//        center.addObserver(self, selector: #selector(getNewNicknameOrPortrait(_:)), name: NSNotification.Name(rawValue: "passValue_nickname"), object: nil)
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
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        getNewData()
        self.tableView.reloadData()
        
    }
    
    func getNewNicknameOrPortrait(_ notification: Notification) {
        getRecordFromCloud_ask(true)
        getRecordFromCloud_help(true)
    }

    

    
    func getNewData() {
        deleteOutdatedAndGetNew()
    }
    
    // MARK: 删去云端中过时的数据
    func deleteOutdatedAndGetNew() {
        
        var query = LCQuery(className: "AskExpress")
        
        if self.segmented.selectedSegmentIndex == 0 {
            query = LCQuery(className: "AskExpress")
        } else {
            query = LCQuery(className: "HelpExpress")
        }

        
        query.whereKey("deadline", .lessThan(NSDate() as Date))
        
        query.find { (result) in
            
            switch result {
                
            case .success(let objects):
                if objects != [] {
                    for object in objects {
                        
                        let objectId = object["objectId"]
                        
                        var todo = LCObject(className: "AskExpress", objectId: objectId as! LCStringConvertible)
                        
                        if self.segmented.selectedSegmentIndex == 0 {
                            todo = LCObject(className: "AskExpress", objectId: objectId as! LCStringConvertible)
                            print("Ask")
                        } else {
                            todo = LCObject(className: "HelpExpress", objectId: objectId as! LCStringConvertible)
                            print("Help")
                        }

                        todo.delete({ (result) in
                            switch result {
                            case .success:
                                
                                
                                if self.segmented.selectedSegmentIndex == 0 {
                                    self.getRecordFromCloud_ask(true)
                                } else {
                                    self.getRecordFromCloud_help(true)
                                }

                                
                            case .failure(let error):
                                print(error)
                            }
                        })
                        
                    }
                    
                } else {
                    if self.segmented.selectedSegmentIndex == 0 {
                        self.getRecordFromCloud_ask(true)
                    } else {
                        self.getRecordFromCloud_help(true)
                    }
                }
                
            case .failure(let error):
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
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(CarPoolTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
            }
        }
        
    }

    
    
    // MARK: 从云端获取数据
    
    func getRecordFromCloud_ask(_ needNew: Bool = false) {
        
        print("getAsk")

        let query = AVQuery(className: "AskExpress")
        
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
                
                print(error.localizedDescription)
                
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(SecondhandTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
                
            }
            
            if let objects = objects as? [AVObject] {
                
                self.expresses_ask = objects
                self.users_ask = []
                for object in objects {
                    let user = object.object(forKey: "toUser")
                    self.users_ask.append(user as! AVObject)
                    
                }
                
                if self.expresses_ask == [] {
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
                    
                    self.tableView.tableFooterView = emptyView
                    
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
    
    func getRecordFromCloud_help(_ needNew: Bool = false) {
        
        let query = AVQuery(className: "HelpExpress")
        
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

                print(error.localizedDescription)
                let HUD = JGProgressHUD(style: .dark)
                HUD?.textLabel.text = "网络连接出错>_<"
                HUD?.indicatorView = JGProgressHUDErrorIndicatorView.init()
                HUD?.show(in: self.view)
                HUD?.dismiss(afterDelay: 2.0, animated: true)
                var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(SecondhandTableViewController.doEndRefreshing), userInfo: nil, repeats: false)
                
            }
            
            if let objects = objects as? [AVObject] {

                self.expresses_help = objects
                self.users_help = []
                for object in objects {
                    let user = object.object(forKey: "toUser")
                    self.users_help.append(user as! AVObject)

                }
                
                if self.expresses_help == [] {
                    
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
                    
                    self.tableView.tableFooterView = emptyView
                    
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.segmented.selectedSegmentIndex == 0 {
            return expresses_ask.count
        } else {
            return expresses_help.count
        }
    }


    // MARK: cell

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentUser: AVUser? = AVUser.current()
        let currentUsername = currentUser?.username ?? "visitor"
        
        
        if self.segmented.selectedSegmentIndex == 0 {
            let express_ask = expresses_ask[(indexPath as NSIndexPath).row]
            let username_ask = express_ask["username"] as! String

            if username_ask == currentUsername {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyAskExpressCell", for: indexPath) as! MyAskExpressTableViewCell
                configureMyAskExpressCell(cell, cellForRowAt: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherAskExpressCell", for: indexPath) as! OtherAskExpressTableViewCell
                configureOtherAskExpressCell(cell, cellForRowAt: indexPath)
                return cell
            }
            
        } else {
            let express_help = expresses_help[(indexPath as NSIndexPath).row]
            let username_help = express_help["username"] as! String
            
            if username_help == currentUsername {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyHelpExpressCell", for: indexPath) as! MyHelpExpressTableViewCell
                configureMyHelpExpressCell(cell, cellForRowAt: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherHelpExpressCell", for: indexPath) as! OtherHelpExpressTableViewCell
                configureOtherHelpExpressCell(cell, cellForRowAt: indexPath)
                return cell
            }
            
        }
        

    }
    
    
    func configureMyAskExpressCell(_ cell: MyAskExpressTableViewCell, cellForRowAt indexPath: IndexPath) {
        
        let express_ask = expresses_ask[(indexPath as NSIndexPath).row]
        let user_ask = users_ask[(indexPath as NSIndexPath).row]
        
        // createdTime
        let createdTime = express_ask["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)

        
        cell.descriptionTextView.text = express_ask["description"] as! String
        
        cell.nameLabel.text = user_ask["nickname"] as! String?
        
        let imgFile = user_ask["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 删除按钮
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteBtnClicked_ask(_:)), for: .touchUpInside)
        
        // 我想要按钮
        cell.contactButton.tag = indexPath.row
        cell.contactButton.addTarget(self, action: #selector(contactBtnClicked_ask(_:)), for: .touchUpInside)
        
        // 点击头像
        cell.portraitButton.tag = indexPath.row
        cell.portraitButton.addTarget(self, action: #selector(portraitBtnClicked(_:)), for: .touchUpInside)
        
    }
    
    func configureOtherAskExpressCell(_ cell: OtherAskExpressTableViewCell, cellForRowAt indexPath: IndexPath) {
        
        let express_ask = expresses_ask[(indexPath as NSIndexPath).row]
        let user_ask = users_ask[(indexPath as NSIndexPath).row]
        
        // createdTime
        let createdTime = express_ask["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)

        cell.descriptionTextView.text = express_ask["description"] as! String
        
        cell.nameLabel.text = user_ask["nickname"] as! String?
        
        let imgFile = user_ask["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 我想要按钮
        cell.contactButton.tag = indexPath.row
        cell.contactButton.addTarget(self, action: #selector(contactBtnClicked_ask(_:)), for: .touchUpInside)
        
        // 点击头像
        cell.portraitButton.tag = indexPath.row
        cell.portraitButton.addTarget(self, action: #selector(portraitBtnClicked(_:)), for: .touchUpInside)
    }
    
    func configureMyHelpExpressCell(_ cell: MyHelpExpressTableViewCell, cellForRowAt indexPath: IndexPath) {
        
        let express_help = expresses_help[(indexPath as NSIndexPath).row]
        let user_help = users_help[(indexPath as NSIndexPath).row]
        
        // createdTime
        let createdTime = express_help["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)
        
        cell.descriptionTextView.text = express_help["description"] as! String
        
        cell.nameLabel.text = user_help["nickname"] as! String?
        
        let imgFile = user_help["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 删除按钮
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteBtnClicked_help(_:)), for: .touchUpInside)
        
        // 我想要按钮
        cell.contactButton.tag = indexPath.row
        cell.contactButton.addTarget(self, action: #selector(contactBtnClicked_help(_:)), for: .touchUpInside)
        
        // 点击头像
        cell.portraitButton.tag = indexPath.row
        cell.portraitButton.addTarget(self, action: #selector(portraitBtnClicked(_:)), for: .touchUpInside)
        
    }
    
    func configureOtherHelpExpressCell(_ cell: OtherHelpExpressTableViewCell, cellForRowAt indexPath: IndexPath) {
        
        let express_help = expresses_help[(indexPath as NSIndexPath).row]
        let user_help = users_help[(indexPath as NSIndexPath).row]
        
        // createdTime
        let createdTime = express_help["createdAt"] as! Date
        cell.timeLabel.text = getShowFormat(createdTime)
        
        cell.descriptionTextView.text = express_help["description"] as! String
        
        cell.nameLabel.text = user_help["nickname"] as! String?
        
        let imgFile = user_help["image"]! as! AVFile
        let urlStr = (imgFile.url)!
        let url: URL! = URL(string: urlStr)
        cell.portraitView.kf.setImage(with: url, placeholder: UIImage(named: "defaultPortrait.png"), options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: nil)
        
        // 我想要按钮
        cell.contactButton.tag = indexPath.row
        cell.contactButton.addTarget(self, action: #selector(contactBtnClicked_help(_:)), for: .touchUpInside)

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
            let user = users_ask[indexPath]
            if user["username"] as! String == currentUsername {
                
            } else {
                infoVC.user = [user]
                self.navigationController?.pushViewController(infoVC, animated: true)
            }
            
        } else {
            let user = users_help[indexPath]
            if user["username"] as! String == currentUsername {
                
            } else {
                infoVC.user = [user]
                self.navigationController?.pushViewController(infoVC, animated: true)
            }


        }
        
        
    
    }
    
    func contactBtnClicked_ask(_ button: UIButton) {
        
        let indexPath = button.tag
        let express_ask = expresses_ask[indexPath]
        let contactInfo = express_ask["contactInfo"] as! String
        
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

    func deleteBtnClicked_ask(_ button: UIButton){
        
        let row = button.tag
        let indexPath = NSIndexPath(item: row, section: 0)
        
        let express_ask = expresses_ask[row]
        let objectId = express_ask["objectId"] as! String
        
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
                let todo = LCObject(className: "AskExpress", objectId: objectId)
                todo.delete { result in
                    switch result {
                    case .success:
                        // 删除成功
                        self.expresses_ask.remove(at: row)
                        self.users_ask.remove(at: row)
                        self.tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                        
                        // 发送通知
                        let center = NotificationCenter.default
                        center.post(name: NSNotification.Name(rawValue: "passValue_delete_other"), object: nil)
                        
                        var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(ExpressTableViewController.reload), userInfo: nil, repeats: false)
                        
                        
                        let HUD = JGProgressHUD(style: .dark)
                        HUD?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                        HUD?.textLabel.text = "成功"
                        HUD?.square = true
                        HUD?.show(in: self.view)
                        HUD?.dismiss(afterDelay: 2, animated: true)
                        
                        
                    case .failure(let error):
                        // 删除失败
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

    func contactBtnClicked_help(_ button: UIButton) {
        
        let indexPath = button.tag
        let express_help = expresses_help[indexPath]
        let contactInfo = express_help["contactInfo"] as! String
        
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
    
    func deleteBtnClicked_help(_ button: UIButton){
        
        let row = button.tag
        let indexPath = NSIndexPath(item: row, section: 0)
        
        let express_help = expresses_help[row]
        let objectId = express_help["objectId"] as! String
        
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
                let todo = LCObject(className: "HelpExpress", objectId: objectId)
                todo.delete { result in
                    switch result {
                    case .success:
                        // 删除成功
                        self.expresses_help.remove(at: row)
                        self.users_help.remove(at: row)
                        self.tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                        
                        // 发送通知
                        let center = NotificationCenter.default
                        center.post(name: NSNotification.Name(rawValue: "passValue_delete_other"), object: nil)
                        
                        var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(ExpressTableViewController.reload), userInfo: nil, repeats: false)
                        
                        
                        let HUD = JGProgressHUD(style: .dark)
                        HUD?.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                        HUD?.textLabel.text = "成功"
                        HUD?.square = true
                        HUD?.show(in: self.view)
                        HUD?.dismiss(afterDelay: 2, animated: true)
                        
                        
                    case .failure(let error):
                        // 删除失败
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
    
    @IBAction func unwindToExpress(_ segue: UIStoryboardSegue) {
        
        
    }
    
    
    // 添加按钮
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
            center.addObserver(self, selector: #selector(getValue(_:)), name: NSNotification.Name(rawValue: "passValue_express"), object: nil)
            
            if segmented.selectedSegmentIndex == 0 {
                // 转到 求帮拿
                let navigationController:UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAskView") as! UINavigationController
                self.present(navigationController, animated: true, completion: nil)
                
            } else if segmented.selectedSegmentIndex == 1 {
                // 转到 我帮拿
                let navigationController:UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddHelpView") as! UINavigationController
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
    
    
    func getValue(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "passValue_express"), object: nil)
     
        getNewData()
        self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
       
        
    }
    
    



    
    // 单击状态栏滚到顶部
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        
        return true
    }

}
