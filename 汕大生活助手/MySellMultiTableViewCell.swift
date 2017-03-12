//
//  MySellMultiTableViewCell.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/12/22.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit

class MySellMultiTableViewCell: UITableViewCell {
    
    @IBOutlet weak var portraitView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var clicksLabel: UILabel!
    @IBOutlet weak var portraitButton: UIButton!

    var imageView1: UIImageView!
    var imageView2: UIImageView!
    var imageView3: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        let screenWidth = UIScreen.main.applicationFrame.size.width
        
        if screenWidth == 320 {
            
            imageView1 = UIImageView(frame: CGRect(x: 0, y: 74, width: 100, height: 100))
            imageView2 = UIImageView(frame: CGRect(x: screenWidth/2 - 50, y: 74, width: 100, height: 100))
            imageView3 = UIImageView(frame: CGRect(x: screenWidth - 100, y: 74, width: 100, height: 100))
            
        } else if screenWidth  == 375 {
            
            imageView1 = UIImageView(frame: CGRect(x: 11.25, y: 74, width: 110, height: 110))
            imageView2 = UIImageView(frame: CGRect(x: screenWidth/2 - 55, y: 74, width: 110, height: 110))
            imageView3 = UIImageView(frame: CGRect(x: screenWidth - 110 - 11.25, y: 74, width: 110, height: 110))
            
        } else if screenWidth  == 414 {
            
            
            imageView1 = UIImageView(frame: CGRect(x: 13.5, y: 74, width: 120, height: 120))
            imageView2 = UIImageView(frame: CGRect(x: screenWidth/2 - 60, y: 74, width: 120, height: 120))
            imageView3 = UIImageView(frame: CGRect(x: screenWidth - 120 - 13.5, y: 74, width: 120, height: 120))
            
        }
        self.addSubview(imageView1)
        self.addSubview(imageView2)
        self.addSubview(imageView3)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
