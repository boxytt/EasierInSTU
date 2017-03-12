//
//  MyPostTableViewCell.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/12/15.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit

class MyPostTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var typeLabel: UILabel!

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var createAtLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
