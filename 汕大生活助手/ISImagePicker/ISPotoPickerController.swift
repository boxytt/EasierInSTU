//
//  ISPhotoPickerController.swift
//  ISImagePicker
//
//  Created by invictus on 2016/11/21.
//  Copyright © 2016年 invictus. All rights reserved.
//

import UIKit

class ISPotoPickerController:UIViewController,UICollectionViewDataSource,UICollectionViewDelegate{
    let album:ISAlbumModel
    let bottomBar = UIView()
    let previewNumLabel =  UILabel()
    let previewNumBack = UIImageView()
    let previewBtn = UIButton()
    let conformBtn = UIButton()
    let orignalImageBtn = UIButton()
    let orignalImageLabel = UILabel()
    var imagePickerDidEnd:((_ images:[UIImage],_ assets:[ISAssetModel],_ isSelectOrignalImage:Bool)->())?
    var imagePickerDidCancel:(()->())?
    let collectionView:UICollectionView
   
    //MARK:Init
    init(album:ISAlbumModel){
        self.album = album;
        collectionView = UICollectionView(frame:CGRect(x: 0, y: 0, width:0, height:0), collectionViewLayout: UICollectionViewFlowLayout())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:Set View UI
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.title = album.name
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey:"取消"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelAct))
        self.view.addSubview(bottomBar)
        self.setupCollectionView()
        self.setupBottomBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        if(album.selectAssets.count>0){
            self.previewBtn.isEnabled = false
            self.conformBtn.isEnabled = true
        }else{
            self.previewBtn.isEnabled = false
            self.conformBtn.isEnabled = false
        }
    }
   
    func setupCollectionView() ->Void{
        self.view.addSubview(collectionView)
        let layout = UICollectionViewFlowLayout()
        let itemWH = (self.view.frame.width - CGFloat(IS_IMG_PICK_CONFIG.columnCount+1)*CGFloat(IS_IMG_PICK_CONFIG.columnMargin))/CGFloat(IS_IMG_PICK_CONFIG.columnCount)
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
        layout.minimumLineSpacing = IS_IMG_PICK_CONFIG.columnMargin
        layout.minimumInteritemSpacing = IS_IMG_PICK_CONFIG.columnMargin
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        collectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 44)
        collectionView.collectionViewLayout = layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsetsMake(IS_IMG_PICK_CONFIG.columnMargin, IS_IMG_PICK_CONFIG.columnMargin, IS_IMG_PICK_CONFIG.columnMargin, IS_IMG_PICK_CONFIG.columnMargin)
        collectionView.register(ISAssetCell.self, forCellWithReuseIdentifier:"ISAssetCell")
        collectionView.register(ISAssetCameraCell.self, forCellWithReuseIdentifier: "ISAssetCameraCell")

         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-[bottomBar]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: ["narbarheight":self.navigationController?.navigationBar.frame.height ?? 64], views: ["collectionView":collectionView,"bottomBar":bottomBar]))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView":collectionView]))
    }
    
    func setupBottomBar() -> Void{
  
        bottomBar.backgroundColor = UIColor.gray
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        previewNumBack.translatesAutoresizingMaskIntoConstraints = false
        previewNumBack.image = UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle, name:IS_IMG_PICK_CONFIG.preNumImg)
        previewNumLabel.translatesAutoresizingMaskIntoConstraints = false
        previewNumLabel.textAlignment = NSTextAlignment.center
        previewNumLabel.textColor = UIColor.white
        previewNumLabel.font = UIFont.systemFont(ofSize: 14)
        previewNumBack.addSubview(previewNumLabel)
        bottomBar.addSubview(previewNumBack)
        
        previewBtn.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(previewBtn)
        
        
        conformBtn.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(conformBtn)
       

        
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[preBtn]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["preBtn":previewBtn,]))
        
        //改 确定按钮 的位置
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[previewNumBack(>=25)]-[conformBtn]-150-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumBack":previewNumBack,"conformBtn":conformBtn]))

        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[preBtn]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["preBtn":previewBtn,"conformBtn":conformBtn,"previewNumLabel":previewNumLabel]))
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[conformBtn]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["preBtn":previewBtn,"conformBtn":conformBtn]))
        
        previewNumBack.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[previewNumLabel]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumLabel":previewNumLabel]))
        previewNumBack.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[previewNumLabel]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumLabel":previewNumLabel]))
        
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[previewNumBack]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumBack":previewNumBack,"previewNumLabel":previewNumLabel,"conformBtn":conformBtn]))
        
        previewBtn.setTitle(String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey:""), for: UIControlState.normal)
        previewBtn.addTarget(self, action: #selector(preViewImages), for: UIControlEvents.touchUpInside)
        
        conformBtn.setTitle(String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey:"确定"), for: UIControlState.normal)
        conformBtn.addTarget(self, action: #selector(pickImageDown), for: UIControlEvents.touchUpInside)
        
        previewNumLabel.text = "\(self.album.selectAssets.count)"
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomBar(==44.0)]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["bottomBar":bottomBar]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bottomBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["bottomBar":bottomBar]))
 
    }
    //MARK: Event Handler
    func cancelAct(_ sender:UIBarButtonItem) ->Void{
//        _ = self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }

    
    func preViewImages(_ sender:UIButton) ->Void{
        let preViewController = ISImagePreiewController(album: self.album, index:0, isSelectedReview:true)
        preViewController.selHandler = self.photoPickHandler
        preViewController.imagePickEndHandler = self.imagePickEndHandler
        self.navigationController?.pushViewController(preViewController, animated: true)
    }
    func pickImageDown(_ sender:UIButton) -> Void{
        self.imagePickEndHandler()
     
    }
    
    func imagePickEndHandler() -> Void {
        guard  let imagePickerDidEnd = self.imagePickerDidEnd else {
            return
        }
        if IS_IMG_PICK_CONFIG.isSelectOrignalImage{
            ISAssetManager.shareInstance.getAssetOrignalImages(assets: self.album.selectAssets, completion: { (retImages:[UIImage]) in
                imagePickerDidEnd(retImages,self.album.selectAssets,IS_IMG_PICK_CONFIG.isSelectOrignalImage)
            })
        }else {
            var ret = [UIImage]()
            for asset in self.album.selectAssets{
                if let image = asset.image{
                    ret.append(image)
                }
            }
            imagePickerDidEnd(ret,self.album.selectAssets,IS_IMG_PICK_CONFIG.isSelectOrignalImage)
        }
    }
    
    func photoPickHandler(_ asset:ISAssetModel,image:UIImage) -> Bool{
        if(asset.isSeleted){
            let index = self.album.selectAssets.index(of:asset)
            self.album.selectAssets.remove(at: index!)
        }else {
            if(self.album.selectAssets.count >= IS_IMG_PICK_CONFIG.maxIamgesCount){
                let alert = UIAlertController(title: String(format:String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey:"最多选择 %zd 张图片"), IS_IMG_PICK_CONFIG.maxIamgesCount), message: nil,preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey:"确定"), style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }else {
                self.album.selectAssets.append(asset)
            }
        }
        asset.isSeleted = !asset.isSeleted
        self.previewNumLabel.text = "\(self.album.selectAssets.count)"
//        self.updateOrignalImageInfo()
        if(self.album.selectAssets.count == 0){
            self.previewBtn.isEnabled = false
            self.conformBtn.isEnabled = false
        }else {
            self.previewBtn.isEnabled = false
            self.conformBtn.isEnabled = true
        }
        return true
    }
    
    //MARK: CollectionView Delegate Method Override
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if IS_IMG_PICK_CONFIG.isShowTakePictureBtn {
            return album.count+1
        }
       return album.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.row>=album.count){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISAssetCameraCell", for: indexPath)
            return cell;
        }else {
            let cell:ISAssetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISAssetCell", for: indexPath) as! ISAssetCell
            cell.asset = album.assets[indexPath.row]
            cell.selHandler = photoPickHandler
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row>=album.count){
            
        }else {
            print("##")
            print(indexPath.row)
            let preViewController = ISImagePreiewController(album: self.album,index:indexPath.row,isSelectedReview:false)
            preViewController.selHandler = self.photoPickHandler
            preViewController.imagePickEndHandler = self.imagePickEndHandler
            self.navigationController?.pushViewController(preViewController, animated: true)
        }
    }
}
