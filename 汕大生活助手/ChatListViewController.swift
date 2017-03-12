//
//  ChatListViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2017/3/2.
//  Copyright © 2017年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud


class ChatListViewController: RCConversationListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        self.title = "消息列表"
        
        // 会话类型
        self.setDisplayConversationTypes([
            RCConversationType.ConversationType_PRIVATE.rawValue,
            RCConversationType.ConversationType_SYSTEM.rawValue,
            RCConversationType.ConversationType_GROUP.rawValue,
            RCConversationType.ConversationType_CHATROOM.rawValue,
            RCConversationType.ConversationType_APPSERVICE.rawValue,
            RCConversationType.ConversationType_DISCUSSION.rawValue,
            RCConversationType.ConversationType_CUSTOMERSERVICE.rawValue,
            RCConversationType.ConversationType_PUBLICSERVICE.rawValue,
            RCConversationType.ConversationType_PUSHSERVICE.rawValue
            ])
        
        // 其他设置
        self.conversationListTableView.tableFooterView = UIView()
        self.showConnectingStatusOnNavigatorBar = true
        self.isShowNetworkIndicatorView = false
        
        // 刷新UI
        self.refreshConversationTableViewIfNeeded()
        
        
        
        
    }
    
   
    
  
    override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {
        
        let conVC = ChatViewController()
        
        conVC.targetId = model.targetId
        conVC.userName = model.conversationTitle
        
        if conVC.userName.contains("KEFU148854728848663") || conVC.userName.contains("机器") || conVC.userName.contains("KEFU148854728848663") {
            conVC.conversationType = .ConversationType_CUSTOMERSERVICE
        } else if conVC.userName.contains("EasierInSTU") {
            conVC.conversationType = .ConversationType_SYSTEM

        } else {
            conVC.conversationType = .ConversationType_PRIVATE
        }
        conVC.title = model.conversationTitle
        
        
        self.navigationController?.pushViewController(conVC, animated: true)
        UIView.setAnimationsEnabled(true)
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        let unRead = RCIMClient.shared().getTotalUnreadCount()
        if unRead == 0 {
            //清除所有本地推送
            UIApplication.shared.applicationIconBadgeNumber = 0

        }
    }
    
    
    
    
    
    
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
