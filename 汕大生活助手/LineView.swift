//
//  lineView.swift
//  BEGIN
//
//  Created by boxytt on 16/8/27.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import UIKit

class LineView: UIView {

    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        context!.setLineWidth(0.5)
        context!.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        

        context?.move(to: CGPoint(x: 0, y: 242))
        context?.addLine(to: CGPoint(x: rect.width, y: 242))

        
        context!.strokePath()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
