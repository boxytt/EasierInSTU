//
//  ISImagePreviewViewController.swift
//  ISImagePicker
//
//  Created by invictus on 2016/11/22.
//  Copyright © 2016年 invictus. All rights reserved.
//

import Foundation
import UIKit


class ISImagePreviewCell:UICollectionViewCell,UIScrollViewDelegate{
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    var asset:ISAssetModel?{
        didSet{
            self.backgroundColor = UIColor.black
            self.contentView.backgroundColor = UIColor.black
            scrollView.frame = self.contentView.frame
            scrollView.bouncesZoom = true
            scrollView.maximumZoomScale = CGFloat(IS_IMG_PICK_CONFIG.previewImageMaxZoom)
            scrollView.minimumZoomScale = 1.0
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.backgroundColor = UIColor.black
            scrollView.delegate = self
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.isMultipleTouchEnabled = true
            imageView.frame = scrollView.frame
            scrollView.addSubview(imageView)
            self.contentView.addSubview(scrollView)
            let singleTapGes = UITapGestureRecognizer(target: self, action: #selector(singleTap))
            let doubleTapGes = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
            doubleTapGes.numberOfTapsRequired = 2
            singleTapGes.require(toFail: doubleTapGes)
            imageView.addGestureRecognizer(singleTapGes)
            imageView.addGestureRecognizer(doubleTapGes)
            print("preview item size \(self.contentView.frame.size)")
            if let image = self.asset?.image{
                self.imageView.image = image
            }else {
                ISAssetManager.shareInstance.getAssetImgage(asset:self.asset! , expectWidth: IS_IMG_PICK_CONFIG.expectImageWidth) { (retImg:UIImage) in
                    self.imageView.image = retImg
                    self.asset?.image = retImg
                }
            }
            
            
        }
    }
    
    
    
    func singleTap(_ ges:UITapGestureRecognizer) -> Void{
    }
    func doubleTap(_ ges:UITapGestureRecognizer) -> Void{
        
        if(self.scrollView.zoomScale>1.0){
            self.scrollView.setZoomScale(1.0, animated: true)
        }else {
            let scale = scrollView.maximumZoomScale
            let point = ges.location(in: ges.view)
            let scrollSize = imageView.frame.size
            let size = CGSize(width: scrollSize.width / scale,
                              height: scrollSize.height / scale)
            let origin = CGPoint(x: point.x - size.width / 2.0,
                                 y: point.y - size.height / 2.0)
            scrollView.zoom(to:CGRect(origin: origin, size: size), animated: true)
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

class ISImagePreiewController:UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate{
    let album:ISAlbumModel
    let assets:[ISAssetModel]
    var index:Int
    var collectionView:UICollectionView?
    let bottomBar = UIView()
    let selBtn = UIButton()
    let previewNumLabel =  UILabel()
    let previewNumBack = UIImageView()
    let orignalImageBtn = UIButton()
    let selLabel = UILabel()
    let conformBtn = UIButton()
    
    var selHandler:((_ asset:ISAssetModel,_ image:UIImage)->(Bool))?
    var imagePickEndHandler:(()->())?
    init(album:ISAlbumModel,index:Int,isSelectedReview:Bool){
        self.album = album
        self.index = index
        if (isSelectedReview)
        {
            assets = self.album.selectAssets
        }else {
            assets = self.album.assets
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.setupCollectionView(self.view.frame.width,height: self.view.frame.height)
        self.setupNavigationBar()
        self.setupBottomBar()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateOrignalImageInfo()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //        let layout:UICollectionViewFlowLayout =  collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        //        layout.itemSize =  size
        //        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.removeFromSuperview()
        self.setupCollectionView(size.width, height: size.height)
    }
    
    func setupNavigationBar() -> Void{
        self.navigationController?.isNavigationBarHidden = true
        
        
        let navBar = UIView()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        let backBtn = UIButton()
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(backBtn)
        
//        selBtn.translatesAutoresizingMaskIntoConstraints = false
//        navBar.addSubview(selBtn)
        self.view.addSubview(navBar)
        navBar.backgroundColor = UIColor.black
        
        
        backBtn.setImage(UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.navBackItemImg), for: UIControlState.normal)
        backBtn.addTarget(self, action: #selector(backAct), for: UIControlEvents.touchUpInside)
        
//        selBtn.addTarget(self, action: #selector(selImgAct(sender:)), for: UIControlEvents.touchUpInside)
        
        
        // backBtn
        navBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[backBtn(==44)]", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["backBtn":backBtn]))
        navBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[backBtn(==44)]", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["backBtn":backBtn]))
        
        // selBtn
//        navBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[selBtn(==44)]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selBtn":selBtn]))
//        navBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selBtn(==44)]-10-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selBtn":selBtn]))
        
        
        // constraint for navbar
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[navBar(==64)]", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["navBar":navBar]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[navBar]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["navBar":navBar]))
        
    }
    
    
    func setupCollectionView(_ width:CGFloat,height:CGFloat) ->Void{
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame:CGRect(x:0,y:0,width:width,height:height), collectionViewLayout: layout)
        if let collectionView = collectionView{
            self.view.insertSubview(collectionView, at: 0)
            collectionView.backgroundColor = UIColor.black
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.backgroundColor = UIColor.white
            collectionView.isPagingEnabled = true
            collectionView.bounces = false
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.alwaysBounceVertical = true
            collectionView.register(ISImagePreviewCell.self, forCellWithReuseIdentifier:"ISImagePreviewCell")
            collectionView.setContentOffset(CGPoint(x:CGFloat(index)*collectionView.frame.width,y:0), animated: false)
            self.updateSelBtnState()
            self.scrollViewDidScroll(collectionView)
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView":collectionView]))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView":collectionView]))
        }
        
    }
    
    
    func setupBottomBar() -> Void{
        
        // bottomBar
        self.view.addSubview(bottomBar)
        bottomBar.backgroundColor = UIColor.gray
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        // previewNumBack & previewNumLabel
        previewNumBack.translatesAutoresizingMaskIntoConstraints = false
        previewNumBack.image = UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle, name:IS_IMG_PICK_CONFIG.preNumImg)
        previewNumLabel.translatesAutoresizingMaskIntoConstraints = false
        previewNumLabel.textAlignment = NSTextAlignment.center
        previewNumLabel.textColor = UIColor.white
        previewNumLabel.font = UIFont.systemFont(ofSize: 14)
        previewNumBack.addSubview(previewNumLabel)
        bottomBar.addSubview(previewNumBack)
        
        // conformBtn
        conformBtn.translatesAutoresizingMaskIntoConstraints = false
        conformBtn.setTitle("确定", for: UIControlState.normal)
        bottomBar.addSubview(conformBtn)
        
        // selLabel
        selLabel.textColor = UIColor.white
        selLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(selLabel)
        
        // selBtn
        selBtn.translatesAutoresizingMaskIntoConstraints = false
//        orignalImageBtn.addTarget(self, action: #selector(orignalImgBtnAct(sender:)), for: UIControlEvents.touchUpInside)
        selBtn.addTarget(self, action: #selector(selImgAct), for: UIControlEvents.touchUpInside)
        bottomBar.addSubview(selBtn)
        
        
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[selBtn]-10-[selLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selBtn":selBtn,"selLabel":selLabel]))
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[previewNumBack(>=25)]-[conformBtn]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumBack":previewNumBack,"conformBtn":conformBtn]))
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[selBtn]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selBtn":selBtn]))
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[selLabel]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selLabel":selLabel]))
        
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[conformBtn]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["conformBtn":conformBtn]))
        
        previewNumBack.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[previewNumLabel]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumLabel":previewNumLabel]))
        previewNumBack.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[previewNumLabel]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumLabel":previewNumLabel]))
        
        bottomBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[previewNumBack]-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previewNumBack":previewNumBack,"previewNumLabel":previewNumLabel,"conformBtn":conformBtn]))
        
        
        
        conformBtn.addTarget(self, action: #selector(pickDown), for: UIControlEvents.touchUpInside)
        
        previewNumLabel.text = "\(self.album.selectAssets.count)"
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomBar(==44.0)]-0-|", options:  NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["bottomBar":bottomBar]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bottomBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["bottomBar":bottomBar]))
        
    }
    func backAct(_ sender:UIButton) -> Void{
        _ = self.navigationController?.popViewController(animated: true)
    }
    func orignalImgBtnAct(_ sender:UIButton) ->Void{
        IS_IMG_PICK_CONFIG.isSelectOrignalImage = !IS_IMG_PICK_CONFIG.isSelectOrignalImage
        self.updateOrignalImageInfo()
    }
    func updateOrignalImageInfo() -> Void{
        if IS_IMG_PICK_CONFIG.isSelectOrignalImage {
            orignalImageBtn.setImage(UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.selImg), for: UIControlState.normal)
            ISAssetManager.shareInstance.getAssetImageOriginalSize(assets: album.selectAssets, completion: { (size:String) in
                self.selLabel.text = String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey:"选择").appending(size)
            })
        }else {
            orignalImageBtn.setImage(UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.unSelImg), for: UIControlState.normal)
            selLabel.text = String.localsizeStringFrom(IS_IMG_PICK_CONFIG.bundle, forkey:"选择")
        }
    }
    func updateSelBtnState() -> Void {
        let asset:ISAssetModel = assets[index]
        if asset.isSeleted{
            selBtn.setImage(UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.selImg), for: UIControlState.normal)
        }else {
            selBtn.setImage(UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.unSelImg), for: UIControlState.normal)
        }
    }
    func pickDown(_ sender:UIButton) ->Void{
        if let imagePickEndHandler = imagePickEndHandler{
            imagePickEndHandler()
        }
    }
    
    func selImgAct(_ sender:UIButton) -> Void{
        
        if let selHandler = selHandler{
            let asset:ISAssetModel = assets[index]
            if selHandler(asset,asset.image!) {
                previewNumLabel.text = "\(self.album.selectAssets.count)"
                self.updateOrignalImageInfo()
                if asset.isSeleted{
                    selBtn.setImage(UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.selImg), for: UIControlState.normal)
                }else {
                    selBtn.setImage(UIImage.loadBundleImage(IS_IMG_PICK_CONFIG.bundle, name: IS_IMG_PICK_CONFIG.unSelImg), for: UIControlState.normal)
                }
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ISImagePreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISImagePreviewCell", for: indexPath) as! ISImagePreviewCell
        cell.asset = assets[indexPath.row]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let  newIdex = Int(scrollView.contentOffset.x/scrollView.frame.width)
        if index != newIdex {
            index = newIdex
            self.updateSelBtnState()
        }
    }
    
}
