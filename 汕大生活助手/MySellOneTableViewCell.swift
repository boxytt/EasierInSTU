//
//  MySellOneTableViewCell.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/12/8.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit

class MySellOneTableViewCell: UITableViewCell {

    @IBOutlet weak var portraitView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var clicksLabel: UILabel!

    @IBOutlet weak var portraitButton: UIButton!
    
    var imageView1: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let screenWidth = UIScreen.main.applicationFrame.size.width
        
        if screenWidth == 320 {
            
             imageView1 = UIImageView(frame: CGRect(x: 17, y: 72, width: 200, height: 250))
            
        } else if screenWidth  == 375 {
            
             imageView1 = UIImageView(frame: CGRect(x: 17, y: 72, width: 200, height: 250))
            
        } else if screenWidth  == 414 {
            
            
             imageView1 = UIImageView(frame: CGRect(x: 17, y: 72, width: 200, height: 250))
            
        }

       
        imageView1.contentMode = .scaleAspectFill
        imageView1.clipsToBounds = true
        self.addSubview(imageView1)
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
