//
//  AboutCellTableViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2017/2/20.
//  Copyright © 2017年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import LeanCloudFeedback


class AboutCellTableViewController: UITableViewController {

    @IBOutlet weak var littleRedPoint: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.littleRedPoint.isHidden = true
   
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {

            let currentUser: AVUser? = AVUser.current()
            let currentUsername = currentUser?.username ?? "visitor"
            
            var contact = currentUser?.email
            if currentUsername == "visitor" {
                contact = "visitor"
            }
            
            
            let feedbackVC = LCUserFeedbackViewController()
            feedbackVC.contact = contact! + "（可修改）"
            feedbackVC.contactHeaderHidden = false
            feedbackVC.feedbackTitle = nil
            feedbackVC.presented = false
            feedbackVC.navigationBarStyle = LCUserFeedbackNavigationBarStyleBlue
            self.navigationController?.pushViewController(feedbackVC, animated: true)   
                
            
        }
            
//        } else if indexPath.row == 2 {
//            
//            let SERVICE_ID = "KEFU148854728848663"
//            let chatService = RCDCustomerServiceViewController()
//            chatService.userName = "客服"
//            chatService.conversationType = .ConversationType_CUSTOMERSERVICE
//            chatService.targetId = SERVICE_ID
//            chatService.title = chatService.userName
//            self.navigationController?.pushViewController(chatService, animated: true)
//
//        }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {

//        let agent = LCUserFeedbackAgent.sharedInstance().countUnreadFeedbackThreads { (number, error) in
//            if (error != nil) {
//                //  网络错误，不设置红点
//                print("网络错误，不设置红点")
//                self.littleRedPoint.isHidden = true
//
//            } else {
//                // 根据number设置红点或移除红点
//                
//                print(number)
//                if (number != 0) {
//                    self.littleRedPoint.isHidden = false
//                } else {
//                    self.littleRedPoint.isHidden = true
//                }
//                
//            }
//        }
        
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
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
