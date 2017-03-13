//
//  AppDelegate.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/16.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import AVOSCloud



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RCIMUserInfoDataSource, RCIMReceiveMessageDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        // 初始化LeanCloud的SDK：applicationId 即 App Id，applicationKey 是 App Key
        LeanCloud.initialize(applicationID: "56D0xu1vde5b1CFBJdhb1Fpk-gzGzoHsz", applicationKey: "EIAhOKPTDy2J7pP3eNQy0da9")
        AVOSCloud.setApplicationId("56D0xu1vde5b1CFBJdhb1Fpk-gzGzoHsz", clientKey: "EIAhOKPTDy2J7pP3eNQy0da9")
        AVOSCloud.setAllLogsEnabled(false)
        
        // 初始化RongIMKit
        RCIM.shared().initWithAppKey("p5tvi9dspjhg4")
        RCIM.shared().globalConversationAvatarStyle = .USER_AVATAR_CYCLE
        
        // RCIMUserInfoDataSource
        RCIM.shared().userInfoDataSource = self

        RCIM.shared().receiveMessageDelegate = self
        
        
        
        
        // 导航栏颜色
        UINavigationBar.appearance().barTintColor = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white // 导航栏返回按钮颜色
        
        
        // 标题字体
        if let font = UIFont(name: "Helvetica-BoldOblique", size: 18) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSForegroundColorAttributeName:UIColor.white,
                NSFontAttributeName:font
            ]
        }

        
        // tabBar点击后的颜色
        UITabBar.appearance().tintColor = UIColor(red: 139/255, green: 189/255, blue: 210/255, alpha: 1)
        
   
        //注册本地推送
        if #available(iOS 8.0, *) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        } else {
            
        }
               
        
        return true
    }

    // MARK：获取用户信息RCIMUserInfoDataSource
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        print("##getUserInfo")
        
        let userInfo = RCUserInfo()
        
        userInfo.userId = userId   // 申请token时，用username作为userId
        
        let query = LCQuery(className: "_User")
        
        query.whereKey("username", .prefixedBy(userId))
        
        query.getFirst { result in
            switch result {
            case .success(let todo):
                
                // 获取头像
                if let str = todo.get("image")?.jsonString {
                    let urls = getUrls(str)
                    let uri = urls[0]
                    userInfo.portraitUri = uri
                } else {
                    let uri = "http://ac-56d0xu1v.clouddn.com/a1a80f5d4c67764ccb0d.png" // defaultPortrait.png
                    userInfo.portraitUri = uri
                }
                
                // 获取name
                if let nickname = todo.get("nickname")?.jsonValue {
                    userInfo.name = nickname as! String
                }
                
          
                
            case .failure(let error):
                print(error)
                
            }
        }
        
        
        return completion(userInfo)
        
    }

       
    
    // 收到消息，发送通知
    func onRCIMReceive(_ message: RCMessage!, left: Int32) {
        print("收到消息")
        
        let unRead = RCIMClient.shared().getTotalUnreadCount()
        print(unRead)
        // 发送通知
        let center = NotificationCenter.default
        center.post(name: NSNotification.Name(rawValue: "getMessage"), object: nil)
        
        
        UIApplication.shared.applicationIconBadgeNumber = Int(unRead)
        
      
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("didReceive")
        
        let unRead = RCIMClient.shared().getTotalUnreadCount()

        //角标清零
        if unRead == 0 {
            print("0")
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    

        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

