//
//  OtherJobTableViewCell.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/12/6.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit

class OtherJobTableViewCell: UITableViewCell {

    @IBOutlet weak var portraitView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var portraitButton: UIButton!
    @IBOutlet weak var wantButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
