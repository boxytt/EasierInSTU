//
//  HomeViewController.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/20.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit
import LeanCloud
import JGProgressHUD
import AVOSCloud

class HomeViewController: UITabBarController {


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.findHamburguerViewController()?.menuDirection = .left

        
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
