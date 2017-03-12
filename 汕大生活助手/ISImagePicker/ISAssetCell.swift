//
//  ISAssetCell.swift
//  ISImagePicker
//
//  Created by invictus on 2016/11/21.
//  Copyright © 2016年 invictus. All rights reserved.
//

import Foundation
import UIKit

class ISAssetCameraCell: UICollectionViewCell {
    
}

class ISAssetCell: UICollectionViewCell{
    let selBtn:UIButton = UIButton()
    let selImg:UIImageView = UIImageView()
    let imgV:UIImageView = UIImageView()
    var selHandler:((_ asset:ISAssetModel,_ image:UIImage)->(Bool))?
    var asset:ISAssetModel?{
        didSet{
            
            self.imgV.frame = self.contentView.frame
            selBtn.frame = CGRect(x:self.frame.width*3/5,y:0,width:self.frame.width*2/5,height:self.frame.width*2/5)
            selBtn.addTarget(self, action:#selector(setImgAct), for: UIControlEvents.touchUpInside)
            selImg.frame = CGRect(x:self.frame.width*3/4,y:0,width:self.frame.width*1/4,height:self.frame.width*1/4)
            self.contentView.addSubview(self.imgV)
            self.contentView.addSubview(selImg)
            self.contentView .addSubview(selBtn)
            self.imgSled = (asset?.isSeleted)!
            if let image = self.asset?.image{
                self.imgV.image = image
            }else {
                ISAssetManager.shareInstance.getAssetImgage(asset:self.asset! , expectWidth: IS_IMG_PICK_CONFIG.expectImageWidth) { (image:UIImage) in
                    self.asset?.image = image
                    self.imgV.image = image
                }
            }
            
        }
    }
    var imgSled: Bool = false{
        didSet{
            if(imgSled){
                self.selImg.image = UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle,name:IS_IMG_PICK_CONFIG.selImg)
            }else {
                self.selImg.image = UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle,name:IS_IMG_PICK_CONFIG.unSelImg)
            }
        }
    }
    
    func setImgAct(_ sender:UIButton){
        if let selHandler = selHandler{
            if(selHandler(asset!,self.imgV.image!)){
                self.imgSled = !self.imgSled
            }
        }
    }
}
